import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dart_git/dart_git.dart';
import 'package:path/path.dart' as p;
import 'package:synchronized/synchronized.dart';

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/appstate.dart';
import 'package:gitjournal/core/git_repo.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_cache.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/features.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils/logger.dart';

class StateContainer with ChangeNotifier {
  final AppState appState;
  final Settings settings;
  final String gitBaseDirectory;
  final String cacheDirectory;

  final _opLock = Lock();
  final _loadLock = Lock();

  // FIXME: The gitRepo should never be changed once it has been setup
  //        We should always just be modifying the 'git remotes'
  //        With that, the StateContainer can be a StatelessWidget
  GitNoteRepository _gitRepo;
  NotesCache _notesCache;

  StateContainer({
    @required this.appState,
    @required this.settings,
    @required this.gitBaseDirectory,
    @required this.cacheDirectory,
  }) {
    assert(settings.localGitRepoConfigured);
    var repoPath = p.join(gitBaseDirectory, settings.internalRepoFolderName);

    _gitRepo = GitNoteRepository(gitDirPath: repoPath, settings: settings);
    appState.notesFolder = NotesFolderFS(null, _gitRepo.gitDirPath, settings);

    // Makes it easier to filter the analytics
    getAnalytics().firebase.setUserProperty(
          name: 'onboarded',
          value: settings.remoteGitRepoConfigured.toString(),
        );

    var cachePath = p.join(cacheDirectory, "cache.json");
    _notesCache = NotesCache(
      filePath: cachePath,
      notesBasePath: _gitRepo.gitDirPath,
      settings: settings,
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
    if (!settings.remoteGitRepoConfigured) {
      Log.d("Not syncing because RemoteRepo not configured");
      return true;
    }

    logEvent(Event.RepoSynced);
    appState.syncStatus = SyncStatus.Pulling;
    notifyListeners();

    Future noteLoadingFuture;
    try {
      await _gitRepo.fetch();
      await _gitRepo.merge();

      appState.syncStatus = SyncStatus.Pushing;
      notifyListeners();

      noteLoadingFuture = _loadNotes();

      await _gitRepo.push();

      Log.d("Synced!");
      appState.syncStatus = SyncStatus.Done;
      appState.numChanges = 0;
      notifyListeners();
    } catch (e, stacktrace) {
      Log.e("Failed to Sync", ex: e, stacktrace: stacktrace);
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
    var freq = settings.remoteSyncFrequency;
    if (freq != RemoteSyncFrequency.Automatic) {
      return;
    }
    return syncNotes(doNotThrow: true);
  }

  void createFolder(NotesFolderFS parent, String folderName) async {
    logEvent(Event.FolderAdded);

    return _opLock.synchronized(() async {
      Log.d("Got createFolder lock");
      var newFolderPath = p.join(parent.folderPath, folderName);
      var newFolder = NotesFolderFS(parent, newFolderPath, settings);
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
      Log.d("Got removeFolder lock");
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
      Log.d("Got renameFolder lock");

      var oldFolderPath = folder.folderPath;
      Log.d("Renaming Folder from $oldFolderPath -> $newFolderName");
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

    var oldNotePath = note.filePath;
    note.rename(newFileName);

    return _opLock.synchronized(() async {
      Log.d("Got renameNote lock");

      _gitRepo.renameNote(oldNotePath, note.filePath).then((NoteRepoResult _) {
        _syncNotes();
        appState.numChanges += 1;
        notifyListeners();
      });
    });
  }

  void renameFile(String oldPath, String newFileName) async {
    logEvent(Event.NoteRenamed);

    return _opLock.synchronized(() async {
      Log.d("Got renameNote lock");

      var newPath = p.join(p.dirname(oldPath), newFileName);
      await File(oldPath).rename(newPath);
      notifyListeners();

      _gitRepo.renameFile(oldPath, newPath).then((NoteRepoResult _) {
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
      Log.d("Got moveNote lock");

      var oldNotePath = note.filePath;
      note.move(destFolder);

      _gitRepo.moveNote(oldNotePath, note.filePath).then((NoteRepoResult _) {
        _syncNotes();
        appState.numChanges += 1;
        notifyListeners();
      });
    });
  }

  Future<void> addNote(Note note) async {
    logEvent(Event.NoteAdded);

    note.updateModified();
    await note.save();

    note.parent.add(note);

    return _opLock.synchronized(() async {
      Log.d("Got addNote lock");

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
      Log.d("Got removeNote lock");

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
      Log.d("Got undoRemoveNote lock");

      note.parent.add(note);
      _gitRepo.resetLastCommit().then((NoteRepoResult _) {
        _syncNotes();
        appState.numChanges -= 1;
        notifyListeners();
      });
    });
  }

  Future<void> updateNote(Note note) async {
    logEvent(Event.NoteUpdated);

    note.updateModified();
    await note.save();

    return _opLock.synchronized(() async {
      Log.d("Got updateNote lock");

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
      Log.d("Got saveFolderConfig lock");

      await config.saveToFS();
      _gitRepo.addFolderConfig(config).then((NoteRepoResult _) {
        _syncNotes();
        appState.numChanges += 1;
        notifyListeners();
      });
    });
  }

  // FIXME: Pass the remote name that was added
  void completeGitHostSetup(String repoFolderName, String remoteName) {
    () async {
      var repo = await GitRepository.load(_gitRepo.gitDirPath);
      var remote = repo.config.remote(remoteName);
      var remoteBranchName = 'master';

      // FIXME: How to get this?
      //
      // There is no way to get it, just need to iterate over the refs
      // and look for one!
      await repo.setUpstreamTo(remote, remoteBranchName);

      // At this point the remote should have been added and fetched

      await _gitRepo.merge();
      settings.remoteGitRepoConfigured = true;

      await _persistConfig();
      _loadNotes();
      _syncNotes();

      notifyListeners();
    }();
  }

  Future _persistConfig() async {
    await settings.save();
  }
}
