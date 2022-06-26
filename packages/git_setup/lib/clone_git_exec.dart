/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:dart_git/dart_git.dart';
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
      gitCloneFn: _clone,
      gitFetchFn: _fetch,
      defaultBranchFn: _defaultBranch,
    ),
  );
}

Future<Result<void>> _clone({
  required String cloneUrl,
  required String repoPath,
  required String sshPublicKey,
  required String sshPrivateKey,
  required String sshPassword,
  required String statusFile,
}) async {
  // FIXME: Stop ignoring the statusFile
  return gitCloneViaExecutable(
    repoPath: repoPath,
    cloneUrl: cloneUrl,
    privateKey: sshPrivateKey,
    privateKeyPassword: sshPassword,
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
