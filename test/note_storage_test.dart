import 'dart:collection';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:gitjournal/core/md_yaml_doc.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/utils/datetime.dart';

void main() {
  group('NoteStorage', () {
    var notes = <Note>[];
    String n1Path;
    String n2Path;
    Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('__storage_test__');

      var dt = DateTime(2019, 12, 2, 5, 4, 2);
      // ignore: prefer_collection_literals
      var props = LinkedHashMap<String, dynamic>();
      props['created'] = toIso8601WithTimezone(dt);

      n1Path = p.join(tempDir.path, "1.md");
      n2Path = p.join(tempDir.path, "2.md");

      var parent = NotesFolderFS(null, tempDir.path);
      var n1 = Note(parent, n1Path);
      n1.body = "test";
      n1.created = dt;

      var n2 = Note(parent, n2Path);
      n2.data = MdYamlDoc("test2", props);

      notes = [n1, n2];
    });

    tearDownAll(() async {
      tempDir.deleteSync(recursive: true);
    });

    test('Should persist and load Notes from disk', () async {
      await Future.forEach(notes, (Note note) async {
        await note.save();
      });
      expect(tempDir.listSync(recursive: true).length, 2);
      expect(File(n1Path).existsSync(), isTrue);
      expect(File(n2Path).existsSync(), isTrue);

      var loadedNotes = <Note>[];
      var parent = NotesFolderFS(null, tempDir.path);

      await Future.forEach(notes, (origNote) async {
        var note = Note(parent, origNote.filePath);
        var r = await note.load();
        expect(r, NoteLoadState.Loaded);

        loadedNotes.add(note);
      });

      var sortFn = (Note n1, Note n2) => n1.filePath.compareTo(n2.filePath);
      loadedNotes.sort(sortFn);
      notes.sort(sortFn);

      expect(loadedNotes, notes);

      await Future.forEach(notes, (Note note) async {
        await note.remove();
      });
      expect(tempDir.listSync(recursive: true).length, 0);
      expect(File(n1Path).existsSync(), isFalse);
      expect(File(n2Path).existsSync(), isFalse);
    });
  });
}
