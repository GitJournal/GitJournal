/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';
import 'dart:convert';

import 'package:dart_git/dart_git.dart';
import 'package:dart_git/exceptions.dart';
import 'package:gitjournal/core/commit_message_builder.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/git_config.dart';
import 'package:gitjournal/utils/git_desktop.dart';
import 'package:go_git_dart/go_git_dart_async.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart' show Platform;

class GitNoteRepository {
  final String gitRepoPath;
  final GitConfig config;
  final CommitMessageBuilder messageBuilder;

  GitNoteRepository({
    required this.gitRepoPath,
    required this.config,
  }) : messageBuilder = CommitMessageBuilder();

  Future<void> _add(String pathSpec) async {
    var repo = await GitAsyncRepository.load(gitRepoPath);
    await repo.add(pathSpec);
  }

  Future<void> _rm(String pathSpec) async {
    var repo = await GitAsyncRepository.load(gitRepoPath);
    await repo.rm(pathSpec);
  }

  Future<void> _commit({
    required String message,
    required String authorEmail,
    required String authorName,
  }) async {
    var repo = await GitAsyncRepository.load(gitRepoPath);
    var author = GitAuthor(name: authorName, email: authorEmail);
    await repo.commit(message: message, author: author);
  }

  Future<void> _addAllAndCommit(String commitMessage) async {
    await _add(".");
    await _commit(
      message: commitMessage,
      authorEmail: config.gitAuthorEmail,
      authorName: config.gitAuthor,
    );
  }

  Future<void> addNote(Note note) async {
    var msg = messageBuilder.addNote(note.filePath);
    return _addAllAndCommit(msg);
  }

  Future<void> addFolder(NotesFolderFS folder) async {
    var msg = messageBuilder.addFolder(folder.folderPath);
    return _addAllAndCommit(msg);
  }

  Future<void> renameFolder(String oldPath, String newPath) async {
    var msg = messageBuilder.renameFolder(oldPath, newPath);

    // FIXME: This is a hacky way of adding the changes, ideally we should be
    //        calling rm + add or something
    return _addAllAndCommit(msg);
  }

  Future<void> renameNote(String oldPath, String newPath) async {
    assert(!oldPath.startsWith(p.separator));
    assert(!newPath.startsWith(p.separator));

    assert(!oldPath.startsWith(gitRepoPath));
    assert(!newPath.startsWith(gitRepoPath));

    var msg = messageBuilder.renameNote(oldPath, newPath);
    return _addAllAndCommit(msg);
  }

  // Future<void> renameFile(
  //   String oldFullPath,
  //   String newFullPath,
  // ) async {
  //   var repoPath = gitRepoPath.endsWith('/') ? gitRepoPath : '$gitRepoPath/';
  //   var oldSpec = oldFullPath.substring(repoPath.length);
  //   var newSpec = newFullPath.substring(repoPath.length);
  //   var msg = messageBuilder.renameFile(oldSpec, newSpec);

  //   return _addAllAndCommit(msg);
  // }

  Future<void> moveNotes(
    List<String> oldPaths,
    List<String> newPaths,
  ) async {
    assert(oldPaths.isNotEmpty);
    assert(newPaths.isNotEmpty);
    assert(oldPaths.length == newPaths.length);

    var msg = oldPaths.length == 1
        ? messageBuilder.moveNote(oldPaths.first, newPaths.first)
        : messageBuilder.moveNotes(oldPaths, newPaths);
    return _addAllAndCommit(msg);
  }

  Future<void> removeNotes(List<Note> notes) async {
    // We are not calling note.remove() as gitRm will also remove the file
    for (var note in notes) {
      var spec = note.filePath;
      await _rm(spec);
    }
    await _commit(
      message: notes.length == 1
          ? messageBuilder.removeNote(notes.first.filePath)
          : messageBuilder.removeNotes(notes.map((n) => n.filePath)),
      authorEmail: config.gitAuthorEmail,
      authorName: config.gitAuthor,
    );
  }

  Future<void> removeFolder(NotesFolderFS folder) async {
    var spec = folder.folderPath;
    await _rm(spec);
    await _commit(
      message: messageBuilder.removeFolder(spec),
      authorEmail: config.gitAuthorEmail,
      authorName: config.gitAuthor,
    );
  }

  Future<void> resetLastCommit() async {
    var repo = await GitAsyncRepository.load(gitRepoPath);
    var headCommit = await repo.headCommit();
    await repo.resetHard(headCommit.parents[0]);
  }

  Future<void> updateNote(Note note) async {
    var msg = messageBuilder.updateNote(note.filePath);
    return _addAllAndCommit(msg);
  }

  Future<void> fetch() async {
    var remoteName = 'origin';

    if (Platform.isAndroid || Platform.isIOS) {
      try {
        var bindings = GitBindingsAsync();
        await bindings.fetch(remoteName, gitRepoPath,
            utf8.encode(config.sshPrivateKey), config.sshPassword);
      } catch (ex) {
        rethrow;
      }
    } else if (Platform.isMacOS || Platform.isLinux) {
      await gitFetchViaExecutable(
        privateKey: config.sshPrivateKey,
        privateKeyPassword: config.sshPassword,
        remoteName: remoteName,
        repoPath: gitRepoPath,
      );
    }
  }

  Future<void> merge() async {
    var repo = await GitAsyncRepository.load(gitRepoPath);
    var branch = await repo.currentBranch();

    var branchConfig = repo.config.branch(branch);
    if (branchConfig == null) {
      var ex = Exception("Branch '$branch' not in config");
      unawaited(logExceptionWarning(ex, StackTrace.current));
      throw ex;
    }

    try {
      // try to get the remoteBranch
      await repo.remoteBranch(
        branchConfig.remote!,
        branchConfig.trackingBranch()!,
      );
    } catch (ex) {
      if (ex is GitRefNotFound) {
        Log.d("No remote branch to merge");
      } else {
        Log.e("Failed to get remote refs",
            ex: ex, stacktrace: StackTrace.current);
      }
      rethrow;
    }

    var author = GitAuthor(
      email: config.gitAuthorEmail,
      name: config.gitAuthor,
    );
    return repo.mergeCurrentTrackingBranch(author: author);
  }

  Future<void> push() async {
    // Only push if we have something we need to push
    try {
      var repo = await GitAsyncRepository.load(gitRepoPath);
      var canPush = await repo.canPush();

      if (!canPush) {}
    } catch (ex, st) {
      Log.e("Can Push", ex: ex, stacktrace: st);
    }

    var remoteName = 'origin';
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        var bindings = GitBindingsAsync();
        await bindings.push(remoteName, gitRepoPath,
            utf8.encode(config.sshPrivateKey), config.sshPassword);
      } catch (ex, stackTrace) {
        /*
        if (ex is gb.GitException) {
          if (ex.cause == 'cannot push non-fastforwardable reference') {
            await fetch();
            await merge();
            await push();
          }
        }
        */
        Log.e("GitPush Failed", ex: ex, stacktrace: stackTrace);
        rethrow;
      }
    } else if (Platform.isMacOS || Platform.isLinux) {
      return await gitPushViaExecutable(
        privateKey: config.sshPrivateKey,
        privateKeyPassword: config.sshPassword,
        remoteName: remoteName,
        repoPath: gitRepoPath,
      );
    }
  }

  Future<int?> numChanges() async {
    try {
      var repo = await GitAsyncRepository.load(gitRepoPath);
      return await repo.numChangesToPush();
    } catch (ex, st) {
      Log.e("numChanges", ex: ex, stacktrace: st);
      return null;
    }
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
  var msg = ex.toString().toLowerCase();
  for (var i = 0; i < ignoredMessages.length; i++) {
    if (msg.contains(ignoredMessages[i])) {
      return false;
    }
  }
  return true;
}
