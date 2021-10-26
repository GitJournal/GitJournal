/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:dart_git/dart_git.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

import 'package:gitjournal/core/file/file_storage.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/link.dart';
import 'package:gitjournal/utils/link_resolver.dart';

void main() {
  late Directory tempDir;
  late String repoPath;

  late NotesFolderFS rootFolder;
  late NotesFolderConfig config;
  late FileStorage fileStorage;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('__link_resolver__');
    repoPath = tempDir.path;

    SharedPreferences.setMockInitialValues({});
    config = NotesFolderConfig('', await SharedPreferences.getInstance());
    fileStorage = await FileStorage.fake(repoPath);

    rootFolder = NotesFolderFS.root(config, fileStorage);

    await generateNote(repoPath, "Hello.md");
    await generateNote(repoPath, "Fire.md");
    await generateNote(repoPath, "Kat.md");
    await generateNote(repoPath, "Folder/Water.md");
    await generateNote(repoPath, "Folder/Kat.md");
    await generateNote(repoPath, "Folder/Sodium.md");
    await generateNote(repoPath, "Folder/Boy.md");
    await generateNote(repoPath, "Folder2/Boy.md");
    await generateNote(repoPath, "Air Bender.md");
    await generateNote(repoPath, "zeplin.txt");
    await generateNote(repoPath, "Goat  Sim.md");

    var repo = await GitRepository.load(repoPath).getOrThrow();
    await repo
        .commit(
          message: "Prepare Test Env",
          author: GitAuthor(name: 'Name', email: "name@example.com"),
          addAll: true,
        )
        .throwOnError();

    await rootFolder.fileStorage.reload().throwOnError();
    await rootFolder.loadRecursively();
  });

  tearDownAll(() async {
    tempDir.deleteSync(recursive: true);
  });

  test('[[Fire]] resolves to base folder `Fire.md`', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('[[Fire]]')!;
    expect(resolvedNote.filePath, 'Fire.md');
  });

  test('[[Fire.md]] resolves to base folder `Fire.md`', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('[[Fire.md]]')!;
    expect(resolvedNote.filePath, 'Fire.md');
  });

  test('[[Water]] resolves to `Folder/Water.md`', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('[[Water]]')!;
    expect(resolvedNote.filePath, 'Folder/Water.md');
  });

  test('[[Boy]] resolves to `Folder/Boy.md`', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    // Make sure if there are 2 Notes with the same name, the first one is resolved
    var resolvedNote = linkResolver.resolve('[[Boy]]')!;
    expect(resolvedNote.filePath, 'Folder/Boy.md');
  }, skip: true);

  test('[[Kat]] resolves to `Kat.md`', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    // Make sure if there are multiple Notes with the same name, the one is the
    // base directory is preffered
    var resolvedNote = linkResolver.resolve('[[Kat]]')!;
    expect(resolvedNote.filePath, 'Kat.md');
  }, skip: true);

  test('WikiLinks with spaces resolves correctly', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('[[Air Bender]]')!;
    expect(resolvedNote.filePath, 'Air Bender.md');
  });

  test('WikiLinks with extra spaces resolves correctly', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('[[Hello ]]')!;
    expect(resolvedNote.filePath, 'Hello.md');
  });

  test('Resolves to txt files as well', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('[[zeplin]]')!;
    expect(resolvedNote.filePath, 'zeplin.txt');
  });

  test('Non base path [[Fire]] should resolve to [[Fire.md]]', () {
    var note = rootFolder.getNoteWithSpec('Folder/Water.md')!;
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('[[Fire]]')!;
    expect(resolvedNote.filePath, 'Fire.md');
  });

  test('Non existing wiki link fails', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('[[Hello2]]');
    expect(resolvedNote, null);
  });

  test('WikiLinks with extra spaces in the middle resolves correctly', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('[[Goat  Sim]]')!;
    expect(resolvedNote.filePath, 'Goat  Sim.md');
  });

  test('Normal with extra spaces in the middle resolves correctly', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('Goat  Sim')!;
    expect(resolvedNote.filePath, 'Goat  Sim.md');
  });

  test('Normal relative link', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('./Hello.md')!;
    expect(resolvedNote.filePath, 'Hello.md');
  });

  test('Normal relative link inside a subFolder', () {
    var note = rootFolder.getNoteWithSpec('Folder/Water.md')!;
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('./Sodium.md')!;
    expect(resolvedNote.filePath, 'Folder/Sodium.md');
  });

  test('Normal relative link without ./', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('Hello.md')!;
    expect(resolvedNote.filePath, 'Hello.md');
  });

  test('Non existing relative link fails', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('Hello2.md');
    expect(resolvedNote, null);
  });

  test('Complex relative link', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('./Air Bender/../Goat  Sim.md')!;
    expect(resolvedNote.filePath, 'Goat  Sim.md');
  });

  test('Resolve Parent file', () {
    var note = rootFolder.getNoteWithSpec('Folder/Water.md')!;
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('../Hello.md')!;
    expect(resolvedNote.filePath, 'Hello.md');
  });

  test('Should resolve Link object', () {
    var note = rootFolder.getNoteWithSpec('Folder/Water.md')!;
    var linkResolver = LinkResolver(note);

    var expectedNote = rootFolder.getNoteWithSpec('Fire.md')!;
    var link = Link(
      filePath: expectedNote.filePath,
      publicTerm: 'foo',
    );

    var resolvedNote = linkResolver.resolveLink(link)!;
    expect(resolvedNote.filePath, expectedNote.filePath);
  });

  test('Should resolve Link object without extension', () {
    var note = rootFolder.getNoteWithSpec('Folder/Water.md')!;
    var linkResolver = LinkResolver(note);

    var expectedNote = rootFolder.getNoteWithSpec('Fire.md')!;
    var filePath = expectedNote.filePath;
    filePath = filePath.substring(0, filePath.length - 3);
    var link = Link(filePath: filePath, publicTerm: 'foo');

    var resolvedNote = linkResolver.resolveLink(link)!;
    expect(resolvedNote.filePath, expectedNote.filePath);
  });

  test('Should resolve Wiki Link object', () {
    var note = rootFolder.getNoteWithSpec('Folder/Water.md')!;
    var linkResolver = LinkResolver(note);

    var link = Link.wiki("Fire");
    var resolvedNote = linkResolver.resolveLink(link)!;
    expect(resolvedNote.fileName, "Fire.md");
  });
}

Future<void> generateNote(String basePath, String path) async {
  var filePath = p.join(basePath, path);

  // Ensure directory exists
  var dirPath = p.dirname(filePath);
  await Directory(dirPath).create(recursive: true);

  var content = """---
title:
modified: 2017-02-15T22:41:19+01:00
---

Hello""";

  await File(filePath).writeAsString(content, flush: true);
}
