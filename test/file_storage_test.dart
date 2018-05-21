import 'dart:io';

import 'package:test/test.dart';
import 'package:path/path.dart' as p;

import '../lib/note.dart';
import '../lib/file_storage.dart';

main() {
  group('FileStorage', () {
    var notes = [
      Note(id: "1", body: "test", createdAt: new DateTime.now()),
      Note(id: "2", body: "test2", createdAt: new DateTime.now()),
    ];

    final directory = Directory.systemTemp.createTemp('__storage_test__');
    final storage = FileStorage(() => directory);

    tearDownAll(() async {
      final tempDirectory = await directory;
      tempDirectory.deleteSync(recursive: true);
    });

    test('Should persist Notes to disk', () async {
      var dir = await storage.saveNotes(notes);
      expect(dir.listSync(recursive: true).length, 2);

      expect(File(p.join(dir.path, "1")).existsSync(), isTrue);
      expect(File(p.join(dir.path, "2")).existsSync(), isTrue);
    });

    test('Should load Notes from disk', () async {
      var loadedNotes = await storage.loadNotes();
      loadedNotes.sort();
      notes.sort();

      expect(loadedNotes, notes);
    });
  });
}
