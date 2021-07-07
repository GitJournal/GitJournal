// GIT_SSH_COMMAND='ssh -i private_key_file -o IdentitiesOnly=yes' git clone user@host:repo.git

import 'dart:io' show Directory, File, Process, ProcessStartMode;

import 'package:dart_git/utils/result.dart';

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
  temp.writeAsString(privateKey);

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
