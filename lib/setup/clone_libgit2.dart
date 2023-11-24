/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:dart_git/dart_git.dart';
import 'package:dart_git/plumbing/reference.dart';
import 'package:function_types/function_types.dart';
import 'package:git_bindings/git_bindings.dart' as git_bindings;
import 'package:git_setup/git_transfer_progress.dart';
import 'package:gitjournal/logger/logger.dart';

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
  await git_bindings.GitRepo.clone(
    cloneUrl: cloneUrl,
    folderPath: repoPath,
    publicKey: sshPublicKey,
    privateKey: sshPrivateKey,
    password: sshPassword,
    statusFile: statusFile,
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
  var gitRepo = git_bindings.GitRepo(folderPath: repoPath);
  await gitRepo.fetch(
    remote: remoteName,
    publicKey: sshPublicKey,
    privateKey: sshPrivateKey,
    password: sshPassword,
    statusFile: statusFile,
  );
}

Future<String> _defaultBranch(
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
