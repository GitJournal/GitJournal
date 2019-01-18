import 'dart:io';

import 'package:test/test.dart';
import 'package:path/path.dart' as p;

import 'package:journal/note.dart';
import 'package:journal/storage/file_storage.dart';
import 'package:journal/storage/serializers.dart';

DateTime nowWithoutMicro() {
  var dt = DateTime.now();
  return DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
}

main() {
  group('FileStorage', () {
    var notes = [
      Note(id: "1", body: "test", created: nowWithoutMicro()),
      Note(id: "2", body: "test2", created: nowWithoutMicro()),
    ];

    final directory = Directory.systemTemp.createTemp('__storage_test__');
    final storage = FileStorage(
      getDirectory: () => directory,
      noteSerializer: new JsonNoteSerializer(),
      fileNameGenerator: (Note note) => note.id + '.md',
    );

    tearDownAll(() async {
      final tempDirectory = await directory;
      tempDirectory.deleteSync(recursive: true);
    });

    test('Should persist Notes to disk', () async {
      var dir = await storage.saveNotes(notes);
      expect(dir.listSync(recursive: true).length, 2);

      expect(File(p.join(dir.path, "1.md")).existsSync(), isTrue);
      expect(File(p.join(dir.path, "2.md")).existsSync(), isTrue);
    });

    test('Should load Notes from disk', () async {
      var loadedNotes = await storage.listNotes();
      loadedNotes.sort();
      notes.sort();

      expect(loadedNotes, notes);
    });
  });
}
