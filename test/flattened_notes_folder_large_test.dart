import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:gitjournal/core/flattened_notes_folder.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';

void main() {
  group('Flattened Notes Folder Large Test', () {
    Directory tempDir;
    NotesFolderFS rootFolder;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('__flat_folder_test__');
      // print("TempDir: ${tempDir.path}");

      var random = Random();
      for (var i = 0; i < 300; i++) {
        // print("Building Note $i");
        await _writeRandomNote(random, tempDir.path);
      }

      rootFolder = NotesFolderFS(null, tempDir.path);
      await rootFolder.loadRecursively();
    });

    tearDown(() async {
      // print("Cleaning Up TempDir: ${tempDir.path}");
      tempDir.deleteSync(recursive: true);
    });

    test('Should load all the notes flattened', () async {
      var f = FlattenedNotesFolder(rootFolder);
      expect(f.notes.length, 300);

      var tempDir = await Directory.systemTemp.createTemp('_test_');
      await _writeRandomNote(Random(), tempDir.path);

      rootFolder.reset(tempDir.path);
      await rootFolder.loadRecursively();
      expect(f.notes.length, 1);
    });
  });
}

Future<void> _writeRandomNote(Random random, String dirPath) async {
  String path;
  while (true) {
    path = p.join(dirPath, "${random.nextInt(10000)}.md");
    if (!File(path).existsSync()) {
      break;
    }
  }

  var note = Note(NotesFolderFS(null, dirPath), path);
  note.modified = DateTime(2014, 1, 1 + (random.nextInt(2000)));
  note.body = "p1";
  await note.save();
}
