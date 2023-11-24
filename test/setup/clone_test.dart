/*
 * SPDX-FileCopyrightText: 2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:io';

import 'package:dart_git/dart_git.dart';
import 'package:gitjournal/setup/clone_git_exec.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../lib.dart';

const emptyRepoHttp = "https://github.com/GitJournal/empty_repo.git";

/// has a commit in the 'master' branch
const sinlgeCommitRepoHttp =
    "https://github.com/GitJournal/test_clone_repo.git";

const sinlgeCommitRepoGit = "git@github.com:GitJournal/test_clone_repo.git";

void main() {
  setUpAll(gjSetupAllTests);

  test('Empty Repo - Default Main', () async {
    const branch = 'master';
    var tempDir = await Directory.systemTemp.createTemp();
    var repoPath = tempDir.path;

    GitRepository.init(repoPath, defaultBranch: branch);
    await clone(repoPath, emptyRepoHttp);

    var repo = GitRepository.load(repoPath);
    var remoteConfig = repo.config.remote('origin')!;
    expect(remoteConfig.url, emptyRepoHttp);

    var branchConfig = repo.config.branch(branch)!;
    expect(branchConfig.remote, 'origin');
    expect(branchConfig.merge!.value, 'refs/heads/$branch');

    repo.close();
  });

  test('Empty Repo - Default Master', () async {
    const branch = 'master';
    var tempDir = await Directory.systemTemp.createTemp();
    var repoPath = tempDir.path;

    GitRepository.init(repoPath, defaultBranch: branch);
    await clone(repoPath, emptyRepoHttp);

    var repo = GitRepository.load(repoPath);
    var remoteConfig = repo.config.remote('origin')!;
    expect(remoteConfig.url, emptyRepoHttp);

    var branchConfig = repo.config.branch(branch)!;
    expect(branchConfig.remote, 'origin');
    expect(branchConfig.merge!.value, 'refs/heads/$branch');

    repo.close();
  });

  test('Single Commit Repo - Default Main', () async {
    var tempDir = await Directory.systemTemp.createTemp();
    var repoPath = tempDir.path;

    GitRepository.init(repoPath, defaultBranch: 'main');
    addOneCommit(repoPath);

    await clone(repoPath, emptyRepoHttp);

    var repo = GitRepository.load(repoPath);
    var c = repo.headCommit();
    expect(c.message, "First Commit");
    expect(c.parents, []);

    var branch = repo.currentBranch();
    expect(branch, 'main');

    repo.close();
  });

  test('Single Commit Repo - Default Master', () async {
    var tempDir = await Directory.systemTemp.createTemp();
    var repoPath = tempDir.path;

    GitRepository.init(repoPath, defaultBranch: 'master');
    addOneCommit(repoPath);

    await clone(repoPath, emptyRepoHttp);

    var repo = GitRepository.load(repoPath);
    var c = repo.headCommit();
    expect(c.message, "First Commit");
    expect(c.parents, []);

    var branch = repo.currentBranch();
    expect(branch, 'main');

    repo.close();
  });

  test('Empty Repo - Default Main - Non Empty Remote', () async {
    var tempDir = await Directory.systemTemp.createTemp();
    var repoPath = tempDir.path;

    GitRepository.init(repoPath, defaultBranch: 'main');
    await clone(repoPath, sinlgeCommitRepoHttp);

    var repo = GitRepository.load(repoPath);
    var remoteConfig = repo.config.remote('origin')!;
    expect(remoteConfig.url, sinlgeCommitRepoHttp);

    var branchConfig = repo.config.branch('master')!;
    expect(branchConfig.remote, 'origin');
    expect(branchConfig.merge!.value, 'refs/heads/master');

    var c = repo.headCommit();
    expect(c.message, "Initial commit");
    expect(c.parents, []);

    repo.close();
  });

  test('Empty Repo - Default Master - Non Empty Remote', () async {
    var tempDir = await Directory.systemTemp.createTemp();
    var repoPath = tempDir.path;

    GitRepository.init(repoPath, defaultBranch: 'master');
    await clone(repoPath, sinlgeCommitRepoHttp);

    var repo = GitRepository.load(repoPath);
    var remoteConfig = repo.config.remote('origin')!;
    expect(remoteConfig.url, sinlgeCommitRepoHttp);

    var branchConfig = repo.config.branch('master')!;
    expect(branchConfig.remote, 'origin');
    expect(branchConfig.merge!.value, 'refs/heads/master');

    var c = repo.headCommit();
    expect(c.message, "Initial commit");
    expect(c.parents, []);

    repo.close();
  });

  test('Single Commit Both - Default Master', () async {
    var tempDir = await Directory.systemTemp.createTemp();
    var repoPath = tempDir.path;

    GitRepository.init(repoPath, defaultBranch: 'master');
    addOneCommit(repoPath);

    await clone(repoPath, sinlgeCommitRepoHttp);

    var repo = GitRepository.load(repoPath);
    var c = repo.headCommit();
    expect(c.message, "Merge origin/master");
    expect(c.parents.isNotEmpty, true);

    var tree = repo.objStorage.readTree(c.treeHash);
    expect(tree.entries.length, 2);
    expect(tree.entries[0].name, '1.md');
    expect(tree.entries[1].name, 'README.md');

    var branch = repo.currentBranch();
    expect(branch, 'master');

    repo.close();
  });

  test('Single Commit Both - Default main', () async {
    var tempDir = await Directory.systemTemp.createTemp();
    var repoPath = tempDir.path;

    GitRepository.init(repoPath, defaultBranch: 'main');
    addOneCommit(repoPath);

    await clone(repoPath, sinlgeCommitRepoHttp);

    var repo = GitRepository.load(repoPath);
    var c = repo.headCommit();
    expect(c.message, "Merge origin/master");
    expect(c.parents.isNotEmpty, true);

    var tree = repo.objStorage.readTree(c.treeHash);
    expect(tree.entries.length, 2);
    expect(tree.entries[0].name, '1.md');
    expect(tree.entries[1].name, 'README.md');

    var branch = repo.currentBranch();
    expect(branch, 'master');

    repo.close();
  });

  // This is being skipped as it's using keys from my osx machine
  test('Clone Repo with SSH', () async {
    var tempDir = await Directory.systemTemp.createTemp();
    var repoPath = tempDir.path;

    GitRepository.init(repoPath, defaultBranch: 'main');

    var public = File("/Users/vishesh/.ssh/id_ed25519.pub").readAsStringSync();
    var private = File("/Users/vishesh/.ssh/id_ed25519").readAsStringSync();

    await cloneRemote(
      repoPath: repoPath,
      cloneUrl: sinlgeCommitRepoGit,
      remoteName: "origin",
      sshPublicKey: public,
      sshPrivateKey: private,
      sshPassword: "",
      authorName: "Author",
      authorEmail: "email@example.com",
      progressUpdate: (_) {},
    );

    var repo = GitRepository.load(repoPath);
    var remoteConfig = repo.config.remote('origin')!;
    expect(remoteConfig.url, sinlgeCommitRepoGit);

    var branchConfig = repo.config.branch('master')!;
    expect(branchConfig.remote, 'origin');
    expect(branchConfig.merge!.value, 'refs/heads/master');

    repo.close();
  }, skip: true);
}

Future<void> clone(String repoPath, String url) async {
  await cloneRemote(
    repoPath: repoPath,
    cloneUrl: url,
    remoteName: "origin",
    sshPublicKey: "",
    sshPrivateKey: "",
    sshPassword: "",
    authorName: "Author",
    authorEmail: "email@example.com",
    progressUpdate: (_) {},
  );
}

void addOneCommit(String repoPath) {
  var repo = GitRepository.load(repoPath);

  File(p.join(repoPath, '1.md')).writeAsStringSync('1');
  repo.add('1.md');
  repo.commit(
      message: 'First Commit',
      author: GitAuthor(name: 'Test', email: 'test@example.com'));

  repo.close();
}
