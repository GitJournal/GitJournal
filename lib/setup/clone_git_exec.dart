/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:dart_git/dart_git.dart';
import 'package:dart_git/utils/result.dart';
import 'package:function_types/function_types.dart';

import 'package:gitjournal/utils/git_desktop.dart';
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
) {
  // FIXME: Stop ignoring the statusFile
  return gitFetchViaExecutable(
    repoPath: repoPath,
    privateKey: sshPrivateKey,
    privateKeyPassword: sshPassword,
    remoteName: remoteName,
  );
}

Future<Result<String>> _defaultBranch(
  String repoPath,
  String remoteName,
  String sshPublicKey,
  String sshPrivateKey,
  String sshPassword,
) {
  return gitDefaultBranchViaExecutable(
    repoPath: repoPath,
    privateKey: sshPrivateKey,
    privateKeyPassword: sshPassword,
    remoteName: remoteName,
  );
}

Future<Result<void>> _merge(
  String repoPath,
  String remoteName,
  String remoteBranchName,
  String authorName,
  String authorEmail,
) {
  return catchAll(() async {
    var repo = await GitRepository.load(repoPath).getOrThrow();
    var author = GitAuthor(name: authorName, email: authorEmail);
    await repo.mergeCurrentTrackingBranch(author: author).throwOnError();
    return Result(null);
  });
}
