import 'dart:io';

import 'package:gitjournal/core/checklist.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
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
modified: 2017-02-15T22:41:19+01:00
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

      var parentFolder = NotesFolder(null, tempDir.path);
      var note = Note(parentFolder, notePath);
      await note.load();

      var checklist = Checklist(note);
      expect(checklist.items.length, equals(5));

      expect(checklist.items[0].checked, false);
      expect(checklist.items[1].checked, true);
      expect(checklist.items[2].checked, true);
      expect(checklist.items[3].checked, false);
      expect(checklist.items[4].checked, false);

      expect(checklist.items[0].text, "item 1");
      expect(checklist.items[1].text, "item 2");
      expect(checklist.items[2].text, "item 3");
      expect(checklist.items[3].text, "item 4");
      expect(checklist.items[4].text, "item 5");

      //
      // Serialization
      //

      checklist.items[0].checked = true;
      checklist.items[1].checked = false;
      checklist.items[1].text = "Foo";
      checklist.addItem(false, "Howdy");

      checklist.removeItem(checklist.items[4]);

      await checklist.note.save();

      var expectedContent = """---
title: Foo
modified: 2017-02-15T22:41:19+01:00
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
  });
}
