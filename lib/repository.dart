/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:dart_git/config.dart';
import 'package:dart_git/dart_git.dart';
import 'package:dart_git/exceptions.dart';
import 'package:dart_git/plumbing/git_hash.dart';
import 'package:git_bindings/git_bindings.dart';
import 'package:path/path.dart' as p;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';
import 'package:time/time.dart';
import 'package:universal_io/io.dart' as io;
import 'package:universal_io/io.dart' show Platform;

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

  static Future<Result<GitJournalRepo>> load({
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
      var r = GitRepository.init(repoPath, defaultBranch: DEFAULT_BRANCH);
      if (r.isFailure) {
        Log.e("GitInit Failed", result: r);
        return fail(r);
      }

      storageConfig.save();
    }

    var valid = GitRepository.isValidRepo(repoPath);
    if (!valid) {
      // What happened that the directory still exists but the .git folder
      // has disappeared?
      // FIXME: What if the '.config' file is not accessible?
      // -> https://sentry.io/share/issue/bafc5c417bdb4fd196cead1d28432f12/
      var ex = Exception('Folder is no longer a valid Git Repo');
      return Result.fail(ex);
    }

    var repoR = await GitAsyncRepository.load(repoPath);
    if (repoR.isFailure) {
      return fail(repoR);
    }
    var repo = repoR.getOrThrow();
    var remoteConfigured = repo.config.remotes.isNotEmpty;

    if (!storageConfig.storeInternally) {
      var r = await _commitUnTrackedChanges(repo, gitConfig);
      if (r.isFailure) {
        return fail(r);
      }
    }

    var _ = await io.Directory(cacheDir).create(recursive: true);

    var fileStorageCache = FileStorageCache(cacheDir);
    var fileStorage = await fileStorageCache.load(repoPath);

    var headR = await repo.headHash();
    var head = headR.isFailure ? GitHash.zero() : headR.getOrThrow();

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
      currentBranch: await repo.currentBranch().getOrThrow(),
      headHash: head,
      loadFromCache: loadFromCache,
      syncOnBoot: syncOnBoot,
    );

    return Result(gjRepo);
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
    var _ = repoManager.buildActiveRepository();
  }

  Future<void> reloadNotes() => _loadNotes();

  Future<void> _loadNotes() async {
    await _fillFileStorageCache();

    // FIXME: We should report the notes that failed to load
    return _loadLock.synchronized(() async {
      var r = await rootFolder.loadRecursively();
      if (r.isFailure) {
        if (r.error is FileStorageCacheIncomplete) {
          var ex = r.error as FileStorageCacheIncomplete;
          Log.i("FileStorageCacheIncomplete ${ex.path}");
          var repo = await GitAsyncRepository.load(repoPath).getOrThrow();
          await _commitUnTrackedChanges(repo, gitConfig).throwOnError();
          await _resetFileStorage();
          return;
        }
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

    var r = await fileStorageCache.save(fileStorage);
    if (r.isFailure) {
      Log.e("Failed to save FileStorageCache", result: r);
      logException(r.exception!, r.stackTrace!);
    }

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
      var repoR = await GitAsyncRepository.load(repoPath);
      if (repoR.isFailure) {
        Log.e("SyncNotes Failed to Load Repo", result: repoR);
        return;
      }
      var repo = repoR.getOrThrow();
      await _commitUnTrackedChanges(repo, gitConfig).throwOnError();
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
        await _gitRepo.fetch().throwOnError();
      });

      attempt.add(SyncStatus.Merging);

      await _gitOpLock.synchronized(() async {
        var r = await _gitRepo.merge();
        if (r.isFailure) {
          var ex = r.error!;
          // When there is nothing to merge into
          if (ex is! GitRefNotFound) {
            throw ex;
            // FIXME: Do not throw this exception, try to solve it somehow!!
          }
        }
      });

      attempt.add(SyncStatus.Pushing);
      notifyListeners();

      noteLoadingFuture = _loadNotes();

      await _networkLock.synchronized(() async {
        await _gitRepo.push().throwOnError();
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

  Future<Result<void>> createFolder(
      NotesFolderFS parent, String folderName) async {
    logEvent(Event.FolderAdded);

    var r = await _gitOpLock.synchronized(() async {
      var newFolderPath = p.join(parent.folderPath, folderName);
      var newFolder = NotesFolderFS(parent, newFolderPath, folderConfig);
      var r = newFolder.create();
      if (r.isFailure) {
        Log.e("createFolder", result: r);
        return fail(r);
      }

      Log.d("Created New Folder: " + newFolderPath);
      parent.addFolder(newFolder);

      var result = await _gitRepo.addFolder(newFolder);
      if (result.isFailure) {
        Log.e("createFolder", result: result);
        return fail(result);
      }

      numChanges += 1;
      notifyListeners();
      return Result(null);
    });
    if (r.isFailure) return fail(r);

    unawaited(_syncNotes());
    return Result(null);
  }

  Future<void> removeFolder(NotesFolderFS folder) async {
    logEvent(Event.FolderDeleted);

    await _gitOpLock.synchronized(() async {
      Log.d("Got removeFolder lock");
      Log.d("Removing Folder: " + folder.folderPath);

      folder.parentFS!.removeFolder(folder);
      var result = await _gitRepo.removeFolder(folder);
      if (result.isFailure) {
        Log.e("removeFolder", result: result);
        return;
      }

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

      var result = await _gitRepo.renameFolder(
        oldFolderPath,
        folder.folderPath,
      );
      if (result.isFailure) {
        Log.e("renameFolder", result: result);
        return;
      }

      numChanges += 1;
      notifyListeners();
    });

    unawaited(_syncNotes());
  }

  Future<Result<Note>> renameNote(Note fromNote, String newFileName) async {
    assert(!newFileName.contains(p.separator));
    assert(fromNote.oid.isNotEmpty);

    logEvent(Event.NoteRenamed);

    var toNote = fromNote.copyWithFileName(newFileName);
    if (io.File(toNote.fullFilePath).existsSync()) {
      var ex = Exception('Destination Note exists');
      return Result.fail(ex);
    }

    var renameR = fromNote.parent.renameNote(fromNote, toNote);
    if (renameR.isFailure) {
      return fail(renameR);
    }

    var _ = await _gitOpLock.synchronized(() async {
      var result = await _gitRepo.renameNote(
        fromNote.filePath,
        toNote.filePath,
      );
      if (result.isFailure) {
        Log.e("renameNote", result: result);
        return fail(result);
      }

      numChanges += 1;
      notifyListeners();
    });

    unawaited(_syncNotes());
    return Result(toNote);
  }

  Future<Result<Note>> moveNote(Note note, NotesFolderFS destFolder) async {
    var r = await moveNotes([note], destFolder);
    if (r.isFailure) return fail(r);

    var newNotes = r.getOrThrow();
    assert(newNotes.length == 1);
    return Result(newNotes.first);
  }

  Future<Result<List<Note>>> moveNotes(
      List<Note> notes, NotesFolderFS destFolder) async {
    notes = notes
        .where((n) => n.parent.folderPath != destFolder.folderPath)
        .toList();

    if (notes.isEmpty) {
      var ex = Exception(
        "All selected notes are already in `${destFolder.folderPath}`",
      );
      return Result.fail(ex);
    }

    var newNotes = <Note>[];

    logEvent(Event.NoteMoved);
    var r = await _gitOpLock.synchronized(() async {
      Log.d("Got moveNote lock");

      var oldPaths = <String>[];
      var newPaths = <String>[];
      for (var note in notes) {
        var result = NotesFolderFS.moveNote(note, destFolder);
        // FIXME: We need to validate that this wont cause any problems!
        //        Transaction needs to be reverted
        if (result.isFailure) {
          Log.e("moveNotes", result: result);
          return fail(result);
        }
        var newNote = result.getOrThrow();
        oldPaths.add(note.filePath);
        newPaths.add(newNote.filePath);

        newNotes.add(newNote);
      }

      var result = await _gitRepo.moveNotes(oldPaths, newPaths);
      if (result.isFailure) {
        Log.e("moveNotes", result: result);
        return fail(result);
      }

      numChanges += 1;
      notifyListeners();
      return Result(null);
    });
    if (r.isFailure) return fail(r);

    unawaited(_syncNotes());
    return Result(newNotes);
  }

  Future<Result<Note>> saveNoteToDisk(Note note) async {
    assert(note.oid.isEmpty);
    return NoteStorage.save(note);
  }

  Future<Result<Note>> addNote(Note note) async {
    assert(note.oid.isEmpty);
    logEvent(Event.NoteAdded);

    note = note.updateModified();

    var r = await NoteStorage.save(note);
    if (r.isFailure) {
      Log.e("Note saving failed", ex: r.error, stacktrace: r.stackTrace);
      return fail(r);
    }
    note = r.getOrThrow();

    note.parent.add(note);

    await _gitOpLock.synchronized(() async {
      Log.d("Got addNote lock");

      var result = await _gitRepo.addNote(note);
      if (result.isFailure) {
        Log.e("addNote", result: result);
        return;
      }

      numChanges += 1;
      notifyListeners();
    });

    unawaited(_syncNotes());
    return Result(note);
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
      var result = await _gitRepo.removeNotes(notes);
      if (result.isFailure) {
        Log.e("removeNotes", result: result);
        return;
      }

      numChanges += 1;
      notifyListeners();

      // FIXME: Is there a way of figuring this amount dynamically?
      // The '4 seconds' is taken from snack_bar.dart -> _kSnackBarDisplayDuration
      // We wait an aritfical amount of time, so that the user has a chance to undo
      // their delete operation, and that commit is not synced with the server, till then.
      var _ = await Future.delayed(4.seconds);
    });

    unawaited(_syncNotes());
  }

  Future<void> undoRemoveNote(Note note) async {
    logEvent(Event.NoteUndoDeleted);

    await _gitOpLock.synchronized(() async {
      Log.d("Got undoRemoveNote lock");

      note.parent.add(note);
      var result = await _gitRepo.resetLastCommit();
      if (result.isFailure) {
        Log.e("undoRemoveNote", result: result);
        return;
      }

      numChanges -= 1;
      notifyListeners();
    });

    unawaited(_syncNotes());
  }

  Future<Result<Note>> updateNote(Note oldNote, Note newNote) async {
    assert(oldNote.oid.isNotEmpty);
    assert(newNote.oid.isEmpty);

    logEvent(Event.NoteUpdated);

    assert(oldNote.filePath == newNote.filePath);
    assert(oldNote.parent == newNote.parent);

    newNote = newNote.updateModified();

    var r = await NoteStorage.save(newNote);
    if (r.isFailure) {
      Log.e("Note saving failed", ex: r.error, stacktrace: r.stackTrace);
      return fail(r);
    }
    newNote = r.getOrThrow();

    newNote.parent.updateNote(newNote);

    await _gitOpLock.synchronized(() async {
      Log.d("Got updateNote lock");

      var result = await _gitRepo.updateNote(newNote);
      if (result.isFailure) {
        Log.e("updateNote", result: result);
        return;
      }

      numChanges += 1;
      notifyListeners();
    });

    unawaited(_syncNotes());
    return Result(newNote);
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

      var _ = repoManager.buildActiveRepository();
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

      dynamic _;
      _ = await io.Directory(newRepoPath).create(recursive: true);
      await _copyDirectory(repoPath, newRepoPath);
      _ = await io.Directory(repoPath).delete(recursive: true);

      _ = repoManager.buildActiveRepository();
    }
  }

  Future<void> discardChanges(Note note) async {
    // FIXME: Add the checkout method to GJRepo
    var gitRepo = await GitAsyncRepository.load(repoPath).getOrThrow();
    await gitRepo.checkout(note.filePath).throwOnError();

    // FIXME: Instead of this just reload that specific file
    // FIXME: I don't think this will work!
    await reloadNotes();
  }

  Future<List<GitRemoteConfig>> remoteConfigs() async {
    var repo = await GitAsyncRepository.load(repoPath).getOrThrow();
    var config = repo.config.remotes;
    return config;
  }

  Future<List<String>> branches() async {
    var repo = await GitAsyncRepository.load(repoPath).getOrThrow();
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
    var repo = await GitAsyncRepository.load(repoPath).getOrThrow();

    try {
      var created = await createBranchIfRequired(repo, branchName);
      if (created.isEmpty) {
        return "";
      }
    } catch (ex, st) {
      Log.e("createBranch", ex: ex, stacktrace: st);
    }

    try {
      await repo.checkoutBranch(branchName).throwOnError();
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
    dynamic _;
    _ = await io.Directory(repoPath).delete(recursive: true);
    _ = await io.Directory(cacheDir).delete(recursive: true);
  }

  /// reset --hard the current branch to its remote branch
  Future<Result<void>> resetHard() {
    return catchAll(() async {
      var repo =
          await GitAsyncRepository.load(_gitRepo.gitRepoPath).getOrThrow();
      var branchName = await repo.currentBranch().getOrThrow();
      var branchConfig = repo.config.branch(branchName);
      if (branchConfig == null) {
        throw Exception("Branch config for '$branchName' not found");
      }

      var remoteName = branchConfig.remote;
      if (remoteName == null) {
        throw Exception("Branch config for '$branchName' misdsing remote");
      }
      var remoteBranch =
          await repo.remoteBranch(remoteName, branchName).getOrThrow();
      await repo.resetHard(remoteBranch.hash!).throwOnError();

      numChanges = 0;
      notifyListeners();

      _loadNotes();

      return Result(null);
    });
  }

  Future<Result<bool>> canResetHard() {
    return catchAll(() async {
      var repo =
          await GitAsyncRepository.load(_gitRepo.gitRepoPath).getOrThrow();
      var branchName = await repo.currentBranch().getOrThrow();
      var branchConfig = repo.config.branch(branchName);
      if (branchConfig == null) {
        throw Exception("Branch config for '$branchName' not found");
      }

      var remoteName = branchConfig.remote;
      if (remoteName == null) {
        throw Exception("Branch config for '$branchName' misdsing remote");
      }
      var remoteBranch =
          await repo.remoteBranch(remoteName, branchName).getOrThrow();
      var headHash = await repo.headHash().getOrThrow();
      return Result(remoteBranch.hash != headHash);
    });
  }

  Future<Result<void>> removeRemote(String remoteName) async {
    var repo = GitRepository.load(repoPath).getOrThrow();
    if (repo.config.remote(remoteName) != null) {
      var r = repo.removeRemote(remoteName);
      var _ = repo.close();
      if (r.isFailure) {
        return fail(r);
      }
    }

    return Result(null);
  }

  Future<Result<void>> ensureValidRepo() async {
    if (!GitRepository.isValidRepo(repoPath)) {
      var r = GitRepository.init(repoPath, defaultBranch: DEFAULT_BRANCH);
      if (r.isFailure) {
        return fail(r);
      }
    }

    return Result(null);
  }

  Result<bool> fileExists(String path) {
    return catchAllSync(() {
      var type = io.FileSystemEntity.typeSync(path);
      return Result(type != io.FileSystemEntityType.notFound);
    });
  }

  Future<Result<void>> init(String repoPath) async {
    return GitRepository.init(repoPath, defaultBranch: DEFAULT_BRANCH);
  }
}

Future<void> _copyDirectory(String source, String destination) async {
  await for (var entity in io.Directory(source).list(recursive: false)) {
    dynamic _;
    if (entity is io.Directory) {
      var newDirectory = io.Directory(p.join(
          io.Directory(destination).absolute.path, p.basename(entity.path)));
      _ = await newDirectory.create();
      await _copyDirectory(entity.absolute.path, newDirectory.path);
    } else if (entity is io.File) {
      _ = await entity.copy(p.join(destination, p.basename(entity.path)));
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

      var repo = GitRepo(folderPath: repoPath);
      await repo.add('.gitignore');

      await repo.commit(
        message: "Add gitignore file",
        authorEmail: config.gitAuthorEmail,
        authorName: config.gitAuthor,
      );
    }
  } catch (ex, st) {
    Log.e("_ensureOneCommitInRepo", ex: ex, stacktrace: st);
  }
}

Future<Result<void>> _commitUnTrackedChanges(
    GitAsyncRepository repo, GitConfig gitConfig) async {
  var timer = Stopwatch()..start();
  //
  // Check for un-committed files and save them
  //
  var addR = await repo.add('.');
  if (addR.isFailure) {
    return fail(addR);
  }

  var commitR = await repo.commit(
    message: CommitMessageBuilder().autoCommit(),
    author: GitAuthor(
      name: gitConfig.gitAuthor,
      email: gitConfig.gitAuthorEmail,
    ),
  );
  if (commitR.isFailure) {
    if (commitR.error is! GitEmptyCommit) {
      Log.i('_commitUntracked NoCommit: ${timer.elapsed}');
      return fail(commitR);
    }
  }

  Log.i('_commitUntracked: ${timer.elapsed}');
  return Result(null);
}
