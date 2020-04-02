import 'dart:io';

import 'package:gitjournal/core/checklist.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('Note', () {
    Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('__notes_test__');
    });

    tearDownAll(() async {
      tempDir.deleteSync(recursive: true);
    });

    test('Should parse simple checklists', () async {
      var content = """---
title: Foo
---

# Title 1

How are you doing?

[ ] item 1
[x] item 2
[x] item 3
[ ] item 4
[ ] item 5

Booga Wooga
""";

      var notePath = p.join(tempDir.path, "note.md");
      File(notePath).writeAsString(content);

      var parentFolder = NotesFolderFS(null, tempDir.path);
      var note = Note(parentFolder, notePath);
      await note.load();

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

      // Nodes
      var nodes = checklist.nodes;
      expect(nodes.length, equals(7));
      expect(nodes[0].textContent, "# Title 1\n\nHow are you doing?\n\n");
      expect(nodes[1], items[0].element);
      expect(nodes[2], items[1].element);
      expect(nodes[3], items[2].element);
      expect(nodes[4], items[3].element);
      expect(nodes[5], items[4].element);
      expect(nodes[6].textContent, "\nBooga Wooga\n");

      //
      // Serialization
      //

      checklist.items[0].checked = true;
      checklist.items[1].checked = false;
      checklist.items[1].text = "Foo";
      var item = checklist.buildItem(false, "Howdy");
      checklist.addItem(item);

      checklist.removeItem(checklist.items[4]);

      await checklist.note.save();

      var expectedContent = """---
title: Foo
---

# Title 1

How are you doing?

[x] item 1
[ ] Foo
[X] item 3
[ ] item 4

Booga Wooga
[ ] Howdy
""";

      var actualContent = File(notePath).readAsStringSync();
      expect(actualContent, equals(expectedContent));
    });

    test('Should not add line breaks', () async {
      var content = """
[ ] item 1
[x] item 2
[x] item 3""";

      var notePath = p.join(tempDir.path, "note2.md");
      await File(notePath).writeAsString(content);

      var parentFolder = NotesFolderFS(null, tempDir.path);
      var note = Note(parentFolder, notePath);
      await note.load();

      var checklist = Checklist(note);
      var items = checklist.items;
      expect(items.length, equals(3));

      // Nodes
      var nodes = checklist.nodes;
      expect(nodes.length, equals(3));
      expect(nodes[0], items[0].element);
      expect(nodes[1], items[1].element);
      expect(nodes[2], items[2].element);
    });

    test('Should add \\n before item when adding', () async {
      var content = "Hi.";

      var notePath = p.join(tempDir.path, "note3.md");
      await File(notePath).writeAsString(content);

      var parentFolder = NotesFolderFS(null, tempDir.path);
      var note = Note(parentFolder, notePath);
      await note.load();

      var checklist = Checklist(note);
      var items = checklist.items;
      expect(items.length, equals(0));

      checklist.addItem(checklist.buildItem(false, "item"));

      note = checklist.note;
      expect(note.body, "Hi.\n[ ] item\n");
    });

    test('Should not add \\n when adding after item', () async {
      var content = "[ ] one";

      var notePath = p.join(tempDir.path, "note13.md");
      await File(notePath).writeAsString(content);

      var parentFolder = NotesFolderFS(null, tempDir.path);
      var note = Note(parentFolder, notePath);
      await note.load();

      var checklist = Checklist(note);
      var items = checklist.items;
      expect(items.length, equals(1));

      checklist.addItem(checklist.buildItem(false, "item"));

      note = checklist.note;
      expect(note.body, "[ ] one\n[ ] item\n");
    });

    test('insertItem works', () async {
      var content = "Hi.\n[ ] One\nTwo\n[ ] Three";

      var notePath = p.join(tempDir.path, "note4.md");
      await File(notePath).writeAsString(content);

      var parentFolder = NotesFolderFS(null, tempDir.path);
      var note = Note(parentFolder, notePath);
      await note.load();

      var checklist = Checklist(note);
      var items = checklist.items;
      expect(items.length, equals(2));

      checklist.insertItem(1, checklist.buildItem(false, "item"));

      note = checklist.note;
      expect(note.body, "Hi.\n[ ] One\nTwo\n[ ] item\n[ ] Three\n");
    });

    test('Removes empty trailing items', () async {
      var content = "Hi.\n[ ] One\nTwo\n[ ]  \n[ ]  ";

      var notePath = p.join(tempDir.path, "note4.md");
      await File(notePath).writeAsString(content);

      var parentFolder = NotesFolderFS(null, tempDir.path);
      var note = Note(parentFolder, notePath);
      await note.load();

      var checklist = Checklist(note);

      note = checklist.note;
      expect(note.body, "Hi.\n[ ] One\nTwo\n");
    });

    test('Does not add extra new line', () async {
      var content = "[ ] One\n[ ]Two\n[ ] Three\n[ ] Four\n";

      var notePath = p.join(tempDir.path, "note449.md");
      await File(notePath).writeAsString(content);

      var parentFolder = NotesFolderFS(null, tempDir.path);
      var note = Note(parentFolder, notePath);
      await note.load();

      var checklist = Checklist(note);
      /*
      for (var node in checklist.nodes) {
        print("node $node - '${node.textContent}'");
      }*/
      checklist.addItem(checklist.buildItem(false, "Five"));

      note = checklist.note;
      expect(note.body, "[ ] One\n[ ]Two\n[ ] Three\n[ ] Four\n[ ] Five\n");
    });
  });
}
