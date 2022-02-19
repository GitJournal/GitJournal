/*
 * SPDX-FileCopyrightText: 2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:io';

import 'package:dart_git/plumbing/git_hash.dart';
import 'package:process_run/process_run.dart';

import 'package:gitjournal/logger/logger.dart';

Future<void> runGit(String args, [String? repoPath]) async {
  Log.d('test> git $args');
  var result = await runExecutableArguments('git', args.split(' '),
      workingDirectory: repoPath);

  if (result.exitCode != 0) {
    throw Exception("Command Failed: `git $args`");
  }
}

Future<void> setupFixture(String repoPath, GitHash hash) async {
  var repo = "https://github.com/GitJournal/test_data";

  await runGit('clone $repo $repoPath');
  await runGit('checkout $hash', repoPath);
  await runGit('switch -c main', repoPath);
  await runGit('remote rm origin', repoPath);
}

Future<void> gjSetupAllTests() async {
  if (!Platform.environment.containsKey("CI")) {
    return;
  }

  final logsCacheDir = await Directory.systemTemp.createTemp();
  await Log.init(cacheDir: logsCacheDir.path, ignoreFimber: false);
}
