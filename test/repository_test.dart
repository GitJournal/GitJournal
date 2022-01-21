/*
 * SPDX-FileCopyrightText: 2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:dart_git/dart_git.dart';
import 'package:dart_git/plumbing/git_hash.dart';
import 'package:path/path.dart' as p;
import 'package:process_run/process_run.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart' as io;

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/storage_config.dart';

Future<void> main() async {
  late io.Directory baseDir;
  late String repoPath;
  late SharedPreferences pref;

  final headHash = GitHash('c8a879a4a9c27abcc27a4d2ee2b2ba0aad5fc940');

  late final GitJournalRepo repo;

  setUp(() async {
    baseDir = await io.Directory.systemTemp.createTemp();
    var cacheDir = await io.Directory(p.join(baseDir.path, 'cache')).create();
    var gitBaseDir = await io.Directory(p.join(baseDir.path, 'repos')).create();

    await runExecutableArguments(
      'git',
      ["clone", "https://github.com/GitJournal/test_data"],
      workingDirectory: gitBaseDir.path,
    );

    repoPath = p.join(gitBaseDir.path, "test_data");

    await _run('checkout $headHash', repoPath);
    await _run('switch -c main', repoPath);
    await _run('remote rm origin', repoPath);

    SharedPreferences.setMockInitialValues({});
    pref = await SharedPreferences.getInstance();

    await Log.init(cacheDir: cacheDir.path, ignoreFimber: false);

    var repoManager = RepositoryManager(
      gitBaseDir: gitBaseDir.path,
      cacheDir: cacheDir.path,
      pref: pref,
    );

    var repoId = DEFAULT_ID;
    await pref.setString("${repoId}_$FOLDER_NAME_KEY", 'test_data');

    repo = await repoManager.buildActiveRepository().getOrThrow();
    await repo.reloadNotes();
  });

  tearDown(() {
    baseDir.deleteSync(recursive: true);
  });

  test('Rename - Same Folder', () async {
    var note = repo.rootFolder.notes.firstWhere((n) => n.fileName == '1.md');

    var newPath = "1_new.md";
    var newNote = await repo.renameNote(note, newPath);

    expect(newNote.filePath, newPath);
    expect(newNote.fileFormat, NoteFileFormat.Markdown);
    expect(repo.rootFolder.getAllNotes().length, 3);

    var gitRepo = GitRepository.load(repoPath).getOrThrow();
    expect(gitRepo.headHash(), isNot(headHash));

    var headCommit = gitRepo.headCommit().getOrThrow();
    expect(headCommit.parents.length, 1);
    expect(headCommit.parents[0], headHash);
  });

  // test('Rename - Change File Type', () async {
  //   var note = repo.rootFolder.notes.firstWhere((n) => n.fileName == '1.md');

  //   var newPath = "1_new.txt";
  //   var newNote = await repo.renameNote(note, newPath);

  //   expect(newNote.filePath, newPath);
  //   expect(newNote.fileFormat, NoteFileFormat.Txt);
  //   expect(repo.rootFolder.getAllNotes().length, 3);
  // });
}

// Renames
// * Note - folder doesn't exist
// * Note - different folder
// * Note - another note exists with same path
// * Note - change content + rename
// * Note - change file type

Future<void> _run(String args, String repoPath) async {
  await runExecutableArguments('git', args.split(' '),
      workingDirectory: repoPath);
}
