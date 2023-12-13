/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';

import 'package:dart_git/dart_git.dart';
import 'package:dart_git/plumbing/reference.dart';
import 'package:function_types/function_types.dart';
import 'package:git_setup/git_transfer_progress.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:go_git_dart/go_git_dart_async.dart';

import 'clone.dart';

Future<void> cloneRemote({
  required String repoPath,
  required String cloneUrl,
  required String remoteName,
  required String sshPublicKey,
  required String sshPrivateKey,
  required String sshPassword,
  required String authorName,
  required String authorEmail,
  required Func1<GitTransferProgress, void> progressUpdate,
}) {
  return cloneRemotePluggable(
    repoPath: repoPath,
    cloneUrl: cloneUrl,
    remoteName: remoteName,
    sshPublicKey: sshPublicKey,
    sshPrivateKey: sshPrivateKey,
    sshPassword: sshPassword,
    authorName: authorName,
    authorEmail: authorEmail,
    progressUpdate: progressUpdate,
    gitCloneFn: _clone,
    gitFetchFn: _fetch,
    defaultBranchFn: _defaultBranch,
  );
}

Future<void> _clone({
  required String cloneUrl,
  required String repoPath,
  required String sshPublicKey,
  required String sshPrivateKey,
  required String sshPassword,
  required String statusFile,
}) async {
  var bindings = GitBindingsAsync();
  await bindings.clone(
    cloneUrl,
    repoPath,
    utf8.encode(sshPrivateKey),
    sshPassword,
  );
}

Future<void> _fetch(
  String repoPath,
  String remoteName,
  String sshPublicKey,
  String sshPrivateKey,
  String sshPassword,
  String statusFile,
) async {
  var bindings = GitBindingsAsync();
  await bindings.fetch(
      remoteName, repoPath, utf8.encode(sshPrivateKey), sshPassword);
}

Future<String> _defaultBranch(
  String repoPath,
  String remoteName,
  String sshPublicKey,
  String sshPrivateKey,
  String sshPassword,
) async {
  try {
    var repo = GitRepository.load(repoPath);
    var remote = repo.config.remote(remoteName);
    if (remote == null) {
      throw Exception("Remote '$remoteName' not found");
    }

    var bindings = GitBindingsAsync();
    var branch = await bindings.defaultBranch(
        remote.url, utf8.encode(sshPrivateKey), sshPassword);

    Log.i("Got default branch: $branch");
    if (branch.isNotEmpty) {
      return branch;
    }
  } catch (ex) {
    Log.w("Could not fetch git Default Branch", ex: ex);
  }

  var repo = GitRepository.load(repoPath);
  var remoteBranch = repo.guessRemoteHead(remoteName);
  repo.close();
  if (remoteBranch == null || remoteBranch is! SymbolicReference) {
    Log.e("Failed to guess RemoteHead. Returning `main`");
    return "main";
  }
  var branch = remoteBranch.target.branchName()!;
  Log.d("Guessed default branch as $branch");
  return branch;
}
