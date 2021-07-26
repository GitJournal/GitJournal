import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:dart_git/config.dart';
import 'package:dart_git/dart_git.dart';
import 'package:dart_git/exceptions.dart';
import 'package:git_bindings/git_bindings.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';
import 'package:time/time.dart';

import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/core/git_repo.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_cache.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/settings/git_config.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/settings_migrations.dart';
import 'package:gitjournal/utils/logger.dart';

enum SyncStatus {
  Unknown,
  Done,
  Pulling,
  Pushing,
  Error,
}

class GitJournalRepo with ChangeNotifier {
  final Settings settings;
  final GitConfig gitConfig;

  final _opLock = Lock();
  final _loadLock = Lock();

  final String gitBaseDirectory;
  final String cacheDir;
  final String id;

  String? _currentBranch;

  late GitNoteRepository _gitRepo;
  late NotesCache _notesCache;

  String repoPath;

  SyncStatus syncStatus = SyncStatus.Unknown;
  String syncStatusError = "";
  int numChanges = 0;

  bool get hasJournalEntries {
    return notesFolder.hasNotes;
  }

  late NotesFolderFS notesFolder;

  bool remoteGitRepoConfigured = false;

  static Future<GitJournalRepo> load({
    required String gitBaseDir,
    required String cacheDir,
    required SharedPreferences pref,
    required String id,
  }) async {
    await migrateSettings(id, pref, gitBaseDir);

    var settings = Settings(id);
    settings.load(pref);

    logEvent(Event.Settings, parameters: settings.toLoggableMap());

    Log.i("Setting ${settings.toLoggableMap()}");

    var gitConfig = GitConfig(id);
    gitConfig.load(pref);

    var repoPath = await settings.buildRepoPath(gitBaseDir);
    Log.i("Loading Repo at path $repoPath");

    var repoDir = Directory(repoPath);

    if (!repoDir.existsSync()) {
      Log.i("Calling GitInit for ${settings.folderName} at: $repoPath");
      await GitRepository.init(repoPath);

      settings.save();
    }

    var valid = await GitRepository.isValidRepo(repoPath);
    if (!valid) {
      // What happened that the directory still exists but the .git folder
      // has disappeared?
      // FIXME: What if the '.config' file is not accessible?
      // -> https://sentry.io/share/issue/bafc5c417bdb4fd196cead1d28432f12/
    }

    var repo = await GitRepository.load(repoPath).getOrThrow();
    var remoteConfigured = repo.config.remotes.isNotEmpty;

    await Directory(cacheDir).create(recursive: true);

    return GitJournalRepo._internal(
      repoPath: repoPath,
      gitBaseDirectory: gitBaseDir,
      cacheDir: cacheDir,
      remoteGitRepoConfigured: remoteConfigured,
      settings: settings,
      gitConfig: gitConfig,
      id: id,
      currentBranch: await repo.currentBranch().getOrThrow(),
    );
  }

  GitJournalRepo._internal({
    required this.id,
    required this.repoPath,
    required this.gitBaseDirectory,
    required this.cacheDir,
    required this.settings,
    required this.gitConfig,
    required this.remoteGitRepoConfigured,
    required String? currentBranch,
  }) {
    _gitRepo = GitNoteRepository(gitDirPath: repoPath, config: gitConfig);
    notesFolder = NotesFolderFS(null, _gitRepo.gitDirPath, settings);
    _currentBranch = currentBranch;

    Log.i("Branch $_currentBranch");

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

      var changes = await _gitRepo.numChanges();
      numChanges = changes != null ? changes : 0;
      notifyListeners();
    });
  }

  Future<void> syncNotes({bool doNotThrow = false}) async {
    if (!remoteGitRepoConfigured) {
      Log.d("Not syncing because RemoteRepo not configured");
      return;
    }

    logEvent(Event.RepoSynced);
    syncStatus = SyncStatus.Pulling;
    notifyListeners();

    Future? noteLoadingFuture;
    try {
      await _gitRepo.fetch().throwOnError();

      var r = await _gitRepo.merge();
      if (r.isFailure) {
        var ex = r.error!;
        // When there is nothing to merge into
        if (ex is! GitRefNotFound) {
          throw ex;
        }
      }

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
      if (e is Exception && shouldLogGitException(e)) {
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

      _gitRepo.addFolder(newFolder).then((Result<void> _) {
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

      folder.parentFS!.removeFolder(folder);
      _gitRepo.removeFolder(folder).then((Result<void> _) {
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
          .then((Result<void> _) {
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

      _gitRepo.renameNote(oldNotePath, note.filePath).then((Result<void> _) {
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

      _gitRepo.renameFile(oldPath, newPath).then((Result<void> _) {
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

      _gitRepo.moveNote(oldNotePath, note.filePath).then((Result<void> _) {
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

      _gitRepo.addNote(note).then((Result<void> _) {
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
      _gitRepo.removeNote(note).then((Result<void> _) async {
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
      _gitRepo.resetLastCommit().then((Result<void> _) {
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

      _gitRepo.updateNote(note).then((Result<void> _) {
        _syncNotes();
        numChanges += 1;
        notifyListeners();
      });
    });
  }

  Future<void> completeGitHostSetup(
      String repoFolderName, String remoteName) async {
    repoPath = p.join(gitBaseDirectory, repoFolderName);
    Log.i("repoPath: $repoPath");

    _gitRepo = GitNoteRepository(gitDirPath: repoPath, config: gitConfig);

    await _addFileInRepo(repo: this, config: gitConfig);

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
      _gitRepo = GitNoteRepository(gitDirPath: repoPath, config: gitConfig);

      _notesCache.clear();
      notesFolder.reset(repoPath);
      notifyListeners();

      _loadNotes();
    }
  }

  Future<void> discardChanges(Note note) async {
    var repo = await GitRepository.load(repoPath).getOrThrow();
    await repo.checkout(note.filePath).throwOnError();
    await note.load();
  }

  Future<List<GitRemoteConfig>> remoteConfigs() async {
    var repo = await GitRepository.load(repoPath).getOrThrow();
    return repo.config.remotes;
  }

  Future<List<String>> branches() async {
    var repo = await GitRepository.load(repoPath).getOrThrow();
    var branches = Set<String>.from(await repo.branches().getOrThrow());
    if (repo.config.remotes.isNotEmpty) {
      var remoteName = repo.config.remotes.first.name;
      var remoteBranches = await repo.remoteBranches(remoteName).getOrThrow();
      branches.addAll(remoteBranches.map((e) {
        return e.name.branchName()!;
      }));
    }
    return branches.toList()..sort();
  }

  String? get currentBranch => _currentBranch;

  Future<String> checkoutBranch(String branchName) async {
    Log.i("Changing branch to $branchName");
    var repo = await GitRepository.load(repoPath).getOrThrow();

    try {
      var created = await createBranchIfRequired(repo, branchName);
      if (created.isEmpty) {
        return "";
      }
    } catch (ex, st) {
      Log.e("createBranch", ex: ex, stacktrace: st);
    }

    try {
      await repo.checkoutBranch(branchName).getOrThrow();
      _currentBranch = branchName;
      print("Done checking out $branchName");

      await _notesCache.clear();
      notesFolder.reset(repoPath);
      notifyListeners();

      _loadNotes();
    } catch (e, st) {
      print('maya hooo');
      print(e);
      print(st);
    }
    return branchName;
  }

  // FIXME: Why does this need to return a string?
  /// throws exceptions
  Future<String> createBranchIfRequired(GitRepository repo, String name) async {
    var localBranches = await repo.branches().getOrThrow();
    if (localBranches.contains(name)) {
      return name;
    }

    if (repo.config.remotes.isEmpty) {
      return "";
    }
    var remoteConfig = repo.config.remotes.first;
    var remoteBranches =
        await repo.remoteBranches(remoteConfig.name).getOrThrow();
    var remoteBranchRef = remoteBranches.firstWhereOrNull(
      (ref) => ref.name.branchName() == name,
    );
    if (remoteBranchRef == null) {
      return "";
    }

    await repo.createBranch(name, hash: remoteBranchRef.hash).throwOnError();
    await repo.setBranchUpstreamTo(name, remoteConfig, name).throwOnError();

    Log.i("Created branch $name");
    return name;
  }

  Future<void> delete() async {
    await Directory(repoPath).delete(recursive: true);
    await Directory(cacheDir).delete(recursive: true);
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
  required GitJournalRepo repo,
  required GitConfig config,
}) async {
  var repoPath = repo.repoPath;
  var dirList = await Directory(repoPath).list().toList();
  var anyFileInRepo = dirList.firstWhereOrNull(
    (fs) => fs.statSync().type == FileSystemEntityType.file,
  );
  if (anyFileInRepo == null) {
    Log.i("Adding .ignore file");
    var ignoreFile = File(p.join(repoPath, ".gitignore"));
    ignoreFile.createSync();

    var repo = GitRepo(folderPath: repoPath);
    await repo.add('.gitignore');

    await repo.commit(
      message: "Add gitignore file",
      authorEmail: config.gitAuthorEmail,
      authorName: config.gitAuthor,
    );
  }
}
