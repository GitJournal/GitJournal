/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';

import 'package:dart_git/dart_git.dart';
import 'package:dart_git/utils/result.dart';
import 'package:git_bindings/git_bindings.dart' as gb;
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart' show Platform, Directory;

import 'package:gitjournal/core/commit_message_builder.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:gitjournal/settings/git_config.dart';
import 'package:gitjournal/utils/git_desktop.dart';

bool useDartGit = false;

class GitNoteRepository {
  final String gitRepoPath;
  final gb.GitRepo _gitRepo;
  final GitConfig config;
  final CommitMessageBuilder messageBuilder;

  GitNoteRepository({
    required this.gitRepoPath,
    required this.config,
  })  : _gitRepo = gb.GitRepo(folderPath: gitRepoPath),
        messageBuilder = CommitMessageBuilder() {
    // git-bindings aren't properly implemented in these platforms
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      useDartGit = true;
    }
  }

  Future<Result<void>> _add(String pathSpec) async {
    if (useDartGit || AppConfig.instance.experimentalGitOps) {
      var repo = await GitRepository.load(gitRepoPath).getOrThrow();
      await repo.add(pathSpec).throwOnError();
      return Result(null);
    } else {
      try {
        await _gitRepo.add(pathSpec);
      } catch (ex, st) {
        return Result.fail(ex, st);
      }
    }

    return Result(null);
  }

  Future<Result<void>> _rm(String pathSpec) async {
    if (useDartGit || AppConfig.instance.experimentalGitOps) {
      var repo = await GitRepository.load(gitRepoPath).getOrThrow();
      return await repo.rm(pathSpec);
    } else {
      try {
        await _gitRepo.rm(pathSpec);
      } catch (ex, st) {
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
    if (useDartGit || AppConfig.instance.experimentalGitOps) {
      var repo = await GitRepository.load(gitRepoPath).getOrThrow();
      var author = GitAuthor(name: authorName, email: authorEmail);
      var r = await repo.commit(message: message, author: author);
      if (r.isFailure) {
        return fail(r);
      }
    } else {
      try {
        await _gitRepo.commit(
          message: message,
          authorEmail: config.gitAuthorEmail,
          authorName: config.gitAuthor,
        );
      } catch (ex, st) {
        return Result.fail(ex, st);
      }
    }

    return Result(null);
  }

  Future<Result<void>> _addAllAndCommit(String commitMessage) async {
    var r = await _add(".");
    if (r.isFailure) {
      return fail(r);
    }

    var res = await _commit(
      message: commitMessage,
      authorEmail: config.gitAuthorEmail,
      authorName: config.gitAuthor,
    );
    if (res.isFailure) {
      return fail(r);
    }

    return Result(null);
  }

  Future<Result<void>> addNote(Note note) async {
    var msg = messageBuilder.addNote(note.filePath);
    return _addAllAndCommit(msg);
  }

  Future<Result<void>> addFolder(NotesFolderFS folder) async {
    var msg = messageBuilder.addFolder(folder.folderPath);
    return _addAllAndCommit(msg);
  }

  Future<Result<void>> renameFolder(String oldPath, String newPath) async {
    var msg = messageBuilder.renameFolder(oldPath, newPath);

    // FIXME: This is a hacky way of adding the changes, ideally we should be
    //        calling rm + add or something
    return _addAllAndCommit(msg);
  }

  Future<Result<void>> renameNote(String oldPath, String newPath) async {
    assert(!oldPath.startsWith(p.separator));
    assert(!newPath.startsWith(p.separator));

    assert(!oldPath.startsWith(gitRepoPath));
    assert(!newPath.startsWith(gitRepoPath));

    var msg = messageBuilder.renameNote(oldPath, newPath);
    return _addAllAndCommit(msg);
  }

  // Future<Result<void>> renameFile(
  //   String oldFullPath,
  //   String newFullPath,
  // ) async {
  //   var repoPath = gitRepoPath.endsWith('/') ? gitRepoPath : '$gitRepoPath/';
  //   var oldSpec = oldFullPath.substring(repoPath.length);
  //   var newSpec = newFullPath.substring(repoPath.length);
  //   var msg = messageBuilder.renameFile(oldSpec, newSpec);

  //   return _addAllAndCommit(msg);
  // }

  Future<Result<void>> moveNotes(
    List<String> oldPaths,
    List<String> newPaths,
    String newFolderPath,
  ) async {
    var repoPath = gitRepoPath.endsWith('/') ? gitRepoPath : '$gitRepoPath/';
    var oldSpecs = oldPaths.map((p) => p.substring(repoPath.length)).toList();
    var newSpecs = newPaths.map((p) => p.substring(repoPath.length)).toList();

    var msg = oldPaths.length == 1
        ? messageBuilder.moveNote(oldSpecs.first, newSpecs.first)
        : messageBuilder.moveNotes(oldSpecs, newSpecs);
    return _addAllAndCommit(msg);
  }

  Future<Result<void>> removeNotes(List<Note> notes) async {
    return catchAll(() async {
      // We are not calling note.remove() as gitRm will also remove the file
      for (var note in notes) {
        var spec = note.filePath;
        await _rm(spec).throwOnError();
      }
      await _commit(
        message: notes.length == 1
            ? messageBuilder.removeNote(notes.first.filePath)
            : messageBuilder.removeNotes(notes.map((n) => n.filePath)),
        authorEmail: config.gitAuthorEmail,
        authorName: config.gitAuthor,
      ).throwOnError();

      return Result(null);
    });
  }

  Future<Result<void>> removeFolder(NotesFolderFS folder) async {
    return catchAll(() async {
      var spec = folder.folderPath;
      await _rm(spec).throwOnError();
      await _commit(
        message: messageBuilder.removeFolder(spec),
        authorEmail: config.gitAuthorEmail,
        authorName: config.gitAuthor,
      ).throwOnError();
      await Directory(folder.folderPath).delete(recursive: true);

      return Result(null);
    });
  }

  Future<Result<void>> resetLastCommit() async {
    if (useDartGit || AppConfig.instance.experimentalGitOps) {
      var repo = await GitRepository.load(gitRepoPath).getOrThrow();
      var headCommitR = await repo.headCommit();
      if (headCommitR.isFailure) {
        return fail(headCommitR);
      }
      var headCommit = headCommitR.getOrThrow();
      var result = await repo.resetHard(headCommit.parents[0]);
      if (result.isFailure) {
        return fail(result);
      }

      return Result(null);
    }
    try {
      await _gitRepo.resetLast();
    } catch (e, st) {
      return Result.fail(e, st);
    }
    return Result(null);
  }

  Future<Result<void>> updateNote(Note note) async {
    var msg = messageBuilder.updateNote(note.filePath);
    return _addAllAndCommit(msg);
  }

  Future<Result<void>> fetch() async {
    var remoteName = 'origin';

    if (Platform.isAndroid || Platform.isIOS) {
      try {
        await _gitRepo.fetch(
          remote: remoteName,
          publicKey: config.sshPublicKey,
          privateKey: config.sshPrivateKey,
          password: config.sshPassword,
          statusFile: p.join(Directory.systemTemp.path, 'gj'),
        );
      } on gb.GitException catch (ex, stackTrace) {
        Log.e("GitPull Failed", ex: ex, stacktrace: stackTrace);
        return Result.fail(ex, stackTrace);
      } catch (ex, stackTrace) {
        return Result.fail(ex, stackTrace);
      }
    } else if (Platform.isMacOS || Platform.isLinux) {
      await gitFetchViaExecutable(
        privateKey: config.sshPrivateKey,
        privateKeyPassword: config.sshPassword,
        remoteName: remoteName,
        repoPath: gitRepoPath,
      ).throwOnError();
    }

    return Result(null);
  }

  Future<Result<void>> merge() => catchAll(_merge);

  Future<Result<void>> _merge() async {
    var repo = await GitRepository.load(gitRepoPath).getOrThrow();
    var branch = await repo.currentBranch().getOrThrow();

    var branchConfig = repo.config.branch(branch);
    if (branchConfig == null) {
      var ex = Exception("Branch '$branch' not in config");
      logExceptionWarning(ex, StackTrace.current);
      return Result.fail(ex);
    }

    var r = await repo.remoteBranch(
      branchConfig.remote!,
      branchConfig.trackingBranch()!,
    );
    if (r.isFailure) {
      Log.e("Failed to get remote refs", ex: r.error, stacktrace: r.stackTrace);
      return fail(r);
    }

    if (useDartGit || AppConfig.instance.experimentalGitMerge) {
      var author = GitAuthor(
        email: config.gitAuthorEmail,
        name: config.gitAuthor,
      );
      return repo.mergeCurrentTrackingBranch(author: author);
    }

    try {
      await _gitRepo.merge(
        branch: branchConfig.remoteTrackingBranch(),
        authorEmail: config.gitAuthorEmail,
        authorName: config.gitAuthor,
      );
    } on gb.GitException catch (ex, stackTrace) {
      Log.e("Git Merge Failed", ex: ex, stacktrace: stackTrace);
      return Result.fail(Exception('Git Merge Bindings failed'));
    }

    return Result(null);
  }

  Future<void> push() async {
    // Only push if we have something we need to push
    try {
      var repo = await GitRepository.load(gitRepoPath).getOrThrow();
      var canPush = await repo.canPush().getOrThrow();
      if (!canPush) {
        return;
      }
    } catch (ex, st) {
      Log.e("Can Push", ex: ex, stacktrace: st);
    }

    var remoteName = 'origin';
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        await _gitRepo.push(
          remote: remoteName,
          publicKey: config.sshPublicKey,
          privateKey: config.sshPrivateKey,
          password: config.sshPassword,
          statusFile: p.join(Directory.systemTemp.path, 'gj'),
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
    } else if (Platform.isMacOS || Platform.isLinux) {
      await gitPushViaExecutable(
        privateKey: config.sshPrivateKey,
        privateKeyPassword: config.sshPassword,
        remoteName: remoteName,
        repoPath: gitRepoPath,
      ).throwOnError();
    }
  }

  Future<int?> numChanges() async {
    try {
      var repo = await GitRepository.load(gitRepoPath).getOrThrow();
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
