import 'dart:io';

import 'package:journal/note.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('NoteStorage', () {
    var notes = <Note>[];
    String n1Path;
    String n2Path;
    Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('__storage_test__');

      var dt = DateTime(2019, 12, 2, 5, 4, 2);
      n1Path = p.join(tempDir.path, "1.md");
      n2Path = p.join(tempDir.path, "2.md");
      notes = <Note>[
        Note(filePath: n1Path, body: "test", created: dt),
        Note(filePath: n2Path, body: "test2", created: dt),
      ];
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
      await Future.forEach(notes, (origNote) async {
        var note = Note(filePath: origNote.filePath);
        var r = await note.load();
        expect(r, NoteLoadState.Loaded);

        loadedNotes.add(note);
      });

      loadedNotes.sort();
      notes.sort();

      expect(loadedNotes, notes);
    });
  });
}
