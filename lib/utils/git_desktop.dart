/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

// GIT_SSH_COMMAND='ssh -i private_key_file -o IdentitiesOnly=yes' git clone user@host:repo.git

import 'dart:convert';

import 'package:dart_git/utils/file_extensions.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:universal_io/io.dart';

Future<void> gitFetchViaExecutable({
  required String repoPath,
  required String privateKey,
  required String privateKeyPassword,
  required String remoteName,
}) =>
    _gitCommandViaExecutable(
      repoPath: repoPath,
      privateKey: privateKey,
      privateKeyPassword: privateKeyPassword,
      args: ["fetch", remoteName],
    );

Future<void> gitCloneViaExecutable({
  required String cloneUrl,
  required String repoPath,
  required String privateKey,
  required String privateKeyPassword,
}) =>
    _gitCommandViaExecutable(
      repoPath: null,
      privateKey: privateKey,
      privateKeyPassword: privateKeyPassword,
      args: ["clone", cloneUrl, repoPath],
    );

Future<void> gitPushViaExecutable({
  required String repoPath,
  required String privateKey,
  required String privateKeyPassword,
  required String remoteName,
}) =>
    _gitCommandViaExecutable(
      repoPath: repoPath,
      privateKey: privateKey,
      privateKeyPassword: privateKeyPassword,
      args: ["push", remoteName],
    );

Future<void> _gitCommandViaExecutable({
  required String? repoPath,
  required String privateKey,
  required String privateKeyPassword,
  required List<String> args,
}) async {
  if (repoPath != null) assert(repoPath.startsWith('/'));
  if (privateKeyPassword.isNotEmpty) {
    throw Exception("SSH Keys with passwords are not supported");
  }

  var dir = Directory.systemTemp.createTempSync();
  var temp = File("${dir.path}/key");
  await temp.writeAsString(privateKey);
  temp.chmodSync(int.parse('0600', radix: 8));

  Log.i("Running git ${args.join(' ')}");
  var process = await Process.start(
    'git',
    args,
    workingDirectory: repoPath,
    environment: {
      if (privateKey.isNotEmpty)
        'GIT_SSH_COMMAND': 'ssh -i ${temp.path} -o IdentitiesOnly=yes',
    },
  );

  Log.d('env GIT_SSH_COMMAND="ssh -i ${temp.path} -o IdentitiesOnly=yes"');
  Log.d("git ${args.join(' ')}");

  var exitCode = await process.exitCode;
  await dir.delete(recursive: true);

  var stdoutB = <int>[];
  await for (var d in process.stdout) {
    stdoutB.addAll(d);
  }
  var stdout = utf8.decode(stdoutB);

  if (exitCode != 0) {
    var ex = Exception("Failed to fetch - $stdout - exitCode: $exitCode");
    throw ex;
  }
}

// Default branch - git remote show origin | grep 'HEAD branch'
Future<String> gitDefaultBranchViaExecutable({
  required String repoPath,
  required String privateKey,
  required String privateKeyPassword,
  required String remoteName,
}) async {
  assert(repoPath.startsWith('/'));
  if (privateKeyPassword.isNotEmpty) {
    var ex = Exception("SSH Keys with passwords are not supported");
    throw ex;
  }

  var dir = Directory.systemTemp.createTempSync();
  var temp = File("${dir.path}/key");
  await temp.writeAsString(privateKey);
  temp.chmodSync(int.parse('0600', radix: 8));

  var process = await Process.start(
    'git',
    [
      'remote',
      'show',
      remoteName,
    ],
    workingDirectory: repoPath,
    environment: {
      if (privateKey.isNotEmpty)
        'GIT_SSH_COMMAND': 'ssh -i ${temp.path} -o IdentitiesOnly=yes',
    },
  );

  Log.d('env GIT_SSH_COMMAND="ssh -i ${temp.path} -o IdentitiesOnly=yes"');
  Log.d('git remote show $remoteName');

  var exitCode = await process.exitCode;
  await dir.delete(recursive: true);

  if (exitCode != 0) {
    var ex = Exception("Failed to fetch default branch, exitCode: $exitCode");
    throw ex;
  }

  var stdoutB = <int>[];
  await for (var d in process.stdout) {
    stdoutB.addAll(d);
  }
  var stdout = utf8.decode(stdoutB);
  for (var line in LineSplitter.split(stdout)) {
    if (line.contains('HEAD branch:')) {
      var branch = line.split(':')[1].trim();
      if (branch == '(unknown)') {
        return DEFAULT_BRANCH;
      }
      return branch;
    }
  }

  var ex = Exception('Default Branch not found');
  throw ex;
}
