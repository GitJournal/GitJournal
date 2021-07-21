import 'dart:async';
import 'dart:io' show Platform, Directory, File;

import 'package:dart_git/dart_git.dart';
import 'package:dart_git/exceptions.dart';
import 'package:function_types/function_types.dart';
import 'package:git_bindings/git_bindings.dart' as git_bindings;
import 'package:path/path.dart' as p;

import 'package:gitjournal/utils/git_desktop.dart';
import 'package:gitjournal/utils/logger.dart';

class GitTransferProgress {
  int totalObjects = 0;
  int indexedObjects = 0;
  int receivedObjects = 0;
  int localObjects = 0;
  int totalDeltas = 0;
  int indexedDeltas = 0;
  int receivedBytes = 0;

  static Future<GitTransferProgress?> load(String statusFile) async {
    if (!File(statusFile).existsSync()) {
      return null;
    }
    var str = await File(statusFile).readAsString();
    var parts = str.split(' ');
    print('Str #$str#');
    print('Parts $parts');

    var tp = GitTransferProgress();
    tp.totalObjects = int.parse(parts[0]);
    tp.indexedObjects = int.parse(parts[1]);
    tp.receivedObjects = int.parse(parts[2]);
    tp.localObjects = int.parse(parts[3]);
    tp.totalDeltas = int.parse(parts[4]);
    tp.indexedDeltas = int.parse(parts[5]);
    tp.receivedBytes = int.parse(parts[6]);
    return tp;
  }
}

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
}) async {
  var repo = await GitRepository.load(repoPath).getOrThrow();
  var remote = await repo.addOrUpdateRemote(remoteName, cloneUrl).getOrThrow();

  var remoteBranchName = "master";
  var _gitRepo = git_bindings.GitRepo(folderPath: repoPath);

  if (Platform.isAndroid || Platform.isIOS) {
    var statusFile = p.join(Directory.systemTemp.path, 'gj');
    var duration = const Duration(milliseconds: 10);
    var timer = Timer.periodic(duration, (_) async {
      var progress = await GitTransferProgress.load(statusFile);
      if (progress != null) {
        progressUpdate(progress);
      }
    });
    await _gitRepo.fetch(
      remote: remoteName,
      publicKey: sshPublicKey,
      privateKey: sshPrivateKey,
      password: sshPassword,
      statusFile: statusFile,
    );
    timer.cancel();

    remoteBranchName = await _remoteDefaultBranch(
      repo: repo,
      libGit2Repo: _gitRepo,
      remoteName: remoteName,
      sshPublicKey: sshPublicKey,
      sshPrivateKey: sshPrivateKey,
      sshPassword: sshPassword,
    );
  } else if (Platform.isMacOS) {
    var r = await gitFetchViaExecutable(
      repoPath: repoPath,
      privateKey: sshPrivateKey,
      privateKeyPassword: sshPassword,
      remoteName: remoteName,
    );
    if (r.isFailure) {
      return fail(r);
    }

    var branchR = await gitDefaultBranchViaExecutable(
      repoPath: repoPath,
      privateKey: sshPrivateKey,
      privateKeyPassword: sshPassword,
      remoteName: remoteName,
    );
    if (r.isFailure) {
      return fail(r);
    }
    remoteBranchName = branchR.getOrThrow();
  }
  Log.i("Using remote branch: $remoteBranchName");

  var branches = await repo.branches().getOrThrow();
  if (branches.isEmpty) {
    Log.i("Completing - no local branch");
    var remoteBranchR = await repo.remoteBranch(remoteName, remoteBranchName);
    if (remoteBranchR.isFailure) {
      if (remoteBranchR.error is! GitNotFound) {
        return fail(remoteBranchR);
      }

      // remoteBranch doesn't exist - do nothing? Are you sure?
    } else {
      // remote branch exists
      var remoteBranch = remoteBranchR.getOrThrow();
      await repo.createBranch(remoteBranchName, hash: remoteBranch.hash);
      await repo.checkoutBranch(remoteBranchName);
    }

    // FIXME: This will fail if the currentBranch doesn't exist!!
    await repo.setUpstreamTo(remote, remoteBranchName).getOrThrow();
  } else {
    Log.i("Local branches $branches");
    var branch = branches[0];

    if (branch == remoteBranchName) {
      Log.i("Completing - localBranch: $branch");

      var currentBranch = await repo.currentBranch().getOrThrow();
      if (currentBranch != branch) {
        // Shit happens sometimes
        // There is only one local branch, and that branch is not the current
        // branch, wtf?
        await repo.checkoutBranch(branch);
      }

      await repo.setUpstreamTo(remote, remoteBranchName).getOrThrow();
      var remoteBranchR = await repo.remoteBranch(remoteName, remoteBranchName);
      if (remoteBranchR.isSuccess) {
        Log.i("Merging '$remoteName/$remoteBranchName'");
        if (Platform.isAndroid || Platform.isIOS) {
          await _gitRepo.merge(
            branch: '$remoteName/$remoteBranchName',
            authorName: authorName,
            authorEmail: authorEmail,
          );
        } else {
          var repo = await GitRepository.load(repoPath).getOrThrow();
          var author = GitAuthor(name: authorName, email: authorEmail);
          repo.mergeCurrentTrackingBranch(author: author).throwOnError();
        }
      }
    } else {
      Log.i("Completing - localBranch diff remote: $branch $remoteBranchName");
      await repo.createBranch(remoteBranchName).getOrThrow();
      await repo.checkoutBranch(remoteBranchName).getOrThrow();

      await repo.deleteBranch(branch).getOrThrow();
      await repo.setUpstreamTo(remote, remoteBranchName).getOrThrow();

      Log.i("Merging '$remoteName/$remoteBranchName'");
      if (Platform.isAndroid || Platform.isIOS) {
        await _gitRepo.merge(
          branch: '$remoteName/$remoteBranchName',
          authorName: authorName,
          authorEmail: authorEmail,
        );
      } else {
        var repo = await GitRepository.load(repoPath).getOrThrow();
        var author = GitAuthor(name: authorName, email: authorEmail);
        repo.mergeCurrentTrackingBranch(author: author).throwOnError();
      }
    }
  }

  // Just to be on the safer side, incase dart-git fucks up something
  // dart-git does fuck something up. This is required!
  // Causes problems -
  // - Pack files are read into memory, this causes OOM issues
  //   https://sentry.io/organizations/gitjournal/issues/2254310735/?project=5168082&query=is%3Aunresolved
  //
  await repo.checkout(".");

  return Result(null);
}

Future<String> _remoteDefaultBranch({
  required GitRepository repo,
  required git_bindings.GitRepo libGit2Repo,
  required String remoteName,
  required String sshPublicKey,
  required String sshPrivateKey,
  required String sshPassword,
}) async {
  try {
    var branch = await libGit2Repo.defaultBranch(
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
    Log.w("Could not fetch git main branch", ex: ex);
  }

  var remoteBranch = await repo.guessRemoteHead(remoteName);
  if (remoteBranch == null) {
    return 'master';
  }
  return remoteBranch.target!.branchName()!;
}

String folderNameFromCloneUrl(String cloneUrl) {
  var name = p.basename(cloneUrl);
  if (name.endsWith('.git')) {
    name = name.substring(0, name.length - 4);
  }
  return name;
}

// Test Cases -
// * New Repo, No Local Changes
// * New Repo, Existing Changes
// * Existing Repo (master default), No Local Changes
// * Existing Repo (master default), Local changes in 'master' branch
// * Existing Repo (main default), Local changes in 'master' branch
