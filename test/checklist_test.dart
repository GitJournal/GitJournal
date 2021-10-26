/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:dart_git/git.dart';
import 'package:dart_git/utils/result.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart' as io;

import 'package:gitjournal/core/checklist.dart';
import 'package:gitjournal/core/file/file.dart';
import 'package:gitjournal/core/file/file_storage.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/note_storage.dart';

void main() {
  group('Note', () {
    late String repoPath;
    late io.Directory tempDir;
    late NotesFolderConfig config;
    late FileStorage fileStorage;

    final storage = NoteStorage();

    setUpAll(() async {
      tempDir = await io.Directory.systemTemp.createTemp('__notes_test__');
      repoPath = tempDir.path + p.separator;

      SharedPreferences.setMockInitialValues({});
      config = NotesFolderConfig('', await SharedPreferences.getInstance());
      fileStorage = await FileStorage.fake(repoPath);
    });

    tearDownAll(() async {
      tempDir.deleteSync(recursive: true);
    });

    test('Should parse simple checklists', () async {
      var content = """---
bar: Foo
---

Title 1

How are you doing?

- [ ] item 1
- [x] item 2
- [X] item 3
- [ ] item 4
- [ ] item 5

Booga Wooga
""";

      var noteFullPath = p.join(repoPath, "note.md");
      await io.File(noteFullPath).writeAsString(content);

      var parentFolder = NotesFolderFS.root(config, fileStorage);
      var file = File.short("note.md", repoPath);
      var note = await storage.load(file, parentFolder).getOrThrow();

      var checklist = Checklist(note);
      var items = checklist.items;
      expect(items.length, equals(5));

      expect(items[0].checked, false);
      expect(items[1].checked, true);
      expect(items[2].checked, true);
      expect(items[3].checked, false);
      expect(items[4].checked, false);

      expect(items[0].text, "item 1");
      expect(items[1].text, "item 2");
      expect(items[2].text, "item 3");
      expect(items[3].text, "item 4");
      expect(items[4].text, "item 5");

      //
      // Serialization
      //

      checklist.items[0].checked = true;
      checklist.items[1].checked = false;
      checklist.items[1].text = "Foo";
      var item = checklist.buildItem(false, "Howdy");
      checklist.addItem(item);

      checklist.removeItem(checklist.items[4]);

      await NoteStorage().save(checklist.note).throwOnError();

      var expectedContent = """---
bar: Foo
---

Title 1

How are you doing?

- [x] item 1
- [ ] Foo
- [X] item 3
- [ ] item 4
- [ ] Howdy

Booga Wooga
""";

      var actualContent = io.File(noteFullPath).readAsStringSync();
      expect(actualContent, equals(expectedContent));
    });

    test('Should not add line breaks', () async {
      var content = """
- [ ] item 1
- [x] item 2
- [x] item 3""";

      var noteFullPath = p.join(repoPath, "note2.md");
      await io.File(noteFullPath).writeAsString(content);

      var parentFolder = NotesFolderFS.root(config, fileStorage);
      var file = File.short("note2.md", repoPath);
      var note = await storage.load(file, parentFolder).getOrThrow();

      var checklist = Checklist(note);
      var items = checklist.items;
      expect(items.length, equals(3));
    });

    test('Should add \\n before item when adding', () async {
      var content = "Hi.";

      var noteFullPath = p.join(repoPath, "note3.md");
      await io.File(noteFullPath).writeAsString(content);

      var parentFolder = NotesFolderFS.root(config, fileStorage);
      var file = File.short("note3.md", repoPath);
      var note = await storage.load(file, parentFolder).getOrThrow();

      var checklist = Checklist(note);
      var items = checklist.items;
      expect(items.length, equals(0));

      checklist.addItem(checklist.buildItem(false, "item"));
      expect(items.length, 1);

      note = checklist.note;
      expect(note.body, "Hi.\n- [ ] item");
    });

    test('Should not add \\n when adding after item', () async {
      var content = "- [ ] one";

      var noteFullPath = p.join(repoPath, "note13.md");
      await io.File(noteFullPath).writeAsString(content);

      var parentFolder = NotesFolderFS.root(config, fileStorage);
      var file = File.short("note13.md", repoPath);
      var note = await storage.load(file, parentFolder).getOrThrow();

      var checklist = Checklist(note);
      var items = checklist.items;
      expect(items.length, equals(1));

      checklist.addItem(checklist.buildItem(false, "item"));

      note = checklist.note;
      expect(note.body, "- [ ] one\n- [ ] item");
    });

    test('insertItem works', () async {
      var content = "Hi.\n- [ ] One\n- Two\n- [ ] Three";

      var noteFullPath = p.join(repoPath, "note4.md");
      await io.File(noteFullPath).writeAsString(content);

      var parentFolder = NotesFolderFS.root(config, fileStorage);
      var file = File.short("note4.md", repoPath);
      var note = await storage.load(file, parentFolder).getOrThrow();

      var checklist = Checklist(note);
      var items = checklist.items;
      expect(items.length, 2);

      checklist.insertItem(1, checklist.buildItem(false, "item"));

      note = checklist.note;
      expect(note.body, "Hi.\n- [ ] One\n- Two\n- [ ] item\n- [ ] Three");
    });

    test('Does not Remove empty trailing items', () async {
      var content = "Hi.\n- [ ] One\n- Two\n- [ ]  \n- [ ]  ";

      var noteFullPath = p.join(repoPath, "note4.md");
      await io.File(noteFullPath).writeAsString(content);

      var parentFolder = NotesFolderFS.root(config, fileStorage);
      var file = File.short("note4.md", repoPath);
      var note = await storage.load(file, parentFolder).getOrThrow();

      var checklist = Checklist(note);

      note = checklist.note;
      expect(note.body, "Hi.\n- [ ] One\n- Two\n- [ ]  \n- [ ]  ");
    });

    test('Does not add extra new line', () async {
      var content = "- [ ] One\n- [ ]Two\n- [ ] Three\n- [ ]Four\n";

      var noteFullPath = p.join(repoPath, "note449.md");
      await io.File(noteFullPath).writeAsString(content);

      var parentFolder = NotesFolderFS.root(config, fileStorage);
      var file = File.short("note449.md", repoPath);
      var note = await storage.load(file, parentFolder).getOrThrow();

      var checklist = Checklist(note);
      checklist.addItem(checklist.buildItem(false, "Five"));

      note = checklist.note;
      expect(note.body,
          "- [ ] One\n- [ ] Two\n- [ ] Three\n- [ ] Four\n- [ ] Five\n");
    });

    test('Maintain x case', () async {
      var content = "- [X] One\n- [ ] Two";

      var noteFullPath = p.join(repoPath, "note448.md");
      await io.File(noteFullPath).writeAsString(content);

      var parentFolder = NotesFolderFS.root(config, fileStorage);
      var file = File.short("note448.md", repoPath);
      var note = await storage.load(file, parentFolder).getOrThrow();

      var checklist = Checklist(note);

      note = checklist.note;
      expect(note.body, content);
    });

    test('Migrate from old checklist format', () async {
      var content = "[X] One\n[ ] Two";

      var noteFullPath = p.join(repoPath, "note448.md");
      await io.File(noteFullPath).writeAsString(content);

      var parentFolder = NotesFolderFS.root(config, fileStorage);
      var file = File.short("note448.md", repoPath);
      var note = await storage.load(file, parentFolder).getOrThrow();

      var checklist = Checklist(note);

      note = checklist.note;
      expect(note.body, "- [X] One\n- [ ] Two");
    });

    test('Empty Checklist', () async {
      var content = "[X] One\n";

      var noteFullPath = p.join(repoPath, "note449.md");
      await io.File(noteFullPath).writeAsString(content);

      var parentFolder = NotesFolderFS.root(config, fileStorage);
      var file = File.short("note449.md", repoPath);
      var note = await storage.load(file, parentFolder).getOrThrow();

      var checklist = Checklist(note);
      checklist.removeAt(0);

      note = checklist.note;
      expect(note.body, "\n");
    });

    test('Checklist Header only', () async {
      var content = "#Title\n[X] One\n";

      var noteFullPath = p.join(repoPath, "note429.md");
      await io.File(noteFullPath).writeAsString(content);

      var parentFolder = NotesFolderFS.root(config, fileStorage);
      var file = File.short("note429.md", repoPath);
      var note = await storage.load(file, parentFolder).getOrThrow();

      var checklist = Checklist(note);
      checklist.removeAt(0);

      note = checklist.note;
      expect(note.body, "");
      expect(note.title, "Title");
    });
  });
}
