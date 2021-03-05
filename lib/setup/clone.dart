import 'package:dart_git/dart_git.dart';
import 'package:git_bindings/git_bindings.dart' as git_bindings;
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'package:gitjournal/utils/logger.dart';

Future<void> cloneRemote({
  @required String repoPath,
  @required String cloneUrl,
  @required String remoteName,
  @required String sshPublicKey,
  @required String sshPrivateKey,
  @required String sshPassword,
  @required String authorName,
  @required String authorEmail,
}) async {
  var repo = await GitRepository.load(repoPath);

  var remote = await repo.addOrUpdateRemote(remoteName, cloneUrl);

  var _gitRepo = git_bindings.GitRepo(folderPath: repoPath);
  await _gitRepo.fetch(
    remote: remoteName,
    publicKey: sshPublicKey,
    privateKey: sshPrivateKey,
    password: sshPassword,
  );

  var remoteBranchName = await _remoteDefaultBranch(
    repo: repo,
    libGit2Repo: _gitRepo,
    remoteName: remoteName,
    sshPublicKey: sshPublicKey,
    sshPrivateKey: sshPrivateKey,
    sshPassword: sshPassword,
  );
  Log.i("Using remote branch: $remoteBranchName");

  var branches = await repo.branches();
  if (branches.isEmpty) {
    Log.i("Completing - no local branch");
    var remoteBranch = await repo.remoteBranch(remoteName, remoteBranchName);

    if (remoteBranchName != null &&
        remoteBranchName.isNotEmpty &&
        remoteBranch != null) {
      await repo.createBranch(remoteBranchName, hash: remoteBranch.hash);
      await repo.checkoutBranch(remoteBranchName);
    }
    await repo.setUpstreamTo(remote, remoteBranchName);
  } else {
    Log.i("Local branches $branches");
    var branch = branches[0];

    if (branch == remoteBranchName) {
      Log.i("Completing - localBranch: $branch");

      var currentBranch = await repo.currentBranch();
      if (currentBranch != branch) {
        // Shit happens sometimes
        // There is only one local branch, and that branch is not the current
        // branch, wtf?
        await repo.checkoutBranch(branch);
      }

      await repo.setUpstreamTo(remote, remoteBranchName);
      var remoteBranch = await repo.remoteBranch(remoteName, remoteBranchName);
      if (remoteBranch != null) {
        Log.i("Merging '$remoteName/$remoteBranchName'");
        await _gitRepo.merge(
          branch: '$remoteName/$remoteBranchName',
          authorName: authorName,
          authorEmail: authorEmail,
        );
      }
    } else {
      Log.i("Completing - localBranch diff remote: $branch $remoteBranchName");
      await repo.createBranch(remoteBranchName);
      await repo.checkoutBranch(remoteBranchName);

      await repo.deleteBranch(branch);
      await repo.setUpstreamTo(remote, remoteBranchName);

      Log.i("Merging '$remoteName/$remoteBranchName'");
      await _gitRepo.merge(
        branch: '$remoteName/$remoteBranchName',
        authorName: authorName,
        authorEmail: authorEmail,
      );
    }
  }

  // Just to be on the safer side, incase dart-git fucks up something
  // Causes problems -
  // - Pack files are read into memory, this causes OOM issues
  //   https://sentry.io/organizations/gitjournal/issues/2254310735/?project=5168082&query=is%3Aunresolved
  // - Pack files don't have REF_DELTA implemented
  //   https://sentry.io/organizations/gitjournal/issues/2235794657/?project=5168082&query=is%3Aunresolved
  //
  // await repo.checkout(".");
}

Future<String> _remoteDefaultBranch({
  @required GitRepository repo,
  @required git_bindings.GitRepo libGit2Repo,
  @required String remoteName,
  @required String sshPublicKey,
  @required String sshPrivateKey,
  @required String sshPassword,
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
  return remoteBranch.target.branchName();
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
