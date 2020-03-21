import 'dart:io';
import 'dart:math';

import 'package:gitjournal/core/flattened_notes_folder.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/core/note.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('Flattened Notes Folder Test', () {
    Directory tempDir;
    NotesFolderFS rootFolder;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('__sorted_folder_test__');

      rootFolder = NotesFolderFS(null, tempDir.path);

      var random = Random();
      for (var i = 0; i < 3; i++) {
        var note = Note(
          rootFolder,
          p.join(rootFolder.folderPath, "${random.nextInt(1000)}.md"),
        );
        note.modified = DateTime(2020, 1, 10 + (i * 2));
        note.body = "$i";
        await note.save();
      }

      Directory(p.join(tempDir.path, "sub1")).createSync();
      Directory(p.join(tempDir.path, "sub1", "p1")).createSync();
      Directory(p.join(tempDir.path, "sub2")).createSync();

      var sub1Folder = NotesFolderFS(rootFolder, p.join(tempDir.path, "sub1"));
      for (var i = 0; i < 2; i++) {
        var note = Note(
          sub1Folder,
          p.join(rootFolder.folderPath, "${random.nextInt(1000)}.md"),
        );
        note.modified = DateTime(2020, 1, 10 + (i * 2));
        note.body = "sub1-$i";
        await note.save();
      }

      var sub2Folder = NotesFolderFS(rootFolder, p.join(tempDir.path, "sub2"));
      for (var i = 0; i < 2; i++) {
        var note = Note(
          sub2Folder,
          p.join(rootFolder.folderPath, "${random.nextInt(1000)}.md"),
        );
        note.modified = DateTime(2020, 1, 10 + (i * 2));
        note.body = "sub2-$i";
        await note.save();
      }

      var p1Folder =
          NotesFolderFS(sub1Folder, p.join(tempDir.path, "sub1", "p1"));
      for (var i = 0; i < 2; i++) {
        var note = Note(
          p1Folder,
          p.join(rootFolder.folderPath, "${random.nextInt(1000)}.md"),
        );
        note.modified = DateTime(2020, 1, 10 + (i * 2));
        note.body = "p1-$i";
        await note.save();
      }

      await rootFolder.loadRecursively();
    });

    tearDown(() async {
      tempDir.deleteSync(recursive: true);
    });

    test('Should load the notes flattened', () async {
      var f = FlattenedNotesFolder(rootFolder);
      expect(f.hasNotes, true);
      expect(f.isEmpty, false);
      expect(f.name, "All Notes");
      expect(f.subFolders.length, 0);
      expect(f.notes.length, 9);

      var notes = List<Note>.from(f.notes);
      notes.sort((Note n1, Note n2) => n1.body.compareTo(n2.body));

      expect(notes[0].body, "0");
      expect(notes[1].body, "1");
      expect(notes[2].body, "2");
      expect(notes[3].body, "p1-0");
      expect(notes[4].body, "p1-1");
      expect(notes[5].body, "sub1-0");
      expect(notes[6].body, "sub1-1");
      expect(notes[7].body, "sub2-0");
      expect(notes[8].body, "sub2-1");
    });

    // Test adding a note
    // Test removing a note
    // Test loading it incrementally
    // Test renaming a file
  });
}
