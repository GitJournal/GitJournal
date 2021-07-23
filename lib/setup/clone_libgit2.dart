import 'package:dart_git/utils/result.dart';
import 'package:function_types/function_types.dart';
import 'package:git_bindings/git_bindings.dart' as git_bindings;

import 'clone.dart';

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
}) =>
    cloneRemotePluggable(
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
    );

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
  } on Exception catch (e, st) {
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
    if (branch != null && branch.isNotEmpty) {
      return Result(branch);
    }
  } on Exception catch (e, st) {
    return Result.fail(e, st);
  }

  var ex = Exception("No Remote Branch found");
  return Result.fail(ex);
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
  } on Exception catch (e, st) {
    return Result.fail(e, st);
  }

  return Result(null);
}
