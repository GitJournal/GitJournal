/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:gitjournal/core/file/file.dart';
import 'package:gitjournal/core/file/file_storage.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/note_storage.dart';
import 'package:gitjournal/core/notes/note.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart' as io;

import 'lib.dart';

void main() {
  late String repoPath;
  late io.Directory tempDir;
  late NotesFolderConfig config;
  late FileStorage fileStorage;

  final gitDt = DateTime.now();

  setUpAll(() async {
    tempDir = await io.Directory.systemTemp.createTemp('__notes_test__');
    repoPath = tempDir.path + p.separator;

    SharedPreferences.setMockInitialValues({});
    config = NotesFolderConfig('', await SharedPreferences.getInstance());
    fileStorage = await FileStorage.fake(repoPath);

    await gjSetupAllTests();
  });

  tearDownAll(() async {
    tempDir.deleteSync(recursive: true);
  });

  test('Should respect modified key as modified', () async {
    var content = """---
bar: Foo
modified: 2017-02-15T22:41:19+01:00
---

Hello
""";

    var noteFullPath = p.join(repoPath, "note.md");
    await io.File(noteFullPath).writeAsString(content);

    var parentFolder = NotesFolderFS.root(config, fileStorage);
    var file = File.short("note.md", repoPath, gitDt);
    var note = await NoteStorage.load(file, parentFolder);
    expect(note.canHaveMetadata, true);

    note = note.copyWith(
      modified: DateTime.utc(2019, 12, 02, 4, 0, 0),
      file: note.file.copyFile(oid: GitHash.zero()),
    );
    note = await NoteStorage.save(note);

    var expectedContent = """---
bar: Foo
modified: 2019-12-02T04:00:00+00:00
---

Hello
""";

    var actualContent = io.File(noteFullPath).readAsStringSync();
    expect(actualContent, equals(expectedContent));
  });

  test('Should respect modified key as mod', () async {
    var content = """---
bar: Foo
mod: 2017-02-15T22:41:19+01:00
---

Hello
""";

    var noteFullPath = p.join(repoPath, "note.md");
    await io.File(noteFullPath).writeAsString(content);

    var parentFolder = NotesFolderFS.root(config, fileStorage);
    var file = File.short("note.md", repoPath, gitDt);
    var note = await NoteStorage.load(file, parentFolder);

    note = note.copyWith(
      modified: DateTime.utc(2019, 12, 02, 4, 0, 0),
      file: note.file.copyFile(oid: GitHash.zero()),
    );

    await NoteStorage.save(note);

    var expectedContent = """---
bar: Foo
mod: 2019-12-02T04:00:00+00:00
---

Hello
""";

    var actualContent = io.File(noteFullPath).readAsStringSync();
    expect(actualContent, equals(expectedContent));
  });

  test('Should read and write tags', () async {
    var content = """---
bar: Foo
tags: [A, B]
---

Hello
""";

    var noteFullPath = p.join(repoPath, "note5.md");
    await io.File(noteFullPath).writeAsString(content);

    var parentFolder = NotesFolderFS.root(config, fileStorage);
    var file = File.short("note5.md", repoPath, gitDt);
    var note = await NoteStorage.load(file, parentFolder);

    expect(note.tags.contains('A'), true);
    expect(note.tags.contains('B'), true);
    expect(note.tags.length, 2);

    note = note.copyWith(
      tags: {'A', 'C', 'D'}.lock,
      file: note.file.copyFile(oid: GitHash.zero()),
    );
    await NoteStorage.save(note);

    var expectedContent = """---
bar: Foo
tags: [A, C, D]
---

Hello
""";

    var actualContent = io.File(noteFullPath).readAsStringSync();
    expect(actualContent, equals(expectedContent));
  });

  test('Should parse links', () async {
    var content = """---
bar: Foo
---

[Hi](./foo.md)
[Hi2](./po/../food.md)
[Web](http://example.com)
""";

    var noteFullPath = p.join(repoPath, "note6.md");
    await io.File(noteFullPath).writeAsString(content);

    var parentFolder = NotesFolderFS.root(config, fileStorage);
    var file = File.short("note6.md", repoPath, gitDt);
    var note = await NoteStorage.load(file, parentFolder);
    parentFolder.add(note);

    var linksOrNull = []; // await note.fetchLinks();
    var links = linksOrNull;
    expect(links[0].filePath, p.join(repoPath, "foo.md"));
    expect(links[0].publicTerm, "Hi");

    expect(links[1].filePath, p.join(repoPath, "food.md"));
    expect(links[1].publicTerm, "Hi2");

    expect(links.length, 2);
  }, skip: true);

  test('Should parse wiki style links', () async {
    var content = "[[GitJournal]] needs some [[Wild Fire]]\n";

    var noteFullPath = p.join(repoPath, "note63.md");
    await io.File(noteFullPath).writeAsString(content);

    var parentFolder = NotesFolderFS.root(config, fileStorage);
    var file = File.short("note63.md", repoPath, gitDt);
    var note = await NoteStorage.load(file, parentFolder);
    parentFolder.add(note);

    var linksOrNull = []; //await note.fetchLinks();
    var links = linksOrNull;
    expect(links[0].isWikiLink, true);
    expect(links[0].wikiTerm, "GitJournal");

    expect(links[1].isWikiLink, true);
    expect(links[1].wikiTerm, "Wild Fire");

    expect(links.length, 2);
  }, skip: true);

  test('Should detect file format', () async {
    var content = """---
bar: Foo
---

Gee
""";

    var noteFullPath = p.join(repoPath, "note16.md");
    await io.File(noteFullPath).writeAsString(content);

    var parentFolder = NotesFolderFS.root(config, fileStorage);
    var file = File.short("note16.md", repoPath, gitDt);
    var note = await NoteStorage.load(file, parentFolder);
    parentFolder.add(note);

    expect(note.fileFormat, NoteFileFormat.Markdown);

    //
    // Txt files
    //
    var txtNotePath = p.join(repoPath, "note16.txt");
    await io.File(txtNotePath).writeAsString(content);

    var txtFile = File.short("note16.txt", repoPath, gitDt);
    var txtNote = await NoteStorage.load(txtFile, parentFolder);

    expect(txtNote.fileFormat, NoteFileFormat.Txt);
    expect(txtNote.canHaveMetadata, false);
    expect(txtNote.title, null);
    expect(txtNote.body, content);
  });

  test('New Notes have a file extension', () async {
    var parentFolder = NotesFolderFS.root(config, fileStorage);
    var note = Note.newNote(parentFolder, fileFormat: NoteFileFormat.Markdown);
    var path = note.filePath;

    expect(p.extension(path), '.md');
    expect(p.withoutExtension(path).isNotEmpty, true);
  });

  test('Txt files header is not read', () async {
    var content = """# Hello

Gee
""";
    var txtNotePath = p.join(repoPath, "note163.txt");
    await io.File(txtNotePath).writeAsString(content);

    var parentFolder = NotesFolderFS.root(config, fileStorage);
    var txtFile = File.short("note163.txt", repoPath, gitDt);
    var txtNote = await NoteStorage.load(txtFile, parentFolder);

    expect(txtNote.fileFormat, NoteFileFormat.Txt);
    expect(txtNote.canHaveMetadata, false);
    expect(txtNote.title, null);
    expect(txtNote.body, content);
  });

  test('Ensure title is null', () async {
    var content = """---
created: 2019-11-29T01:37:26+01:00
pinned: true
modified: 2021-10-16T12:15:35+02:00
---

Isn't it time you write;
""";

    var noteFullPath = p.join(repoPath, "note.md");
    await io.File(noteFullPath).writeAsString(content);

    var parentFolder = NotesFolderFS.root(config, fileStorage);
    var file = File.short("note.md", repoPath, gitDt);
    var note = await NoteStorage.load(file, parentFolder);

    expect(note.title, null);
  });

  test('Dendron FrontMatter', () async {
    var content = """---
bar: Foo
updated: 1626257689
created: 1626257689
---

Hello
""";

    var noteFullPath = p.join(repoPath, "note.md");
    await io.File(noteFullPath).writeAsString(content);

    var parentFolder = NotesFolderFS.root(config, fileStorage);
    var file = File.short("note.md", repoPath, gitDt);
    var note = await NoteStorage.load(file, parentFolder);
    parentFolder.add(note);

    expect(note.modified, DateTime.parse('2021-07-14T10:14:49Z'));
    expect(note.created, DateTime.parse('2021-07-14T10:14:49Z'));

    note = note.copyWith(
      created: DateTime.parse('2020-06-13T10:14:49Z'),
      modified: DateTime.parse('2020-07-14T10:14:49Z'),
      file: note.file.copyFile(oid: GitHash.zero()),
    );

    var expectedContent = """---
bar: Foo
updated: 1594721689
created: 1592043289
---

Hello
""";

    await NoteStorage.save(note);

    var actualContent = io.File(noteFullPath).readAsStringSync();
    expect(actualContent, equals(expectedContent));
  });

  test('Date Only FrontMatter', () async {
    var content = """---
bar: Foo
modified: 2022-07-14
created: 2024-07-14
---

Hello
""";

    var noteFullPath = p.join(repoPath, "note.md");
    await io.File(noteFullPath).writeAsString(content);

    var parentFolder = NotesFolderFS.root(config, fileStorage);
    var file = File.short("note.md", repoPath, gitDt);
    var note = await NoteStorage.load(file, parentFolder);
    parentFolder.add(note);

    // Doing this to avoid timezone issues
    expect(note.modified.year, 2022);
    expect(note.modified.month, 7);
    expect(note.modified.day, 14);

    expect(note.created.year, 2024);
    expect(note.created.month, 7);
    expect(note.created.day, 14);

    note = note.copyWith(
      modified: DateTime.parse('2022-08-15'),
      created: DateTime.parse('2024-08-15'),
      file: note.file.copyFile(oid: GitHash.zero()),
    );

    var expectedContent = """---
bar: Foo
modified: 2022-08-15
created: 2024-08-15
---

Hello
""";

    await NoteStorage.save(note);

    var actualContent = io.File(noteFullPath).readAsStringSync();
    expect(actualContent, equals(expectedContent));
  });

  test('Note title should be saved as File Name', () async {
    var parentFolder = NotesFolderFS.root(config, fileStorage);
    var n = Note.newNote(parentFolder, fileFormat: NoteFileFormat.Markdown);
    n = n.copyWith(title: "Hello");

    expect(n.rebuildFileName(), "Hello.md");
  });

  test('Rename', () {
    var parentFolder = NotesFolderFS.root(config, fileStorage);
    var n = Note.newNote(
      parentFolder,
      fileFormat: NoteFileFormat.Markdown,
      fileName: "poo",
    );
    var n2 = n.copyWithFileName('doo.md');
    expect(n.filePath, "poo.md");
    expect(n2.filePath, "doo.md");

    var subDir = NotesFolderFS(parentFolder, "folder", parentFolder.config);
    var n3 = Note.newNote(
      subDir,
      fileFormat: NoteFileFormat.Markdown,
      fileName: "goo.md",
    );
    var n4 = n3.copyWithFileName('roo.md');
    expect(n3.filePath, "folder/goo.md");
    expect(n4.filePath, "folder/roo.md");

    var n5 = n4.copyWithFileName('file.txt');
    expect(n5.filePath, "folder/file.txt");
    expect(n5.fileFormat, NoteFileFormat.Txt);
  });
}
