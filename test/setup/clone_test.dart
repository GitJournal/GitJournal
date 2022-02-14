/*
 * SPDX-FileCopyrightText: 2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:io';

import 'package:dart_git/dart_git.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/setup/clone_git_exec.dart';

// import 'package:gitjournal/setup/clone_libgit2.dart';


void main() {
  Log.d("unused");

  test('Empty Repo - Default Main', () async {
    // final logsCacheDir = await Directory.systemTemp.createTemp();
    // await Log.init(cacheDir: logsCacheDir.path, ignoreFimber: false);

    var tempDir = await Directory.systemTemp.createTemp();
    var repoPath = tempDir.path;

    GitRepository.init(repoPath, defaultBranch: 'main').throwOnError();

    var cloneUrl = "https://github.com/GitJournal/empty_repo.git";

    await cloneRemote(
      repoPath: repoPath,
      cloneUrl: cloneUrl,
      remoteName: "origin",
      sshPublicKey: "",
      sshPrivateKey: "",
      sshPassword: "",
      authorName: "Author",
      authorEmail: "email@example.com",
      progressUpdate: (_) {},
    ).throwOnError();

    var repo = GitRepository.load(repoPath).getOrThrow();
    var remoteConfig = repo.config.remote('origin')!;
    expect(remoteConfig.url, cloneUrl);

    var branchConfig = repo.config.branch('main')!;
    expect(branchConfig.remote, 'origin');
    expect(branchConfig.merge!.value, 'refs/heads/main');

    repo.close().throwOnError();
  });

  test('Empty Repo - Default Master', () async {
    // final logsCacheDir = await Directory.systemTemp.createTemp();
    // await Log.init(cacheDir: logsCacheDir.path, ignoreFimber: false);

    var tempDir = await Directory.systemTemp.createTemp();
    var repoPath = tempDir.path;

    GitRepository.init(repoPath, defaultBranch: 'master').throwOnError();

    var cloneUrl = "https://github.com/GitJournal/empty_repo.git";

    await cloneRemote(
      repoPath: repoPath,
      cloneUrl: cloneUrl,
      remoteName: "origin",
      sshPublicKey: "",
      sshPrivateKey: "",
      sshPassword: "",
      authorName: "Author",
      authorEmail: "email@example.com",
      progressUpdate: (_) {},
    ).throwOnError();

    var repo = GitRepository.load(repoPath).getOrThrow();
    var remoteConfig = repo.config.remote('origin')!;
    expect(remoteConfig.url, cloneUrl);

    var branchConfig = repo.config.branch('master')!;
    expect(branchConfig.remote, 'origin');
    expect(branchConfig.merge!.value, 'refs/heads/main');

    repo.close().throwOnError();
  });

  test('Single Commit Repo - Default Main', () async {
    // final logsCacheDir = await Directory.systemTemp.createTemp();
    // await Log.init(cacheDir: logsCacheDir.path, ignoreFimber: false);

    var tempDir = await Directory.systemTemp.createTemp();
    var repoPath = tempDir.path;

    GitRepository.init(repoPath, defaultBranch: 'main').throwOnError();
    addOneCommit(repoPath);

    var cloneUrl = "https://github.com/GitJournal/empty_repo.git";

    await cloneRemote(
      repoPath: repoPath,
      cloneUrl: cloneUrl,
      remoteName: "origin",
      sshPublicKey: "",
      sshPrivateKey: "",
      sshPassword: "",
      authorName: "Author",
      authorEmail: "email@example.com",
      progressUpdate: (_) {},
    ).throwOnError();

    var repo = GitRepository.load(repoPath).getOrThrow();
    var c = repo.headCommit().getOrThrow();
    expect(c.message, "First Commit");

    var branch = repo.currentBranch().getOrThrow();
    expect(branch, 'main');

    repo.close().throwOnError();
  });

  test('Single Commit Repo - Default Master', () async {
    // final logsCacheDir = await Directory.systemTemp.createTemp();
    // await Log.init(cacheDir: logsCacheDir.path, ignoreFimber: false);

    var tempDir = await Directory.systemTemp.createTemp();
    var repoPath = tempDir.path;

    GitRepository.init(repoPath, defaultBranch: 'master').throwOnError();
    addOneCommit(repoPath);

    var cloneUrl = "https://github.com/GitJournal/empty_repo.git";

    await cloneRemote(
      repoPath: repoPath,
      cloneUrl: cloneUrl,
      remoteName: "origin",
      sshPublicKey: "",
      sshPrivateKey: "",
      sshPassword: "",
      authorName: "Author",
      authorEmail: "email@example.com",
      progressUpdate: (_) {},
    ).throwOnError();

    var repo = GitRepository.load(repoPath).getOrThrow();
    var c = repo.headCommit().getOrThrow();
    expect(c.message, "First Commit");

    var branch = repo.currentBranch().getOrThrow();
    expect(branch, 'main');

    repo.close().throwOnError();
  });
}

// test with a single commit in 'remote'
// test with a single commit in both

void addOneCommit(String repoPath) {
  var repo = GitRepository.load(repoPath).getOrThrow();

  File(p.join(repoPath, '1.md')).writeAsStringSync('1');
  repo.add('1.md').throwOnError();
  repo
      .commit(
          message: 'First Commit',
          author: GitAuthor(name: 'Test', email: 'test@example.com'))
      .throwOnError();

  repo.close().throwOnError();
}
