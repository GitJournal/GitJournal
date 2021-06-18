import 'dart:async';
import 'dart:io' show Platform;

import 'package:dart_git/dart_git.dart';
import 'package:dart_git/utils/result.dart';
import 'package:git_bindings/git_bindings.dart' as gb;

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/utils/logger.dart';

bool useDartGit = false;

class GitNoteRepository {
  final String gitDirPath;
  final gb.GitRepo _gitRepo;
  final Settings settings;

  GitNoteRepository({
    required this.gitDirPath,
    required this.settings,
  }) : _gitRepo = gb.GitRepo(folderPath: gitDirPath) {
    // git-bindings aren't properly implemented in these platforms
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      useDartGit = true;
    }
  }

  Future<Result<void>> _add(String pathSpec) async {
    if (useDartGit) {
      var repo = await GitRepository.load(gitDirPath).getOrThrow();
      return await repo.add(pathSpec);
    } else {
      try {
        await _gitRepo.add(pathSpec);
      } on Exception catch (ex, st) {
        return Result.fail(ex, st);
      }
    }

    return Result(null);
  }

  Future<Result<void>> _rm(String pathSpec) async {
    if (useDartGit) {
      var repo = await GitRepository.load(gitDirPath).getOrThrow();
      return await repo.rm(pathSpec);
    } else {
      try {
        await _gitRepo.rm(pathSpec);
      } on Exception catch (ex, st) {
        return Result.fail(ex, st);
      }
    }

    return Result(null);
  }

  Future<Result<void>> _commit({
    required String message,
    required String authorEmail,
    required String authorName,
  }) async {
    if (useDartGit) {
      var repo = await GitRepository.load(gitDirPath).getOrThrow();
      var author = GitAuthor(name: authorName, email: authorEmail);
      var r = await repo.commit(message: message, author: author);
      if (r.isFailure) {
        return fail(r);
      }
    } else {
      try {
        await _gitRepo.commit(
          message: message,
          authorEmail: settings.gitAuthorEmail,
          authorName: settings.gitAuthor,
        );
      } on Exception catch (ex, st) {
        return Result.fail(ex, st);
      }
    }

    return Result(null);
  }

  // FIXME: Is this actually used?
  Future<Result<void>> addNote(Note note) async {
    return _addAllAndCommit("Added Note");
  }

  Future<Result<void>> _addAllAndCommit(String commitMessage) async {
    var r = await _add(".");
    if (r.isFailure) {
      return fail(r);
    }

    var res = await _commit(
      message: commitMessage,
      authorEmail: settings.gitAuthorEmail,
      authorName: settings.gitAuthor,
    );
    if (res.isFailure) {
      return fail(r);
    }

    return Result(null);
  }

  Future<Result<void>> addFolder(NotesFolderFS folder) async {
    return _addAllAndCommit("Created New Folder");
  }

  Future<Result<void>> addFolderConfig(NotesFolderConfig config) async {
    var pathSpec = config.folder!.pathSpec();
    pathSpec = pathSpec.isNotEmpty ? pathSpec : '/';

    return _addAllAndCommit("Update folder config for $pathSpec");
  }

  Future<Result<void>> renameFolder(
    String oldFullPath,
    String newFullPath,
  ) async {
    // FIXME: This is a hacky way of adding the changes, ideally we should be calling rm + add or something
    return _addAllAndCommit("Renamed Folder");
  }

  Future<Result<void>> renameNote(
    String oldFullPath,
    String newFullPath,
  ) async {
    return _addAllAndCommit("Renamed Note");
  }

  Future<Result<void>> renameFile(
    String oldFullPath,
    String newFullPath,
  ) async {
    return _addAllAndCommit("Renamed File");
  }

  Future<Result<void>> moveNote(
    String oldFullPath,
    String newFullPath,
  ) async {
    return _addAllAndCommit("Note Moved");
  }

  Future<Result<void>> removeNote(Note note) async {
    return catchAll(() async {
      // We are not calling note.remove() as gitRm will also remove the file
      var spec = note.pathSpec();
      await _rm(spec).throwOnError();
      await _commit(
        message: "Removed Note " + spec,
        authorEmail: settings.gitAuthorEmail,
        authorName: settings.gitAuthor,
      ).throwOnError();

      return Result(null);
    });
  }

  Future<Result<void>> removeFolder(NotesFolderFS folder) async {
    return catchAll(() async {
      var spec = folder.pathSpec();
      await _rm(spec).throwOnError();
      await _commit(
        message: "Removed Folder " + spec,
        authorEmail: settings.gitAuthorEmail,
        authorName: settings.gitAuthor,
      ).throwOnError();

      return Result(null);
    });
  }

  Future<Result<void>> resetLastCommit() async {
    try {
      await _gitRepo.resetLast();
    } on Exception catch (e, st) {
      return Result.fail(e, st);
    }
    return Result(null);
  }

  Future<Result<void>> updateNote(Note note) async {
    return _addAllAndCommit("Edited Note");
  }

  Future<Result<void>> fetch() async {
    try {
      await _gitRepo.fetch(
        remote: "origin",
        publicKey: settings.sshPublicKey,
        privateKey: settings.sshPrivateKey,
        password: settings.sshPassword,
      );
    } on gb.GitException catch (ex, stackTrace) {
      Log.e("GitPull Failed", ex: ex, stacktrace: stackTrace);
      return Result.fail(ex, stackTrace);
    } on Exception catch (ex, stackTrace) {
      return Result.fail(ex, stackTrace);
    }

    return Result(null);
  }

  // FIXME: Convert to Result!
  Future<void> merge() async {
    var repo = await GitRepository.load(gitDirPath).getOrThrow();
    var branch = await repo.currentBranch().getOrThrow();

    var branchConfig = repo.config.branch(branch);
    if (branchConfig == null) {
      logExceptionWarning(
          Exception("Branch '$branch' not in config"), StackTrace.current);
      return;
    }

    var result = await repo.remoteBranch(
      branchConfig.remote!,
      branchConfig.trackingBranch()!,
    );
    if (result.isFailure) {
      Log.e("Failed to get remote refs",
          ex: result.error, stacktrace: result.stackTrace);
    }

    try {
      await _gitRepo.merge(
        branch: branchConfig.remoteTrackingBranch(),
        authorEmail: settings.gitAuthorEmail,
        authorName: settings.gitAuthor,
      );
    } on gb.GitException catch (ex, stackTrace) {
      Log.e("Git Merge Failed", ex: ex, stacktrace: stackTrace);
    }
  }

  Future<void> push() async {
    // Only push if we have something we need to push
    try {
      var repo = await GitRepository.load(gitDirPath).getOrThrow();
      var canPush = await repo.canPush().getOrThrow();
      if (!canPush) {
        return;
      }
    } catch (ex, st) {
      Log.e("Can Push", ex: ex, stacktrace: st);
    }

    try {
      await _gitRepo.push(
        remote: "origin",
        publicKey: settings.sshPublicKey,
        privateKey: settings.sshPrivateKey,
        password: settings.sshPassword,
      );
    } on gb.GitException catch (ex, stackTrace) {
      if (ex.cause == 'cannot push non-fastforwardable reference') {
        await fetch();
        await merge();
        return push();
      }
      Log.e("GitPush Failed", ex: ex, stacktrace: stackTrace);
      rethrow;
    }
  }

  Future<int?> numChanges() async {
    try {
      var repo = await GitRepository.load(gitDirPath).getOrThrow();
      var n = await repo.numChangesToPush().getOrThrow();
      return n;
    } catch (ex, st) {
      Log.e("numChanges", ex: ex, stacktrace: st);
    }
    return null;
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
  if (ex is! gb.GitException) {
    return false;
  }
  var msg = ex.cause.toLowerCase();
  for (var i = 0; i < ignoredMessages.length; i++) {
    if (msg.contains(ignoredMessages[i])) {
      return false;
    }
  }
  return true;
}
