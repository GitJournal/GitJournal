/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:dart_git/dart_git.dart';
import 'package:dart_git/utils/result.dart';
import 'package:function_types/function_types.dart';
import 'package:git_bindings/git_bindings.dart' as git_bindings;

import 'package:gitjournal/logger/logger.dart';
import 'clone.dart';
import 'git_transfer_progress.dart';

Future<Result<void>> cloneRemote({
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
  return catchAll(
    () => cloneRemotePluggable(
      repoPath: repoPath,
      cloneUrl: cloneUrl,
      remoteName: remoteName,
      sshPublicKey: sshPublicKey,
      sshPrivateKey: sshPrivateKey,
      sshPassword: sshPassword,
      authorName: authorName,
      authorEmail: authorEmail,
      progressUpdate: progressUpdate,
      gitFetchFn: _fetch,
      defaultBranchFn: _defaultBranch,
      gitMergeFn: _merge,
    ),
  );
}

Future<Result<void>> _fetch(
  String repoPath,
  String remoteName,
  String sshPublicKey,
  String sshPrivateKey,
  String sshPassword,
  String statusFile,
) async {
  try {
    var gitRepo = git_bindings.GitRepo(folderPath: repoPath);
    await gitRepo.fetch(
      remote: remoteName,
      publicKey: sshPublicKey,
      privateKey: sshPrivateKey,
      password: sshPassword,
      statusFile: statusFile,
    );
  } catch (e, st) {
    return Result.fail(e, st);
  }

  return Result(null);
}

Future<Result<String>> _defaultBranch(
  String repoPath,
  String remoteName,
  String sshPublicKey,
  String sshPrivateKey,
  String sshPassword,
) async {
  try {
    var gitRepo = git_bindings.GitRepo(folderPath: repoPath);
    var branch = await gitRepo.defaultBranch(
      remote: remoteName,
      publicKey: sshPublicKey,
      privateKey: sshPrivateKey,
      password: sshPassword,
    );
    Log.i("Got default branch: $branch");
    if (branch != null && branch.isNotEmpty) {
      return Result(branch);
    }
  } catch (ex) {
    Log.w("Could not fetch git main branch", ex: ex);
  }

  var repo = await GitRepository.load(repoPath).getOrThrow();
  var remoteBranch = await repo.guessRemoteHead(remoteName);
  if (remoteBranch == null) {
    return Result('master');
  }
  var branch = remoteBranch.target!.branchName()!;
  return Result(branch);
}

Future<Result<void>> _merge(
  String repoPath,
  String remoteName,
  String remoteBranchName,
  String authorName,
  String authorEmail,
) async {
  try {
    var gitRepo = git_bindings.GitRepo(folderPath: repoPath);
    await gitRepo.merge(
      branch: '$remoteName/$remoteBranchName',
      authorName: authorName,
      authorEmail: authorEmail,
    );
  } catch (e, st) {
    return Result.fail(e, st);
  }

  return Result(null);
}
