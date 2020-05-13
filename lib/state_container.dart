import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gitjournal/analytics.dart';

import 'package:gitjournal/apis/git_migration.dart';
import 'package:gitjournal/appstate.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_cache.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/core/git_repo.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/features.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils/logger.dart';

import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

class StateContainer with ChangeNotifier {
  final AppState appState;

  final _opLock = Lock();
  final _loadLock = Lock();

  // FIXME: The gitRepo should never be changed once it has been setup
  //        We should always just be modifying the 'git remotes'
  //        With that, the StateContainer can be a StatelessWidget
  GitNoteRepository _gitRepo;
  NotesCache _notesCache;

  StateContainer(this.appState) {
    assert(appState.localGitRepoConfigured);

    String repoPath;
    if (appState.remoteGitRepoConfigured) {
      repoPath =
          p.join(appState.gitBaseDirectory, appState.remoteGitRepoFolderName);
    } else if (appState.localGitRepoConfigured) {
      repoPath =
          p.join(appState.gitBaseDirectory, appState.localGitRepoFolderName);
    }

    _gitRepo = GitNoteRepository(gitDirPath: repoPath);
    appState.notesFolder = NotesFolderFS(null, _gitRepo.gitDirPath);

    // Just a fail safe
    if (!appState.remoteGitRepoConfigured) {
      removeExistingRemoteClone();
    }

    // Makes it easier to filter the analytics
    getAnalytics().firebase.setUserProperty(
          name: 'onboarded',
          value: appState.remoteGitRepoConfigured.toString(),
        );

    var cachePath = p.join(appState.gitBaseDirectory, "cache.json");
    _notesCache = NotesCache(
      filePath: cachePath,
      notesBasePath: _gitRepo.gitDirPath,
    );

    _loadFromCache();
    _syncNotes();
  }

  void _loadFromCache() async {
    await _notesCache.load(appState.notesFolder);
    Log.i("Finished loading the notes cache");

    await _loadNotes();
    Log.i("Finished loading all the notes");
  }

  void removeExistingRemoteClone() async {
    var remoteGitDir = Directory(
        p.join(appState.gitBaseDirectory, appState.remoteGitRepoFolderName));
    var dotGitDir = Directory(p.join(remoteGitDir.path, ".git"));

    bool exists = dotGitDir.existsSync();
    if (exists) {
      await remoteGitDir.delete(recursive: true);
    }
  }

  Future<void> _loadNotes() async {
    // FIXME: We should report the notes that failed to load
    return _loadLock.synchronized(() async {
      await appState.notesFolder.loadRecursively();
      await _notesCache.buildCache(appState.notesFolder);

      appState.numChanges = await _gitRepo.numChanges();
      notifyListeners();
    });
  }

  Future<void> syncNotes({bool doNotThrow = false}) async {
    if (!appState.remoteGitRepoConfigured) {
      Log.d("Not syncing because RemoteRepo not configured");
      return true;
    }

    logEvent(Event.RepoSynced);
    appState.syncStatus = SyncStatus.Pulling;
    notifyListeners();

    Future noteLoadingFuture;
    try {
      await _gitRepo.pull();

      appState.syncStatus = SyncStatus.Pushing;
      notifyListeners();

      noteLoadingFuture = _loadNotes();

      await _gitRepo.push();

      Log.d("Synced!");
      appState.syncStatus = SyncStatus.Done;
      appState.numChanges = 0;
      notifyListeners();
    } catch (e, stacktrace) {
      Log.d("Failed to Sync");
      appState.syncStatus = SyncStatus.Error;
      notifyListeners();
      if (shouldLogGitException(e)) {
        await logException(e, stacktrace);
      }
      if (!doNotThrow) rethrow;
    }

    await noteLoadingFuture;
  }

  Future<void> _syncNotes() async {
    var freq = Settings.instance.remoteSyncFrequency;
    if (freq != RemoteSyncFrequency.Automatic) {
      return;
    }
    return syncNotes(doNotThrow: true);
  }

  void createFolder(NotesFolderFS parent, String folderName) async {
    logEvent(Event.FolderAdded);

    return _opLock.synchronized(() async {
      var newFolderPath = p.join(parent.folderPath, folderName);
      var newFolder = NotesFolderFS(parent, newFolderPath);
      newFolder.create();

      Log.d("Created New Folder: " + newFolderPath);
      parent.addFolder(newFolder);

      _gitRepo.addFolder(newFolder).then((NoteRepoResult _) {
        _syncNotes();
        appState.numChanges += 1;
        notifyListeners();
      });
    });
  }

  void removeFolder(NotesFolderFS folder) async {
    logEvent(Event.FolderDeleted);

    return _opLock.synchronized(() async {
      Log.d("Removing Folder: " + folder.folderPath);

      folder.parentFS.removeFolder(folder);
      _gitRepo.removeFolder(folder).then((NoteRepoResult _) {
        _syncNotes();
        appState.numChanges += 1;
        notifyListeners();
      });
    });
  }

  void renameFolder(NotesFolderFS folder, String newFolderName) async {
    logEvent(Event.FolderRenamed);

    return _opLock.synchronized(() async {
      var oldFolderPath = folder.folderPath;
      print("Renaming Folder from $oldFolderPath -> $newFolderName");
      folder.rename(newFolderName);

      _gitRepo
          .renameFolder(oldFolderPath, folder.folderPath)
          .then((NoteRepoResult _) {
        _syncNotes();
        appState.numChanges += 1;
        notifyListeners();
      });
    });
  }

  void renameNote(Note note, String newFileName) async {
    logEvent(Event.NoteRenamed);

    return _opLock.synchronized(() async {
      var oldNotePath = note.filePath;
      note.rename(newFileName);

      _gitRepo.renameNote(oldNotePath, note.filePath).then((NoteRepoResult _) {
        _syncNotes();
        appState.numChanges += 1;
        notifyListeners();
      });
    });
  }

  void moveNote(Note note, NotesFolderFS destFolder) async {
    if (destFolder.folderPath == note.parent.folderPath) {
      return;
    }

    logEvent(Event.NoteMoved);
    return _opLock.synchronized(() async {
      var oldNotePath = note.filePath;
      note.move(destFolder);

      _gitRepo.moveNote(oldNotePath, note.filePath).then((NoteRepoResult _) {
        _syncNotes();
        appState.numChanges += 1;
        notifyListeners();
      });
    });
  }

  void addNote(Note note) async {
    logEvent(Event.NoteAdded);

    return _opLock.synchronized(() async {
      Log.d("State Container addNote");
      note.parent.add(note);
      note.updateModified();
      _gitRepo.addNote(note).then((NoteRepoResult _) {
        _syncNotes();
        appState.numChanges += 1;
        notifyListeners();
      });
    });
  }

  void removeNote(Note note) async {
    logEvent(Event.NoteDeleted);

    return _opLock.synchronized(() async {
      // FIXME: What if the Note hasn't yet been saved?
      note.parent.remove(note);
      _gitRepo.removeNote(note).then((NoteRepoResult _) async {
        appState.numChanges += 1;
        notifyListeners();
        // FIXME: Is there a way of figuring this amount dynamically?
        // The '4 seconds' is taken from snack_bar.dart -> _kSnackBarDisplayDuration
        // We wait an aritfical amount of time, so that the user has a change to undo
        // their delete operation, and that commit is not synced with the server, till then.
        await Future.delayed(const Duration(seconds: 4));
        _syncNotes();
      });
    });
  }

  void undoRemoveNote(Note note) async {
    logEvent(Event.NoteUndoDeleted);

    return _opLock.synchronized(() async {
      note.parent.add(note);
      _gitRepo.resetLastCommit().then((NoteRepoResult _) {
        _syncNotes();
        appState.numChanges -= 1;
        notifyListeners();
      });
    });
  }

  void updateNote(Note note) async {
    logEvent(Event.NoteUpdated);

    return _opLock.synchronized(() async {
      Log.d("State Container updateNote");
      note.updateModified();
      _gitRepo.updateNote(note).then((NoteRepoResult _) {
        _syncNotes();
        appState.numChanges += 1;
        notifyListeners();
      });
    });
  }

  void saveFolderConfig(NotesFolderConfig config) async {
    if (!Features.perFolderConfig) {
      return;
    }
    logEvent(Event.FolderConfigUpdated);

    return _opLock.synchronized(() async {
      Log.d("State Container saveFolderConfig");
      await config.saveToFS();
      _gitRepo.addFolderConfig(config).then((NoteRepoResult _) {
        _syncNotes();
        appState.numChanges += 1;
        notifyListeners();
      });
    });
  }

  void completeGitHostSetup() {
    () async {
      appState.remoteGitRepoConfigured = true;
      appState.remoteGitRepoFolderName = "journal";

      await migrateGitRepo(
        fromGitBasePath: appState.localGitRepoFolderName,
        toGitBaseFolder: appState.remoteGitRepoFolderName,
        gitBasePath: appState.gitBaseDirectory,
      );

      var repoPath =
          p.join(appState.gitBaseDirectory, appState.remoteGitRepoFolderName);
      _gitRepo = GitNoteRepository(gitDirPath: repoPath);
      appState.notesFolder.reset(_gitRepo.gitDirPath);

      await _persistConfig();
      _loadNotes();
      _syncNotes();

      notifyListeners();
    }();
  }

  void completeOnBoarding() {
    appState.onBoardingCompleted = true;
    _persistConfig();
    notifyListeners();
  }

  Future _persistConfig() async {
    var pref = await SharedPreferences.getInstance();
    await appState.save(pref);
  }
}
