import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dart_git/config.dart';
import 'package:dart_git/dart_git.dart';
import 'package:git_bindings/git_bindings.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';
import 'package:time/time.dart';

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/core/git_repo.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_cache.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/features.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/settings_migrations.dart';
import 'package:gitjournal/setup/clone.dart';
import 'package:gitjournal/utils/logger.dart';

enum SyncStatus {
  Unknown,
  Done,
  Pulling,
  Pushing,
  Error,
}

class Repository with ChangeNotifier {
  final Settings settings;

  final _opLock = Lock();
  final _loadLock = Lock();

  final String gitBaseDirectory;
  final String cacheDir;
  final String id;

  GitNoteRepository _gitRepo;
  NotesCache _notesCache;

  String repoPath;

  SyncStatus syncStatus = SyncStatus.Unknown;
  String syncStatusError = "";
  int numChanges = 0;

  bool get hasJournalEntries {
    return notesFolder.hasNotes;
  }

  NotesFolderFS notesFolder;

  bool remoteGitRepoConfigured = false;

  static Future<Repository> load({
    @required String gitBaseDir,
    @required String cacheDir,
    @required SharedPreferences pref,
    @required String id,
  }) async {
    await migrateSettings(id, pref, gitBaseDir);

    var settings = Settings(id);
    settings.load(pref);

    logEvent(Event.Settings, parameters: settings.toLoggableMap());

    Log.i("Setting ${settings.toLoggableMap()}");

    var repoPath = await settings.buildRepoPath(gitBaseDir);
    Log.i("Loading Repo at path $repoPath");

    var repoDir = Directory(repoPath);
    var repoDirStat = repoDir.statSync();

    if (repoDirStat.type != FileSystemEntityType.directory) {
      Log.i("Calling GitInit for ${settings.folderName} at: $repoPath");
      await GitRepository.init(repoPath);

      settings.save();
    }

    var repo = await GitRepository.load(repoPath);
    var remoteConfigured = repo.config.remotes.isNotEmpty;
    if (remoteConfigured) {
      // Code path for 'branch is null' exception
      var branch = await repo.currentBranch();
      if (branch == null) {
        var remoteConfig = repo.config.remotes[0];
        await cloneRemote(
          repoPath: repoPath,
          remoteName: remoteConfig.name,
          cloneUrl: remoteConfig.url,
          authorName: settings.gitAuthor,
          authorEmail: settings.gitAuthorEmail,
          sshPublicKey: settings.sshPublicKey,
          sshPrivateKey: settings.sshPrivateKey,
          sshPassword: settings.sshPassword,
        );
      }
    }

    return Repository._internal(
      repoPath: repoPath,
      gitBaseDirectory: gitBaseDir,
      cacheDir: cacheDir,
      remoteGitRepoConfigured: remoteConfigured,
      settings: settings,
      id: id,
    );
  }

  Repository._internal({
    @required this.id,
    @required this.repoPath,
    @required this.gitBaseDirectory,
    @required this.cacheDir,
    @required this.settings,
    @required this.remoteGitRepoConfigured,
  }) {
    _gitRepo = GitNoteRepository(gitDirPath: repoPath, settings: settings);
    notesFolder = NotesFolderFS(null, _gitRepo.gitDirPath, settings);

    // Makes it easier to filter the analytics
    getAnalytics().setUserProperty(
      name: 'onboarded',
      value: remoteGitRepoConfigured.toString(),
    );

    var cachePath = p.join(cacheDir, "cache.json");
    _notesCache = NotesCache(
      filePath: cachePath,
      notesBasePath: _gitRepo.gitDirPath,
      settings: settings,
    );

    _loadFromCache();
    _syncNotes();
  }

  void _loadFromCache() async {
    await _notesCache.load(notesFolder);
    Log.i("Finished loading the notes cache");

    await _loadNotes();
    Log.i("Finished loading all the notes");
  }

  Future<void> _loadNotes() async {
    // FIXME: We should report the notes that failed to load
    return _loadLock.synchronized(() async {
      await notesFolder.loadRecursively();
      await _notesCache.buildCache(notesFolder);

      numChanges = await _gitRepo.numChanges();
      notifyListeners();
    });
  }

  Future<void> syncNotes({bool doNotThrow = false}) async {
    if (!remoteGitRepoConfigured) {
      Log.d("Not syncing because RemoteRepo not configured");
      return true;
    }

    logEvent(Event.RepoSynced);
    syncStatus = SyncStatus.Pulling;
    notifyListeners();

    Future noteLoadingFuture;
    try {
      await _gitRepo.fetch();
      await _gitRepo.merge();

      syncStatus = SyncStatus.Pushing;
      notifyListeners();

      noteLoadingFuture = _loadNotes();

      await _gitRepo.push();

      Log.d("Synced!");
      syncStatus = SyncStatus.Done;
      numChanges = 0;
      notifyListeners();
    } catch (e, stacktrace) {
      Log.e("Failed to Sync", ex: e, stacktrace: stacktrace);
      syncStatus = SyncStatus.Error;
      syncStatusError = e.toString();
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
        numChanges += 1;
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
        numChanges += 1;
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
        numChanges += 1;
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
        numChanges += 1;
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
        numChanges += 1;
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
        numChanges += 1;
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
        numChanges += 1;
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
        numChanges += 1;
        notifyListeners();
        // FIXME: Is there a way of figuring this amount dynamically?
        // The '4 seconds' is taken from snack_bar.dart -> _kSnackBarDisplayDuration
        // We wait an aritfical amount of time, so that the user has a change to undo
        // their delete operation, and that commit is not synced with the server, till then.
        await Future.delayed(4.seconds);
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
        numChanges -= 1;
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
        numChanges += 1;
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
        numChanges += 1;
        notifyListeners();
      });
    });
  }

  Future<void> completeGitHostSetup(
      String repoFolderName, String remoteName) async {
    var repoPath = p.join(gitBaseDirectory, repoFolderName);
    Log.i("completeGitHostSetup repoPath: $repoPath");

    _gitRepo = GitNoteRepository(gitDirPath: repoPath, settings: settings);

    await _addFileInRepo(repo: this, settings: settings);

    this.repoPath = repoPath;
    _notesCache.clear();
    remoteGitRepoConfigured = true;
    notesFolder.reset(repoPath);

    settings.folderName = repoFolderName;
    settings.save();

    await _persistConfig();
    _loadNotes();
    _syncNotes();

    notifyListeners();
  }

  Future _persistConfig() async {
    await settings.save();
  }

  Future<void> moveRepoToPath() async {
    var newRepoPath = await settings.buildRepoPath(gitBaseDirectory);

    if (newRepoPath != repoPath) {
      Log.i("Old Path: $repoPath");
      Log.i("New Path: $newRepoPath");

      await Directory(newRepoPath).create(recursive: true);
      await _copyDirectory(repoPath, newRepoPath);
      await Directory(repoPath).delete(recursive: true);

      repoPath = newRepoPath;
      _gitRepo = GitNoteRepository(gitDirPath: repoPath, settings: settings);

      _notesCache.clear();
      notesFolder.reset(repoPath);
      notifyListeners();

      _loadNotes();
    }
  }

  Future<void> discardChanges(Note note) async {
    var repo = await GitRepository.load(repoPath);
    await repo.checkout(note.filePath);
    return note.load();
  }

  Future<List<GitRemoteConfig>> remoteConfigs() async {
    var repo = await GitRepository.load(repoPath);
    return repo.config.remotes;
  }
}

Future<void> _copyDirectory(String source, String destination) async {
  await for (var entity in Directory(source).list(recursive: false)) {
    if (entity is Directory) {
      var newDirectory = Directory(p.join(
          Directory(destination).absolute.path, p.basename(entity.path)));
      await newDirectory.create();
      await _copyDirectory(entity.absolute.path, newDirectory.path);
    } else if (entity is File) {
      await entity.copy(p.join(destination, p.basename(entity.path)));
    }
  }
}

/// Add a GitIgnore file if no file is present. This way we always at least have
/// one commit. It makes doing a git pull and push easier
Future<void> _addFileInRepo({
  @required Repository repo,
  @required Settings settings,
}) async {
  var repoPath = repo.repoPath;
  var dirList = await Directory(repoPath).list().toList();
  var anyFileInRepo = dirList.firstWhere(
    (fs) => fs.statSync().type == FileSystemEntityType.file,
    orElse: () => null,
  );
  if (anyFileInRepo == null) {
    Log.i("Adding .ignore file");
    var ignoreFile = File(p.join(repoPath, ".gitignore"));
    ignoreFile.createSync();

    var repo = GitRepo(folderPath: repoPath);
    await repo.add('.gitignore');

    await repo.commit(
      message: "Add gitignore file",
      authorEmail: settings.gitAuthorEmail,
      authorName: settings.gitAuthor,
    );
  }
}
