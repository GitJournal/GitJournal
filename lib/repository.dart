/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';

import 'package:archive/archive_io.dart';
import 'package:collection/collection.dart';
import 'package:dart_git/config.dart';
import 'package:dart_git/dart_git.dart';
import 'package:dart_git/exceptions.dart';
import 'package:dart_git/plumbing/git_hash.dart';
import 'package:dart_git/plumbing/reference.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/core/commit_message_builder.dart';
import 'package:gitjournal/core/file/file_storage.dart';
import 'package:gitjournal/core/file/file_storage_cache.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/git_repo.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/note_storage.dart';
import 'package:gitjournal/core/notes_cache.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:gitjournal/settings/git_config.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/settings_migrations.dart';
import 'package:gitjournal/settings/storage_config.dart';
import 'package:gitjournal/sync_attempt.dart';
import 'package:path/path.dart' as p;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';
import 'package:time/time.dart';
import 'package:universal_io/io.dart' as io;
import 'package:universal_io/io.dart' show Platform;

class GitJournalRepo with ChangeNotifier {
  final RepositoryManager repoManager;
  final StorageConfig storageConfig;
  final GitConfig gitConfig;
  final NotesFolderConfig folderConfig;
  final Settings settings;

  final FileStorage fileStorage;
  final FileStorageCache fileStorageCache;

  final _gitOpLock = Lock();
  final _loadLock = Lock();
  final _networkLock = Lock();
  final _cacheBuildingLock = Lock();

  /// The private directory where the 'git repo' is stored.
  final String gitBaseDirectory;
  final String cacheDir;
  final String id;

  final String repoPath;

  late final GitNoteRepository _gitRepo;
  late final NotesCache _notesCache;
  late final NotesFolderFS rootFolder;

  //
  // Mutable stuff
  //

  String? _currentBranch;

  /// Sorted in newest -> oldest
  var syncAttempts = <SyncAttempt>[];
  SyncStatus get syncStatus =>
      syncAttempts.isNotEmpty ? syncAttempts.first.status : SyncStatus.Unknown;

  int numChanges = 0;

  bool remoteGitRepoConfigured = false;
  late bool fileStorageCacheReady;

  static Future<bool> exists({
    required String gitBaseDir,
    required SharedPreferences pref,
    required String id,
  }) async {
    var storageConfig = StorageConfig(id, pref);
    storageConfig.load();

    var repoPath = await storageConfig.buildRepoPath(gitBaseDir);
    return GitRepository.isValidRepo(repoPath);
  }

  static Future<GitJournalRepo> load({
    required String gitBaseDir,
    required String cacheDir,
    required SharedPreferences pref,
    required String id,
    required RepositoryManager repoManager,
    bool loadFromCache = true,
    bool syncOnBoot = true,
  }) async {
    await migrateSettings(id, pref, gitBaseDir);

    var storageConfig = StorageConfig(id, pref);
    storageConfig.load();

    var folderConfig = NotesFolderConfig(id, pref);
    folderConfig.load();

    var gitConfig = GitConfig(id, pref);
    gitConfig.load();

    var settings = Settings(id, pref);
    settings.load();

    Sentry.configureScope((scope) {
      scope.setContexts('StorageConfig', storageConfig.toLoggableMap());
      scope.setContexts('FolderConfig', folderConfig.toLoggableMap());
      scope.setContexts('GitConfig', gitConfig.toLoggableMap());
      scope.setContexts('Settings', settings.toLoggableMap());
    });

    logEvent(
      Event.StorageConfig,
      parameters: storageConfig.toLoggableMap()..addAll({'id': id}),
    );
    logEvent(
      Event.FolderConfig,
      parameters: folderConfig.toLoggableMap()..addAll({'id': id}),
    );
    logEvent(
      Event.GitConfig,
      parameters: gitConfig.toLoggableMap()..addAll({'id': id}),
    );
    logEvent(
      Event.Settings,
      parameters: settings.toLoggableMap()..addAll({'id': id}),
    );

    var repoPath = await storageConfig.buildRepoPath(gitBaseDir);
    Log.i("Loading Repo at path $repoPath");

    var repoDir = io.Directory(repoPath);

    if (!repoDir.existsSync()) {
      Log.i("Calling GitInit for ${storageConfig.folderName} at: $repoPath");
      GitRepository.init(repoPath, defaultBranch: DEFAULT_BRANCH);

      storageConfig.save();
    }

    var valid = GitRepository.isValidRepo(repoPath);
    if (!valid) {
      // What happened that the directory still exists but the .git folder
      // has disappeared?
      // FIXME: What if the '.config' file is not accessible?
      // -> https://sentry.io/share/issue/bafc5c417bdb4fd196cead1d28432f12/
      throw Exception('Folder is no longer a valid Git Repo');
    }

    var repo = await GitAsyncRepository.load(repoPath);
    var remoteConfigured = repo.config.remotes.isNotEmpty;

    if (!storageConfig.storeInternally) {
      await _commitUnTrackedChanges(repo, gitConfig);
    }

    await io.Directory(cacheDir).create(recursive: true);

    var fileStorageCache = FileStorageCache(cacheDir);
    var fileStorage = await fileStorageCache.load(repoPath);

    var head = GitHash.zero();
    try {
      head = await repo.headHash();
    } catch (_) {}

    var gjRepo = GitJournalRepo._internal(
      repoManager: repoManager,
      repoPath: repoPath,
      gitBaseDirectory: gitBaseDir,
      cacheDir: cacheDir,
      remoteGitRepoConfigured: remoteConfigured,
      storageConfig: storageConfig,
      settings: settings,
      folderConfig: folderConfig,
      gitConfig: gitConfig,
      id: id,
      fileStorage: fileStorage,
      fileStorageCache: fileStorageCache,
      currentBranch: await repo.currentBranch(),
      headHash: head,
      loadFromCache: loadFromCache,
      syncOnBoot: syncOnBoot,
    );

    return gjRepo;
  }

  GitJournalRepo._internal({
    required this.id,
    required this.repoPath,
    required this.repoManager,
    required this.gitBaseDirectory,
    required this.cacheDir,
    required this.storageConfig,
    required this.folderConfig,
    required this.settings,
    required this.gitConfig,
    required this.remoteGitRepoConfigured,
    required this.fileStorage,
    required this.fileStorageCache,
    required String? currentBranch,
    required GitHash headHash,
    required bool loadFromCache,
    required bool syncOnBoot,
  }) {
    _gitRepo = GitNoteRepository(gitRepoPath: repoPath, config: gitConfig);
    rootFolder = NotesFolderFS.root(folderConfig, fileStorage);
    _currentBranch = currentBranch;

    Log.i("Branch $_currentBranch");

    // Makes it easier to filter the analytics
    Analytics.instance?.setUserProperty(
      name: 'onboarded',
      value: remoteGitRepoConfigured.toString(),
    );

    Log.i("Cache Directory: $cacheDir");

    _notesCache = NotesCache(
      folderPath: cacheDir,
      repoPath: _gitRepo.gitRepoPath,
      fileStorage: fileStorage,
    );

    fileStorageCacheReady = headHash == fileStorageCache.lastProcessedHead;

    if (loadFromCache) _loadFromCache();
    if (syncOnBoot) _syncNotes();
  }

  Future<void> _loadFromCache() async {
    var startTime = DateTime.now();
    await _notesCache.load(rootFolder);
    var endTime = DateTime.now().difference(startTime);

    Log.i("Finished loading the notes cache - $endTime");

    startTime = DateTime.now();
    await _loadNotes();
    endTime = DateTime.now().difference(startTime);

    Log.i("Finished loading all the notes - $endTime");
  }

  Future<void> _resetFileStorage() async {
    await fileStorageCache.clear();

    // This will discard this Repository and build a new one
    repoManager.buildActiveRepository();
  }

  Future<void> reloadNotes() => _loadNotes();

  Future<void> _loadNotes() async {
    await _fillFileStorageCache();

    // FIXME: We should report the notes that failed to load
    return _loadLock.synchronized(() async {
      try {
        await rootFolder.loadRecursively();
      } on FileStorageCacheIncomplete catch (ex) {
        Log.i("FileStorageCacheIncomplete ${ex.path}");
        var repo = await GitAsyncRepository.load(repoPath);
        await _commitUnTrackedChanges(repo, gitConfig);
        await _resetFileStorage();
        return;
      }

      await _notesCache.buildCache(rootFolder);

      var changes = await _gitRepo.numChanges();
      numChanges = changes ?? 0;
      notifyListeners();
    });
  }

  Future<void> _fillFileStorageCache() {
    return _cacheBuildingLock.synchronized(__fillFileStorageCache);
  }

  Future<void> __fillFileStorageCache() async {
    var firstTime = fileStorage.head.isEmpty;

    var startTime = DateTime.now();
    await fileStorage.fill();
    var endTime = DateTime.now().difference(startTime);

    if (firstTime) Log.i("Built Git Time Cache - $endTime");

    await fileStorageCache.save(fileStorage);
    assert(fileStorageCache.lastProcessedHead == fileStorage.head);

    // Notify that the cache is ready
    fileStorageCacheReady = true;
    notifyListeners();
  }

  bool _shouldCheckForChanges() {
    if (Platform.isAndroid || Platform.isIOS) {
      return !storageConfig.storeInternally;
    }
    // Overwriting this for now, as I want the tests to pass
    return !storageConfig.storeInternally;
  }

  Future<void> syncNotes({bool doNotThrow = false}) async {
    // This is extremely slow with dart-git, can take over a second!
    if (_shouldCheckForChanges()) {
      try {
        var repo = await GitAsyncRepository.load(repoPath);
        await _commitUnTrackedChanges(repo, gitConfig);
      } catch (ex, st) {
        Log.e("SyncNotes Failed to Load Repo", ex: ex, stacktrace: st);
        return;
      }
    }

    if (!remoteGitRepoConfigured) {
      Log.d("Not syncing because RemoteRepo not configured");
      await _loadNotes();
      return;
    }

    logEvent(Event.RepoSynced);
    var attempt = SyncAttempt();
    attempt.add(SyncStatus.Pulling);
    syncAttempts.insert(0, attempt);
    notifyListeners();

    Future<void>? noteLoadingFuture;
    try {
      await _networkLock.synchronized(() async {
        await _gitRepo.fetch();
      });

      attempt.add(SyncStatus.Merging);

      await _gitOpLock.synchronized(() async {
        try {
          await _gitRepo.merge();
        } catch (ex) {
          // When there is nothing to merge into
          if (ex is! GitRefNotFound) {
            rethrow;
            // FIXME: Do not throw this exception, try to solve it somehow!!
          }
        }
      });

      attempt.add(SyncStatus.Pushing);
      notifyListeners();

      noteLoadingFuture = _loadNotes();

      await _networkLock.synchronized(() async {
        await _gitRepo.push();
      });

      Log.d("Synced!");
      attempt.add(SyncStatus.Done);
      numChanges = 0;
      notifyListeners();
    } catch (e, stacktrace) {
      Log.e("Failed to Sync", ex: e, stacktrace: stacktrace);

      var ex = e;
      if (ex is! Exception) {
        ex = Exception(e.toString());
      }
      attempt.add(SyncStatus.Error, ex);

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
      await _loadNotes();
      return;
    }
    return syncNotes(doNotThrow: true);
  }

  Future<void> createFolder(NotesFolderFS parent, String folderName) async {
    logEvent(Event.FolderAdded);

    await _gitOpLock.synchronized(() async {
      var newFolderPath = p.join(parent.folderPath, folderName);
      var newFolder = NotesFolderFS(parent, newFolderPath, folderConfig);
      newFolder.create();

      Log.d("Created New Folder: $newFolderPath");
      parent.addFolder(newFolder);

      await _gitRepo.addFolder(newFolder);

      numChanges += 1;
      notifyListeners();
    });

    unawaited(_syncNotes());
  }

  Future<void> removeFolder(NotesFolderFS folder) async {
    logEvent(Event.FolderDeleted);

    await _gitOpLock.synchronized(() async {
      Log.d("Got removeFolder lock");
      Log.d("Removing Folder: ${folder.folderPath}");

      folder.parentFS!.removeFolder(folder);
      await _gitRepo.removeFolder(folder);

      numChanges += 1;
      notifyListeners();
    });

    unawaited(_syncNotes());
  }

  Future<void> renameFolder(NotesFolderFS folder, String newFolderName) async {
    assert(!newFolderName.contains(p.separator));

    logEvent(Event.FolderRenamed);

    await _gitOpLock.synchronized(() async {
      var oldFolderPath = folder.folderPath;
      Log.d("Renaming Folder from $oldFolderPath -> $newFolderName");
      folder.rename(newFolderName);

      await _gitRepo.renameFolder(
        oldFolderPath,
        folder.folderPath,
      );

      numChanges += 1;
      notifyListeners();
    });

    unawaited(_syncNotes());
  }

  Future<Note> renameNote(Note fromNote, String newFileName) async {
    assert(!newFileName.contains(p.separator));
    assert(fromNote.oid.isNotEmpty);

    logEvent(Event.NoteRenamed);

    var toNote = fromNote.copyWithFileName(newFileName);
    if (io.File(toNote.fullFilePath).existsSync()) {
      throw Exception('Destination Note exists');
    }

    fromNote.parent.renameNote(fromNote, toNote);

    await _gitOpLock.synchronized(() async {
      await _gitRepo.renameNote(
        fromNote.filePath,
        toNote.filePath,
      );

      numChanges += 1;
      notifyListeners();
    });

    unawaited(_syncNotes());
    return toNote;
  }

  Future<Note> moveNote(Note note, NotesFolderFS destFolder) async {
    var newNotes = await moveNotes([note], destFolder);

    assert(newNotes.length == 1);
    return newNotes.first;
  }

  Future<List<Note>> moveNotes(
      List<Note> notes, NotesFolderFS destFolder) async {
    notes = notes
        .where((n) => n.parent.folderPath != destFolder.folderPath)
        .toList();

    if (notes.isEmpty) {
      throw Exception(
        "All selected notes are already in `${destFolder.folderPath}`",
      );
    }

    var newNotes = <Note>[];

    logEvent(Event.NoteMoved);
    await _gitOpLock.synchronized(() async {
      Log.d("Got moveNote lock");

      var oldPaths = <String>[];
      var newPaths = <String>[];
      for (var note in notes) {
        var newNote = NotesFolderFS.moveNote(note, destFolder);
        oldPaths.add(note.filePath);
        newPaths.add(newNote.filePath);

        newNotes.add(newNote);
      }

      await _gitRepo.moveNotes(oldPaths, newPaths);

      numChanges += 1;
      notifyListeners();
    });

    unawaited(_syncNotes());
    return newNotes;
  }

  Future<Note> saveNoteToDisk(Note note) async {
    assert(note.oid.isEmpty);
    return NoteStorage.save(note);
  }

  Future<Note> addNote(Note note) async {
    assert(note.oid.isEmpty);
    logEvent(Event.NoteAdded);

    note = note.updateModified();
    note = await NoteStorage.save(note);
    note.parent.add(note);

    await _gitOpLock.synchronized(() async {
      Log.d("Got addNote lock");

      await _gitRepo.addNote(note);

      numChanges += 1;
      notifyListeners();
    });

    unawaited(_syncNotes());
    return note;
  }

  void removeNote(Note note) => removeNotes([note]);

  Future<void> removeNotes(List<Note> notes) async {
    logEvent(Event.NoteDeleted);

    await _gitOpLock.synchronized(() async {
      Log.d("Got removeNote lock");

      // FIXME: What if the Note hasn't yet been saved?
      for (var note in notes) {
        note.parent.remove(note);
      }
      await _gitRepo.removeNotes(notes);

      numChanges += 1;
      notifyListeners();

      // FIXME: Is there a way of figuring this amount dynamically?
      // The '4 seconds' is taken from snack_bar.dart -> _kSnackBarDisplayDuration
      // We wait an aritfical amount of time, so that the user has a chance to undo
      // their delete operation, and that commit is not synced with the server, till then.
      await Future.delayed(4.seconds);
    });

    unawaited(_syncNotes());
  }

  Future<void> undoRemoveNote(Note note) async {
    logEvent(Event.NoteUndoDeleted);

    await _gitOpLock.synchronized(() async {
      Log.d("Got undoRemoveNote lock");

      note.parent.add(note);
      await _gitRepo.resetLastCommit();

      numChanges -= 1;
      notifyListeners();
    });

    unawaited(_syncNotes());
  }

  Future<Note> updateNote(Note oldNote, Note newNote) async {
    assert(oldNote.oid.isNotEmpty);
    assert(newNote.oid.isEmpty);

    logEvent(Event.NoteUpdated);

    assert(oldNote.filePath == newNote.filePath);
    assert(oldNote.parent == newNote.parent);

    newNote = newNote.updateModified();

    try {
      newNote = await NoteStorage.save(newNote);
    } catch (ex, st) {
      Log.e("Note saving failed", ex: ex, stacktrace: st);
      rethrow;
    }
    newNote.parent.updateNote(newNote);

    await _gitOpLock.synchronized(() async {
      Log.d("Got updateNote lock");

      await _gitRepo.updateNote(newNote);

      numChanges += 1;
      notifyListeners();
    });

    unawaited(_syncNotes());
    return newNote;
  }

  Future<void> completeGitHostSetup(
      String repoFolderName, String remoteName) async {
    storageConfig.folderName = repoFolderName;
    storageConfig.save();
    await _persistConfig();

    var newRepoPath = p.join(gitBaseDirectory, repoFolderName);
    await _ensureOneCommitInRepo(repoPath: newRepoPath, config: gitConfig);

    if (newRepoPath != repoPath) {
      Log.i("Old Path: $repoPath");
      Log.i("New Path: $newRepoPath");

      repoManager.buildActiveRepository();
      return;
    }

    Log.i("repoPath: $repoPath");

    remoteGitRepoConfigured = true;
    fileStorageCacheReady = false;

    _loadNotes();
    _syncNotes();

    notifyListeners();
  }

  Future<void> _persistConfig() async {
    await storageConfig.save();
    await folderConfig.save();
    await gitConfig.save();
    await settings.save();
  }

  Future<void> moveRepoToPath() async {
    var newRepoPath = await storageConfig.buildRepoPath(gitBaseDirectory);

    if (newRepoPath != repoPath) {
      Log.i("Old Path: $repoPath");
      Log.i("New Path: $newRepoPath");

      await io.Directory(newRepoPath).create(recursive: true);
      await _copyDirectory(repoPath, newRepoPath);
      await io.Directory(repoPath).delete(recursive: true);

      repoManager.buildActiveRepository();
    }
  }

  Future<void> discardChanges(Note note) async {
    // FIXME: Add the checkout method to GJRepo
    var gitRepo = await GitAsyncRepository.load(repoPath);
    await gitRepo.checkout(note.filePath);

    // FIXME: Instead of this just reload that specific file
    // FIXME: I don't think this will work!
    await reloadNotes();
  }

  Future<List<GitRemoteConfig>> remoteConfigs() async {
    var repo = await GitAsyncRepository.load(repoPath);
    var config = repo.config.remotes;
    return config;
  }

  Future<List<String>> branches() async {
    var repo = await GitAsyncRepository.load(repoPath);
    var branches = Set<String>.from(await repo.branches());
    if (repo.config.remotes.isNotEmpty) {
      var remoteName = repo.config.remotes.first.name;
      var remoteBranches = await repo.remoteBranches(remoteName);
      branches.addAll(remoteBranches.map((e) {
        return e.name.branchName()!;
      }));
    }
    return branches.toList()..sort();
  }

  String? get currentBranch => _currentBranch;

  Future<String> checkoutBranch(String branchName) async {
    Log.i("Changing branch to $branchName");
    var repo = await GitAsyncRepository.load(repoPath);

    try {
      var created = await createBranchIfRequired(repo, branchName);
      if (created.isEmpty) {
        return "";
      }
    } catch (ex, st) {
      Log.e("createBranch", ex: ex, stacktrace: st);
    }

    try {
      await repo.checkoutBranch(branchName);
      _currentBranch = branchName;
      Log.i("Done checking out $branchName");

      await _notesCache.clear();
      notifyListeners();

      _loadNotes();
    } catch (e, st) {
      Log.e("Checkout Branch Failed", ex: e, stacktrace: st);
    }

    return branchName;
  }

  // FIXME: Why does this need to return a string?
  /// throws exceptions
  Future<String> createBranchIfRequired(
      GitAsyncRepository repo, String name) async {
    var localBranches = await repo.branches();
    if (localBranches.contains(name)) {
      return name;
    }

    if (repo.config.remotes.isEmpty) {
      return "";
    }
    var remoteConfig = repo.config.remotes.first;
    var remoteBranches = await repo.remoteBranches(remoteConfig.name);
    var remoteBranchRef = remoteBranches.firstWhereOrNull(
      (ref) => ref.name.branchName() == name,
    );
    if (remoteBranchRef == null || remoteBranchRef is! HashReference) {
      return "";
    }

    await repo.createBranch(name, hash: remoteBranchRef.hash);
    await repo.setBranchUpstreamTo(name, remoteConfig, name);

    Log.i("Created branch $name");
    return name;
  }

  Future<void> delete() async {
    await io.Directory(repoPath).delete(recursive: true);
    await io.Directory(cacheDir).delete(recursive: true);
  }

  /// reset --hard the current branch to its remote branch
  Future<void> resetHard() async {
    var repo = await GitAsyncRepository.load(_gitRepo.gitRepoPath);
    var branchName = await repo.currentBranch();
    var branchConfig = repo.config.branch(branchName);
    if (branchConfig == null) {
      throw Exception("Branch config for '$branchName' not found");
    }

    var remoteName = branchConfig.remote;
    if (remoteName == null) {
      throw Exception("Branch config for '$branchName' misdsing remote");
    }
    var remoteBranch = await repo.remoteBranch(remoteName, branchName);
    await repo.resetHard(remoteBranch.hash);

    numChanges = 0;
    notifyListeners();

    _loadNotes();
  }

  Future<bool> canResetHard() async {
    var repo = await GitAsyncRepository.load(_gitRepo.gitRepoPath);
    var branchName = await repo.currentBranch();
    var branchConfig = repo.config.branch(branchName);
    if (branchConfig == null) {
      throw Exception("Branch config for '$branchName' not found");
    }

    var remoteName = branchConfig.remote;
    if (remoteName == null) {
      throw Exception("Branch config for '$branchName' misdsing remote");
    }
    var remoteBranch = await repo.remoteBranch(remoteName, branchName);
    var headHash = await repo.headHash();
    return remoteBranch.hash != headHash;
  }

  Future<void> removeRemote(String remoteName) async {
    var repo = GitRepository.load(repoPath);
    if (repo.config.remote(remoteName) != null) {
      try {
        repo.removeRemote(remoteName);
      } catch (ex, st) {
        Log.e("removeRemote", ex: ex, stacktrace: st);
      } finally {
        repo.close();
      }
    }
  }

  Future<void> ensureValidRepo() async {
    if (!GitRepository.isValidRepo(repoPath)) {
      GitRepository.init(repoPath, defaultBranch: DEFAULT_BRANCH);
    }
  }

  bool fileExists(String path) {
    var type = io.FileSystemEntity.typeSync(path);
    return type != io.FileSystemEntityType.notFound;
  }

  Future<void> init(String repoPath) async {
    return GitRepository.init(repoPath, defaultBranch: DEFAULT_BRANCH);
  }

  Future<void> exportRepo() async {
    // 1. Create a temporary folder
    var dir = await io.Directory.systemTemp.createTemp();
    var repoName = repoManager.repoFolderName(id);
    var exportPath = p.join(dir.path, "$repoName.zip");

    // 2. Create a zip file in that folder
    await _gitOpLock.synchronized(() async {
      var encoder = ZipFileEncoder();
      await encoder.zipDirectoryAsync(
        io.Directory(repoPath),
        filename: exportPath,
      );
    });

    // 3. Share the zip file
    await Share.shareXFiles([XFile(exportPath, name: "$repoName.zip")]);
    await dir.delete(recursive: true);
  }
}

Future<void> _copyDirectory(String source, String destination) async {
  await for (var entity in io.Directory(source).list(recursive: false)) {
    if (entity is io.Directory) {
      var newDirectory = io.Directory(p.join(
          io.Directory(destination).absolute.path, p.basename(entity.path)));
      await newDirectory.create();
      await _copyDirectory(entity.absolute.path, newDirectory.path);
    } else if (entity is io.File) {
      await entity.copy(p.join(destination, p.basename(entity.path)));
    }
  }
}

/// Add a GitIgnore file if no file is present. This way we always at least have
/// one commit. It makes doing a git pull and push easier
Future<void> _ensureOneCommitInRepo({
  required String repoPath,
  required GitConfig config,
}) async {
  try {
    var dirList = await io.Directory(repoPath).list().toList();
    var anyFileInRepo = dirList.firstWhereOrNull(
      (fs) => fs.statSync().type == io.FileSystemEntityType.file,
    );
    if (anyFileInRepo == null) {
      Log.i("Adding .ignore file");
      var ignoreFile = io.File(p.join(repoPath, ".gitignore"));
      ignoreFile.createSync();

      var repo = await GitAsyncRepository.load(repoPath);
      await repo.add(".gitignore");
      await repo.commit(
        message: "Add gitignore file",
        author: GitAuthor(
          name: config.gitAuthor,
          email: config.gitAuthorEmail,
        ),
      );
    }
  } catch (ex, st) {
    Log.e("_ensureOneCommitInRepo", ex: ex, stacktrace: st);
  }
}

Future<void> _commitUnTrackedChanges(
    GitAsyncRepository repo, GitConfig gitConfig) async {
  var timer = Stopwatch()..start();
  //
  // Check for un-committed files and save them
  //
  await repo.add('.');

  try {
    await repo.commit(
      message: CommitMessageBuilder().autoCommit(),
      author: GitAuthor(
        name: gitConfig.gitAuthor,
        email: gitConfig.gitAuthorEmail,
      ),
    );
  } catch (ex) {
    if (ex is! GitEmptyCommit) rethrow;
  }

  Log.i('_commitUntracked: ${timer.elapsed}');
}
