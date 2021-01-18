import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:dart_git/git.dart' as git;
import 'package:git_bindings/git_bindings.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils/logger.dart';

class NoteRepoResult {
  bool error;
  String noteFilePath;

  NoteRepoResult({
    @required this.error,
    this.noteFilePath,
  });
}

class GitNoteRepository {
  final String gitDirPath;
  final GitRepo _gitRepo;
  final Settings settings;

  GitNoteRepository({
    @required this.gitDirPath,
    @required this.settings,
  }) : _gitRepo = GitRepo(folderPath: gitDirPath);

  Future<NoteRepoResult> addNote(Note note) async {
    return _addNote(note, "Added Note");
  }

  Future<NoteRepoResult> _addNote(Note note, String commitMessage) async {
    await _gitRepo.add(".");
    await _gitRepo.commit(
      message: commitMessage,
      authorEmail: settings.gitAuthorEmail,
      authorName: settings.gitAuthor,
    );

    return NoteRepoResult(noteFilePath: note.filePath, error: false);
  }

  Future<NoteRepoResult> addFolder(NotesFolderFS folder) async {
    await _gitRepo.add(".");
    await _gitRepo.commit(
      message: "Created New Folder",
      authorEmail: settings.gitAuthorEmail,
      authorName: settings.gitAuthor,
    );

    return NoteRepoResult(noteFilePath: folder.folderPath, error: false);
  }

  Future<NoteRepoResult> addFolderConfig(NotesFolderConfig config) async {
    var pathSpec = config.folder.pathSpec();
    pathSpec = pathSpec.isNotEmpty ? pathSpec : '/';

    await _gitRepo.add(".");
    await _gitRepo.commit(
      message: "Update folder config for $pathSpec",
      authorEmail: settings.gitAuthorEmail,
      authorName: settings.gitAuthor,
    );

    return NoteRepoResult(noteFilePath: config.folder.folderPath, error: false);
  }

  Future<NoteRepoResult> renameFolder(
    String oldFullPath,
    String newFullPath,
  ) async {
    // FIXME: This is a hacky way of adding the changes, ideally we should be calling rm + add or something
    await _gitRepo.add(".");
    await _gitRepo.commit(
      message: "Renamed Folder",
      authorEmail: settings.gitAuthorEmail,
      authorName: settings.gitAuthor,
    );

    return NoteRepoResult(noteFilePath: newFullPath, error: false);
  }

  Future<NoteRepoResult> renameNote(
    String oldFullPath,
    String newFullPath,
  ) async {
    // FIXME: This is a hacky way of adding the changes, ideally we should be calling rm + add or something
    await _gitRepo.add(".");
    await _gitRepo.commit(
      message: "Renamed Note",
      authorEmail: settings.gitAuthorEmail,
      authorName: settings.gitAuthor,
    );

    return NoteRepoResult(noteFilePath: newFullPath, error: false);
  }

  Future<NoteRepoResult> renameFile(
    String oldFullPath,
    String newFullPath,
  ) async {
    // FIXME: This is a hacky way of adding the changes, ideally we should be calling rm + add or something
    await _gitRepo.add(".");
    await _gitRepo.commit(
      message: "Renamed File",
      authorEmail: settings.gitAuthorEmail,
      authorName: settings.gitAuthor,
    );

    return NoteRepoResult(noteFilePath: newFullPath, error: false);
  }

  Future<NoteRepoResult> moveNote(
    String oldFullPath,
    String newFullPath,
  ) async {
    // FIXME: This is a hacky way of adding the changes, ideally we should be calling rm + add or something
    await _gitRepo.add(".");
    await _gitRepo.commit(
      message: "Note Moved",
      authorEmail: settings.gitAuthorEmail,
      authorName: settings.gitAuthor,
    );

    return NoteRepoResult(noteFilePath: newFullPath, error: false);
  }

  Future<NoteRepoResult> removeNote(Note note) async {
    // We are not calling note.remove() as gitRm will also remove the file
    var spec = note.pathSpec();
    await _gitRepo.rm(spec);
    await _gitRepo.commit(
      message: "Removed Note " + spec,
      authorEmail: settings.gitAuthorEmail,
      authorName: settings.gitAuthor,
    );

    return NoteRepoResult(noteFilePath: note.filePath, error: false);
  }

  Future<NoteRepoResult> removeFolder(NotesFolderFS folder) async {
    var spec = folder.pathSpec();
    await _gitRepo.rm(spec);
    await _gitRepo.commit(
      message: "Removed Folder " + spec,
      authorEmail: settings.gitAuthorEmail,
      authorName: settings.gitAuthor,
    );

    await Directory(folder.folderPath).delete(recursive: true);

    return NoteRepoResult(noteFilePath: folder.folderPath, error: false);
  }

  Future<NoteRepoResult> resetLastCommit() async {
    await _gitRepo.resetLast();
    return NoteRepoResult(error: false);
  }

  Future<NoteRepoResult> updateNote(Note note) async {
    return _addNote(note, "Edited Note");
  }

  Future<void> fetch() async {
    try {
      await _gitRepo.fetch(
        remote: "origin",
        publicKey: settings.sshPublicKey,
        privateKey: settings.sshPrivateKey,
        password: settings.sshPassword,
      );
    } on GitException catch (ex, stackTrace) {
      Log.e("GitPull Failed", ex: ex, stacktrace: stackTrace);
    }
  }

  Future<void> merge() async {
    var repo = await git.GitRepository.load(gitDirPath);
    var branch = await repo.currentBranch();
    var branchConfig = repo.config.branch(branch);
    if (branchConfig == null) {
      logExceptionWarning(Exception("Current Branch null"), StackTrace.current);
      return;
    }

    assert(branchConfig.name != null);
    assert(branchConfig.merge != null);

    var remoteRef = await repo.remoteBranch(
      branchConfig.remote,
      branchConfig.trackingBranch(),
    );
    if (remoteRef == null) {
      Log.i('Remote has no refs');
      return;
    }

    try {
      await _gitRepo.merge(
        branch: branchConfig.remoteTrackingBranch(),
        authorEmail: settings.gitAuthorEmail,
        authorName: settings.gitAuthor,
      );
    } on GitException catch (ex, stackTrace) {
      Log.e("Git Merge Failed", ex: ex, stacktrace: stackTrace);
    }
  }

  Future<void> push() async {
    // Only push if we have something we need to push
    try {
      var repo = await git.GitRepository.load(gitDirPath);
      if ((await repo.canPush()) == false) {
        return;
      }
    } catch (_) {}

    try {
      await _gitRepo.push(
        remote: "origin",
        publicKey: settings.sshPublicKey,
        privateKey: settings.sshPrivateKey,
        password: settings.sshPassword,
      );
    } on GitException catch (ex, stackTrace) {
      if (ex.cause == 'cannot push non-fastforwardable reference') {
        await fetch();
        await merge();
        return push();
      }
      Log.e("GitPush Failed", ex: ex, stacktrace: stackTrace);
      rethrow;
    }
  }

  Future<String> defaultBranch(String remoteName) async {
    try {
      return await _gitRepo.defaultBranch(
        remote: remoteName,
        publicKey: settings.sshPublicKey,
        privateKey: settings.sshPrivateKey,
        password: settings.sshPassword,
      );
    } on GitException catch (ex, stackTrace) {
      Log.e("GitDefaultBranch Failed", ex: ex, stacktrace: stackTrace);
      rethrow;
    }
  }

  Future<int> numChanges() async {
    try {
      var repo = await git.GitRepository.load(gitDirPath);
      var n = await repo.numChangesToPush();
      return n;
    } catch (_) {}
    return 0;
  }
}

const ignoredMessages = [
  'connection timed out',
  'failed to resolve address for',
  'failed to connect to',
  'no address associated with hostname',
  'unauthorized',
  'invalid credentials',
  'failed to start ssh session',
  'failure while draining',
  'network is unreachable',
  'software caused connection abort',
  'unable to exchange encryption keys',
  'the key you are authenticating with has been marked as read only',
  'transport read',
  "unpacking the sent packfile failed on the remote",
  "key permission denied", // gogs
  "failed getting response",
];

bool shouldLogGitException(Exception ex) {
  if (ex is! GitException) {
    return false;
  }
  var msg = (ex as GitException).cause.toLowerCase();
  for (var i = 0; i < ignoredMessages.length; i++) {
    if (msg.contains(ignoredMessages[i])) {
      return false;
    }
  }
  return true;
}
