/*
 * SPDX-FileCopyrightText: 2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:io' as io;

import 'package:dart_git/dart_git.dart';
import 'package:dart_git/plumbing/git_hash.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:universal_io/io.dart' as io;

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/settings/settings.dart';
import 'lib.dart';

Future<void> main() async {
  late String repoPath;

  final headHash = GitHash('c8a879a4a9c27abcc27a4d2ee2b2ba0aad5fc940');
  late GitJournalRepo repo;

  setUpAll(gjSetupAllTests);

  Future<void> _setup({
    GitHash? head,
    Map<String, Object> sharedPrefValues = const {},
  }) async {
    var td = await TestData.load(
      headHash: head ?? headHash,
      sharedPrefValues: sharedPrefValues,
    );

    repoPath = td.repoPath;
    repo = td.repo;
  }

  tearDown(() {
    // Most of repo's methods call an unawaited task to sync + reload
    // baseDir.deleteSync(recursive: true);
  });

  test('Rename - Same Folder', () async {
    await _setup();
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
    await _setup();
    var note = repo.rootFolder.notes.firstWhere((n) => n.fileName == '1.md');

    var newPath = "1_new.txt";
    var newNote = await repo.renameNote(note, newPath).getOrThrow();

    expect(newNote.filePath, newPath);
    expect(newNote.fileFormat, NoteFileFormat.Txt);
    expect(repo.rootFolder.getAllNotes().length, 3);
  });

  test('Rename - Destination Exists', () async {
    await _setup();
    var note = repo.rootFolder.notes.firstWhere((n) => n.fileName == '1.md');

    var newPath = "2.md";
    var result = await repo.renameNote(note, newPath);
    expect(result.isFailure, true);
    expect(result.error, isA<Exception>());

    var gitRepo = GitRepository.load(repoPath).getOrThrow();
    expect(gitRepo.headHash().getOrThrow(), headHash);
  });

  test('updateNote - Basic', () async {
    await _setup();
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
    await _setup();
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
    await _setup();
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
    expect(contents.contains('7\n'), true);
  });

  test('addNote - Fails', () async {
    await _setup();
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

  test('Outside Changes', () async {
    var extDir = await io.Directory.systemTemp.createTemp();
    var pref = <String, Object>{
      "${DEFAULT_ID}_storeInternally": false,
      "${DEFAULT_ID}_storageLocation": extDir.path,
    };

    await setupFixture(p.join(extDir.path, "test_data"), headHash);
    await _setup(sharedPrefValues: pref);

    var note = repo.rootFolder.getNoteWithSpec('1.md')!;
    io.File(note.fullFilePath).writeAsStringSync('foo');

    var repoManager = repo.repoManager;
    var newRepo = await repoManager
        .buildActiveRepository(loadFromCache: false, syncOnBoot: false)
        .getOrThrow();
    await newRepo.reloadNotes();

    var repoPath = newRepo.repoPath;
    var newNote = newRepo.rootFolder.getNoteWithSpec('1.md')!;
    expect(newNote.oid, isNot(note.oid));
    // expect(newNote.created, note.created);
    expect(newNote.body, 'foo');
    expect(newNote, isNot(note));

    var gitRepo = GitRepository.load(repoPath).getOrThrow();
    expect(gitRepo.headHash().getOrThrow(), isNot(headHash));

    var headCommit = gitRepo.headCommit().getOrThrow();
    expect(headCommit.parents.length, 1);
    expect(headCommit.parents[0], headHash);
  });

  test('updateNote - created metadata stays the same', () async {
    var headHash = GitHash('38e8c9150c0c004c9f72221ac7c19cf770575545');
    await _setup(head: headHash);

    var note = repo.rootFolder.getNoteWithSpec('doc.md')!;
    var toNote = note.resetOid();

    expect(toNote.created, note.created);
    toNote = await repo.updateNote(note, toNote).getOrThrow();

    var gitRepo = GitRepository.load(repoPath).getOrThrow();
    expect(gitRepo.headHash().getOrThrow(), isNot(headHash));

    var headCommit = gitRepo.headCommit().getOrThrow();
    expect(headCommit.parents.length, 1);
    expect(headCommit.parents[0], headHash);

    expect(toNote.created, note.created);
    expect(toNote.modified.isAfter(note.modified), true);
  });

  test('Move - Note from root to Folder', () async {
    await _setup();
    var note = repo.rootFolder.getNoteWithSpec('1.md')!;
    var folder = repo.rootFolder.getFolderWithSpec('f1')!;

    var r = await repo.moveNote(note, folder);
    expect(r.isSuccess, true);
    expect(r.isFailure, false);

    var gitRepo = GitRepository.load(repoPath).getOrThrow();
    expect(gitRepo.headHash().getOrThrow(), isNot(headHash));

    var headCommit = gitRepo.headCommit().getOrThrow();
    expect(headCommit.parents.length, 1);
    expect(headCommit.parents[0], headHash);

    var root = repo.rootFolder;
    expect(root.getNoteWithSpec('1.md'), null);
    expect(root.getNoteWithSpec('f1/1.md'), isNotNull);
  });

  test('Move - Note from Folder to Root', () async {
    await _setup();
    var note = repo.rootFolder.getNoteWithSpec('f1/3.md')!;
    var folder = repo.rootFolder;

    var r = await repo.moveNote(note, folder);
    expect(r.isSuccess, true);
    expect(r.isFailure, false);

    var gitRepo = GitRepository.load(repoPath).getOrThrow();
    expect(gitRepo.headHash().getOrThrow(), isNot(headHash));

    var headCommit = gitRepo.headCommit().getOrThrow();
    expect(headCommit.parents.length, 1);
    expect(headCommit.parents[0], headHash);

    var root = repo.rootFolder;
    expect(root.getNoteWithSpec('f1/3.md'), null);
    expect(root.getNoteWithSpec('3.md'), isNotNull);
  });

  test('Move - To New Folder', () async {
    await _setup();
    var note = repo.rootFolder.getNoteWithSpec('1.md')!;
    var folder = repo.rootFolder.getOrBuildFolderWithSpec('f2');
    folder.create();

    var r = await repo.moveNote(note, folder);
    expect(r.isSuccess, true);
    expect(r.isFailure, false);

    var gitRepo = GitRepository.load(repoPath).getOrThrow();
    expect(gitRepo.headHash().getOrThrow(), isNot(headHash));

    var headCommit = gitRepo.headCommit().getOrThrow();
    expect(headCommit.parents.length, 1);
    expect(headCommit.parents[0], headHash);

    var root = repo.rootFolder;
    expect(root.getNoteWithSpec('1.md'), null);
    expect(root.getNoteWithSpec('f2/1.md'), isNotNull);
  });

  test('Move - To New Folder Failure', () async {
    await _setup();
    var note = repo.rootFolder.getNoteWithSpec('1.md')!;
    var folder = repo.rootFolder.getOrBuildFolderWithSpec('f2');

    var r = await repo.moveNote(note, folder);
    expect(r.isFailure, true);

    var gitRepo = GitRepository.load(repoPath).getOrThrow();
    expect(gitRepo.headHash().getOrThrow(), headHash);

    var root = repo.rootFolder;
    expect(root.getNoteWithSpec('1.md'), isNotNull);
    expect(root.getNoteWithSpec('f2/1.md'), isNull);
  });

  test('Move - From one folder to another folder', () async {
    var headHash = GitHash('7fc65b59170bdc91013eb56cdc65fa3307f2e7de');
    await _setup(head: headHash);
    var note = repo.rootFolder.getNoteWithSpec('f1/3.md')!;
    var folder = repo.rootFolder.getFolderWithSpec('f2')!;

    var r = await repo.moveNote(note, folder);
    expect(r.isSuccess, true);
    expect(r.isFailure, false);

    var gitRepo = GitRepository.load(repoPath).getOrThrow();
    expect(gitRepo.headHash().getOrThrow(), isNot(headHash));

    var headCommit = gitRepo.headCommit().getOrThrow();
    expect(headCommit.parents.length, 1);
    expect(headCommit.parents[0], headHash);

    var root = repo.rootFolder;
    expect(root.getNoteWithSpec('f1/3.md'), null);
    expect(root.getNoteWithSpec('f2/3.md'), isNotNull);
  });

  test('Add a tag', () async {
    var headHash = GitHash('7fc65b59170bdc91013eb56cdc65fa3307f2e7de');
    await _setup(head: headHash);

    var note = repo.rootFolder.getNoteWithSpec('doc.md')!;
    var updatedNote = note.resetOid();
    updatedNote = updatedNote.copyWith(tags: {"Foo"}.lock);

    var r = await repo.updateNote(note, updatedNote);
    expect(r.isSuccess, true);
    expect(r.isFailure, false);

    var note2 = r.getOrThrow();
    expect(note2.tags, {"Foo"});
    expect(note2.data.props.containsKey("tags"), true);

    var gitRepo = GitRepository.load(repoPath).getOrThrow();
    expect(gitRepo.headHash().getOrThrow(), isNot(headHash));

    var headCommit = gitRepo.headCommit().getOrThrow();
    expect(headCommit.parents.length, 1);
    expect(headCommit.parents[0], headHash);
  });
}

// Renames
// * Note - change content + rename
// * Note - saveNote fails because of 'x'
// move - ensure that destination cannot exist (and the git repo is in a good state after that)
