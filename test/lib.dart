/*
 * SPDX-FileCopyrightText: 2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:io';

import 'package:dart_git/plumbing/git_hash.dart';
import 'package:dart_git/utils/result.dart';
import 'package:path/path.dart' as p;
import 'package:process_run/process_run.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/storage_config.dart';

final inCI = Platform.environment.containsKey("CI");

Future<void> runGit(String args, [String? repoPath]) async {
  var result = await runExecutableArguments('git', args.split(' '),
      workingDirectory: repoPath, verbose: inCI);

  if (result.exitCode != 0) {
    throw Exception("Command Failed: `git $args`");
  }
}

Future<void> setupFixture(String repoPath, GitHash hash) async {
  var repo = "https://github.com/GitJournal/test_data";

  await runGit('clone $repo $repoPath');
  await runGit('checkout -b main $hash', repoPath);
  await runGit('remote rm origin', repoPath);
}

Future<void> gjSetupAllTests() async {
  if (!inCI) {
    return;
  }

  final logsCacheDir = await Directory.systemTemp.createTemp();
  await Log.init(cacheDir: logsCacheDir.path, ignoreFimber: false);

  await runGit('version');
}

class TestData {
  final Directory baseDir;
  final String repoPath;
  final SharedPreferences pref;
  final GitJournalRepo repo;
  final RepositoryManager repoManager;

  TestData._(
      this.baseDir, this.repoPath, this.pref, this.repo, this.repoManager);

  static Future<TestData> load({
    required GitHash headHash,
    Map<String, Object> sharedPrefValues = const {},
  }) async {
    var baseDir = Directory.systemTemp.createTempSync();
    var cacheDir = Directory(p.join(baseDir.path, 'cache'))..createSync();
    var gitBaseDir = Directory(p.join(baseDir.path, 'repos'))..createSync();

    var repoPath = p.join(gitBaseDir.path, "test_data");
    await setupFixture(repoPath, headHash);

    SharedPreferences.setMockInitialValues(sharedPrefValues);
    var pref = await SharedPreferences.getInstance();

    var repoManager = RepositoryManager(
      gitBaseDir: gitBaseDir.path,
      cacheDir: cacheDir.path,
      pref: pref,
    );

    var repoId = DEFAULT_ID;
    await pref.setString("${repoId}_$FOLDER_NAME_KEY", 'test_data');

    var repo = await repoManager
        .buildActiveRepository(
          loadFromCache: false,
          syncOnBoot: false,
        )
        .getOrThrow();
    await repo.reloadNotes();

    return TestData._(baseDir, repoPath, pref, repo, repoManager);
  }
}
