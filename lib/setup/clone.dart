import 'package:dart_git/dart_git.dart';
import 'package:git_bindings/git_bindings.dart' as git_bindings;
import 'package:meta/meta.dart';

import 'package:gitjournal/utils/logger.dart';

Future<void> cloneRemote({
  @required String repoPath,
  @required String cloneUrl,
  @required String remoteName,
  @required String sshPublicKey,
  @required String sshPrivateKey,
  @required String sshPassword,
}) async {
  var repo = await GitRepository.load(repoPath);

  // FIXME: In the case of no remotes and no commits, revert to clone?

  var remote = await repo.addOrUpdateRemote(remoteName, cloneUrl);

  var _gitRepo = git_bindings.GitRepo(folderPath: repoPath);
  await _gitRepo.fetch(
    remote: remoteName,
    publicKey: sshPublicKey,
    privateKey: sshPrivateKey,
    password: sshPassword,
  );

  var remoteBranchName = "master";
  try {
    var branch = await _gitRepo.defaultBranch(
      remote: remoteName,
      publicKey: sshPublicKey,
      privateKey: sshPrivateKey,
      password: sshPassword,
    );
    if (branch != null && branch.isNotEmpty) {
      Log.i("Got default branch: $branch");
      remoteBranchName = branch;
    }
  } catch (ex) {
    Log.w("Could not get git main branch - assuming master", ex: ex);
  }

  var remoteBranch = await repo.remoteBranch(remoteName, remoteBranchName);
  Log.i("Using remote branch: $remoteBranchName");

  var branches = await repo.branches();
  if (branches.isEmpty) {
    Log.i("Completing - no local branch");
    if (remoteBranchName != null &&
        remoteBranchName.isNotEmpty &&
        remoteBranch != null) {
      await repo.checkoutBranch(remoteBranchName, remoteBranch.hash);
    }
    await repo.setUpstreamTo(remote, remoteBranchName);
  } else {
    var branch = branches[0];

    if (branch == remoteBranchName) {
      Log.i("Completing - localBranch: $branch");

      await repo.setUpstreamTo(remote, remoteBranchName);
      await _gitRepo.merge();
    } else {
      Log.i("Completing - localBranch diff remote: $branch $remoteBranchName");

      var headRef = await repo.resolveReference(await repo.head());
      await repo.checkoutBranch(remoteBranchName, headRef.hash);
      await repo.deleteBranch(branch);
      await repo.setUpstreamTo(remote, remoteBranchName);
      await _gitRepo.merge();
    }

    // if more than one branch
    // TODO: Check if one of the branches matches the remote branch name
    //       and use that
    //       if not, then just create a new branch with the remoteBranchName
    //       and merge ..

  }
}
