// GIT_SSH_COMMAND='ssh -i private_key_file -o IdentitiesOnly=yes' git clone user@host:repo.git

import 'dart:convert';
import 'dart:io';

import 'package:dart_git/utils/file_extensions.dart';
import 'package:dart_git/utils/result.dart';

import 'package:gitjournal/utils/logger.dart';

Future<Result<void>> gitFetchViaExecutable({
  required String repoPath,
  required String privateKey,
  required String privateKeyPassword,
  required String remoteName,
}) =>
    _gitCommandViaExecutable(
      repoPath: repoPath,
      privateKey: privateKey,
      privateKeyPassword: privateKeyPassword,
      remoteName: remoteName,
      command: 'fetch',
    );

Future<Result<void>> gitPushViaExecutable({
  required String repoPath,
  required String privateKey,
  required String privateKeyPassword,
  required String remoteName,
}) =>
    _gitCommandViaExecutable(
      repoPath: repoPath,
      privateKey: privateKey,
      privateKeyPassword: privateKeyPassword,
      remoteName: remoteName,
      command: 'push',
    );

Future<Result<void>> _gitCommandViaExecutable({
  required String repoPath,
  required String privateKey,
  required String privateKeyPassword,
  required String remoteName,
  required String command,
}) async {
  assert(repoPath.startsWith('/'));
  if (privateKeyPassword.isNotEmpty) {
    var ex = Exception("SSH Keys with passwords are not supported");
    return Result.fail(ex);
  }

  var dir = Directory.systemTemp.createTempSync();
  var temp = File("${dir.path}/key");
  await temp.writeAsString(privateKey);
  await temp.chmod(int.parse('0600', radix: 8));

  Log.i("Running git $command $remoteName");
  var process = await Process.start(
    'git',
    [
      command,
      remoteName,
    ],
    workingDirectory: repoPath,
    environment: {
      'GIT_SSH_COMMAND': 'ssh -i ${temp.path} -o IdentitiesOnly=yes',
    },
    mode: ProcessStartMode.inheritStdio,
  );

  var exitCode = await process.exitCode;
  await dir.delete(recursive: true);

  if (exitCode != 0) {
    var ex = Exception("Failed to fetch, exitCode: $exitCode");
    return Result.fail(ex);
  }

  return Result(null);
}

// Default branch - git remote show origin | grep 'HEAD branch'
Future<Result<String>> gitDefaultBranchViaExecutable({
  required String repoPath,
  required String privateKey,
  required String privateKeyPassword,
  required String remoteName,
}) async {
  assert(repoPath.startsWith('/'));
  if (privateKeyPassword.isNotEmpty) {
    var ex = Exception("SSH Keys with passwords are not supported");
    return Result.fail(ex);
  }

  var dir = Directory.systemTemp.createTempSync();
  var temp = File("${dir.path}/key");
  temp.writeAsString(privateKey);

  var process = await Process.start(
    'git',
    [
      'remote',
      'show',
      remoteName,
    ],
    workingDirectory: repoPath,
    environment: {
      'GIT_SSH_COMMAND': 'ssh -i ${temp.path} -o IdentitiesOnly=yes',
    },
  );

  var exitCode = await process.exitCode;
  await dir.delete(recursive: true);

  if (exitCode != 0) {
    var ex = Exception("Failed to fetch, exitCode: $exitCode");
    return Result.fail(ex);
  }

  var stdoutB = <int>[];
  await for (var d in process.stdout) {
    stdoutB.addAll(d);
  }
  var stdout = utf8.decode(stdoutB);
  for (var line in LineSplitter.split(stdout)) {
    if (line.contains('HEAD branch:')) {
      var branch = line.split(':')[1].trim();
      // Everyone seems to default to 'main' these days
      if (branch == '(unknown)') {
        return Result('main');
      }
      return Result(branch);
    }
  }

  var ex = Exception('Default Branch not found');
  return Result.fail(ex);
}
