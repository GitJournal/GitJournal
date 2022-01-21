/*
 * SPDX-FileCopyrightText: 2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:io' as io;

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

  late GitJournalRepo repo;

  setUpAll(() async {
    // Logging
    var logsCacheDir = await io.Directory.systemTemp.createTemp();
    await Log.init(cacheDir: logsCacheDir.path, ignoreFimber: false);
  });

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

    var repoManager = RepositoryManager(
      gitBaseDir: gitBaseDir.path,
      cacheDir: cacheDir.path,
      pref: pref,
    );

    var repoId = DEFAULT_ID;
    await pref.setString("${repoId}_$FOLDER_NAME_KEY", 'test_data');

    repo = await repoManager
        .buildActiveRepository(
          loadFromCache: false,
          syncOnBoot: false,
        )
        .getOrThrow();
    await repo.reloadNotes();
  });

  tearDown(() {
    // Most of repo's methods call an unawaited task to sync + reload
    // baseDir.deleteSync(recursive: true);
  });

  test('Rename - Same Folder', () async {
    var note = repo.rootFolder.notes.firstWhere((n) => n.fileName == '1.md');

    var newPath = "1_new.md";
    var newNote = await repo.renameNote(note, newPath).getOrThrow();

    expect(newNote.filePath, newPath);
    expect(newNote.fileFormat, NoteFileFormat.Markdown);
    expect(repo.rootFolder.getAllNotes().length, 3);

    var gitRepo = GitRepository.load(repoPath).getOrThrow();
    expect(gitRepo.headHash().getOrThrow(), isNot(headHash));

    var headCommit = gitRepo.headCommit().getOrThrow();
    expect(headCommit.parents.length, 1);
    expect(headCommit.parents[0], headHash);
  });

  test('Rename - Change File Type', () async {
    var note = repo.rootFolder.notes.firstWhere((n) => n.fileName == '1.md');

    var newPath = "1_new.txt";
    var newNote = await repo.renameNote(note, newPath).getOrThrow();

    expect(newNote.filePath, newPath);
    expect(newNote.fileFormat, NoteFileFormat.Txt);
    expect(repo.rootFolder.getAllNotes().length, 3);
  });

  test('Rename - Destination Exists', () async {
    var note = repo.rootFolder.notes.firstWhere((n) => n.fileName == '1.md');

    var newPath = "2.md";
    var result = await repo.renameNote(note, newPath);
    expect(result.isFailure, true);
    expect(result.error, isA<Exception>());

    var gitRepo = GitRepository.load(repoPath).getOrThrow();
    expect(gitRepo.headHash().getOrThrow(), headHash);
  });

  test('updateNote - Basic', () async {
    var note = repo.rootFolder.notes.firstWhere((n) => n.fileName == '1.md');

    var toNote = note.resetOid();
    toNote = toNote.copyWith(body: '11');
    toNote = await repo.updateNote(note, toNote).getOrThrow();

    var gitRepo = GitRepository.load(repoPath).getOrThrow();
    expect(gitRepo.headHash().getOrThrow(), isNot(headHash));

    var headCommit = gitRepo.headCommit().getOrThrow();
    expect(headCommit.parents.length, 1);
    expect(headCommit.parents[0], headHash);

    var contents = io.File(toNote.fullFilePath).readAsStringSync();
    expect(contents, '11\n');
  });

  test('updateNote - Fails', () async {
    var note = repo.rootFolder.getNoteWithSpec('f1/3.md')!;

    var toNote = note.resetOid();
    toNote = toNote.copyWith(body: "doesn't matter");
    io.Directory(note.parent.fullFolderPath).deleteSync(recursive: true);

    var result = await repo.updateNote(note, toNote);
    expect(result.isFailure, true);
    expect(result.error, isA<Exception>());

    var gitRepo = GitRepository.load(repoPath).getOrThrow();
    expect(gitRepo.headHash().getOrThrow(), headHash);
  });

  test('addNote - Basic', () async {
    var note = Note.newNote(
      repo.rootFolder,
      fileFormat: NoteFileFormat.Markdown,
    );

    note = note.copyWith(body: '7');
    note = note.copyWithFileName('7.md');
    note = await repo.addNote(note).getOrThrow();

    var gitRepo = GitRepository.load(repoPath).getOrThrow();
    expect(gitRepo.headHash().getOrThrow(), isNot(headHash));

    var headCommit = gitRepo.headCommit().getOrThrow();
    expect(headCommit.parents.length, 1);
    expect(headCommit.parents[0], headHash);

    var contents = io.File(note.fullFilePath).readAsStringSync();
    expect(contents, '7\n');
  });

  test('addNote - Fails', () async {
    var folder = repo.rootFolder.getFolderWithSpec('f1')!;
    var note = Note.newNote(folder, fileFormat: NoteFileFormat.Markdown);

    note = note.copyWith(body: '7');
    note = note.copyWithFileName('7.md');

    io.Directory(folder.fullFolderPath).deleteSync(recursive: true);
    var result = await repo.addNote(note);
    expect(result.isFailure, true);
    expect(result.error, isA<Exception>());

    var gitRepo = GitRepository.load(repoPath).getOrThrow();
    expect(gitRepo.headHash().getOrThrow(), headHash);
  });
}

// Renames
// * Note - change content + rename
// * Note - saveNote fails because of 'x'

Future<void> _run(String args, String repoPath) async {
  await runExecutableArguments('git', args.split(' '),
      workingDirectory: repoPath);
}
