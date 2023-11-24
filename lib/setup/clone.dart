/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';

import 'package:dart_git/dart_git.dart';
import 'package:dart_git/exceptions.dart';
import 'package:dart_git/plumbing/reference.dart';
import 'package:function_types/function_types.dart';
import 'package:git_setup/git_transfer_progress.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart' show Directory;

const DefaultBranchName = DEFAULT_BRANCH;

typedef GitFetchFunction = Future<void> Function(
  String repoPath,
  String remoteName,
  String sshPublicKey,
  String sshPrivateKey,
  String sshPassword,
  String statusFile,
);

typedef GitCloneFunction = Future<void> Function({
  required String cloneUrl,
  required String repoPath,
  required String sshPublicKey,
  required String sshPrivateKey,
  required String sshPassword,
  required String statusFile,
});

typedef GitDefaultBranchFunction = Future<String> Function(
  String repoPath,
  String remoteName,
  String sshPublicKey,
  String sshPrivateKey,
  String sshPassword,
);

Future<void> cloneRemotePluggable({
  required String repoPath,
  required String cloneUrl,
  required String remoteName,
  required String sshPublicKey,
  required String sshPrivateKey,
  required String sshPassword,
  required String authorName,
  required String authorEmail,
  required Func1<GitTransferProgress, void> progressUpdate,
  required GitFetchFunction gitFetchFn,
  required GitCloneFunction gitCloneFn,
  required GitDefaultBranchFunction defaultBranchFn,
}) async {
  var statusFile = p.join(Directory.systemTemp.path, 'gj');

  // Check if the repo is empty, and accordingly use clone instead
  // this way we can avoid using dart-git unless absolutely necessary
  // since it's clearly buggy
  if (await _repoIsEmpty(repoPath)) {
    Directory(repoPath).deleteSync(recursive: true);
    return await gitCloneFn(
      cloneUrl: cloneUrl,
      repoPath: repoPath,
      sshPublicKey: sshPublicKey,
      sshPrivateKey: sshPrivateKey,
      sshPassword: sshPassword,
      statusFile: statusFile,
    );
  }

  var repo = await GitAsyncRepository.load(repoPath);
  var remote = await repo.addOrUpdateRemote(remoteName, cloneUrl);

  var duration = const Duration(milliseconds: 50);
  var timer = Timer.periodic(duration, (_) async {
    var progress = await GitTransferProgress.load(statusFile);
    if (progress != null) {
      progressUpdate(progress);
    }
  });

  try {
    await gitFetchFn(repoPath, remoteName, sshPublicKey, sshPrivateKey,
        sshPassword, statusFile);
  } catch (ex) {
    rethrow;
  } finally {
    timer.cancel();
  }

  var remoteBranchName = "";
  try {
    remoteBranchName = await defaultBranchFn(
        repoPath, remoteName, sshPublicKey, sshPrivateKey, sshPassword);
  } catch (ex, st) {
    Log.e("`git fetch default branch` failed", ex: ex, stacktrace: st);
  }
  if (remoteBranchName.isEmpty) {
    try {
      remoteBranchName = await repo.currentBranch();
    } catch (_) {
      remoteBranchName = DefaultBranchName;
    }
  }

  Log.i("Using remote branch: $remoteBranchName");
  var skipCheckout = false;

  var branches = await repo.branches();
  Log.i("Repo has the following branches: $branches");
  if (branches.isEmpty) {
    Log.i("Completing - no local branch");
    try {
      var remoteBranch = await repo.remoteBranch(remoteName, remoteBranchName);
      // remote branch exists
      Log.i("Remote branch exists $remoteName/$remoteBranchName");
      await repo.createBranch(remoteBranchName, hash: remoteBranch.hash);
      await repo.checkoutBranch(remoteBranchName);
    } catch (ex) {
      if (ex is! GitNotFound) rethrow;
      skipCheckout = true;
    }

    // FIXME: This will fail if the currentBranch doesn't exist!!
    await repo.setUpstreamTo(remote, remoteBranchName);
  } else {
    Log.i("Local branches $branches");
    var branch = branches[0];

    if (branch == remoteBranchName) {
      Log.i("Completing - localBranch: $branch");

      var currentBranch = await repo.currentBranch();
      if (currentBranch != branch) {
        Log.i("Current branch is not the only branch");
        Log.d("Current Branch: $currentBranch");
        Log.d("Branch: $branch");

        // Shit happens sometimes
        // There is only one local branch, and that branch is not the current
        // branch, wtf?
        await repo.checkoutBranch(branch);
      }

      await repo.setUpstreamTo(remote, remoteBranchName);
      try {
        await repo.remoteBranch(remoteName, remoteBranchName);
        await _merge(
            repoPath, remoteName, remoteBranchName, authorName, authorEmail);
      } catch (ex, st) {
        Log.e("Remote branch merging failed", ex: ex, stacktrace: st);
      }
    } else {
      Log.i("Completing - localBranch diff remote: $branch $remoteBranchName");
      await repo.createBranch(remoteBranchName);
      await repo.checkoutBranch(remoteBranchName);

      await repo.deleteBranch(branch);
      await repo.setUpstreamTo(remote, remoteBranchName);

      Log.i("Merging '$remoteName/$remoteBranchName'");
      await _merge(
          repoPath, remoteName, remoteBranchName, authorName, authorEmail);
    }
  }

  // Just to be on the safer side, incase dart-git fucks up something
  // dart-git does fuck something up. This is required!
  // Causes problems -
  // - Pack files are read into memory, this causes OOM issues
  //   https://sentry.io/organizations/gitjournal/issues/2254310735/?project=5168082&query=is%3Aunresolved
  //
  if (!skipCheckout) {
    await repo.checkout(".");
  }
}

Future<bool> _repoIsEmpty(repoPath) async {
  var entities = Directory(repoPath).listSync();
  if (entities.length == 1) {
    if (p.basename(entities[0].path) == '.git') {
      return true;
    }
  }

  return false;
}

String folderNameFromCloneUrl(String cloneUrl) {
  var name = p.basename(cloneUrl);
  if (name.endsWith('.git')) {
    name = name.substring(0, name.length - 4);
  }
  return name;
}

Future<void> _merge(
  String repoPath,
  String remoteName,
  String remoteBranchName,
  String authorName,
  String authorEmail,
) async {
  var repo = GitRepository.load(repoPath);
  var author = GitAuthor(name: authorName, email: authorEmail);
  try {
    repo.mergeTrackingBranch(author: author);
  } catch (ex) {
    if (ex is GitRefNotFound) {
      var refName = ReferenceName.remote(remoteName, remoteBranchName);
      if (ex.refName == refName) {
        Log.d("Remote Repo is empty");
      }
      repo.close();
      return;
    }

    rethrow;
  }
  repo.close();
}
