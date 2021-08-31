import 'dart:io';

import 'package:gitjournal/core/notes_folder_config.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/core/notes_materialized_view.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/transformers/base.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import 'package:path/path.dart' as p;
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  group('ViewTest', () {
    late Directory tempDir;
    late NotesFolderConfig config;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('__notes_test__');
      SharedPreferences.setMockInitialValues({});
      config = NotesFolderConfig('', await SharedPreferences.getInstance());

      await Hive.initFlutter();
    });

    var _createExampleNote = () async {
      var content = """---
bar: Foo
updated: 1626257689
created: 1626257689
---

Hello
""";

      var notePath = p.join(tempDir.path, "note.md");
      await File(notePath).writeAsString(content);

      var parentFolder = NotesFolderFS(null, tempDir.path, config);
      var note = Note(parentFolder, notePath);
      note.fileLastModified = DateTime.now();
      return note;
    };

    test('Test', () async {
      var compute = (Note note) {
        return note.fileName;
      };

      var view =
          await NotesMaterializedView.loadView<String>('_test_box', compute);
      var note = await _createExampleNote();

      expect(view.fetch(note), note.fileName);
    });
  });
}
