import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:gitjournal/core/flattened_notes_folder.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/settings.dart';

void main() {
  var random = Random(DateTime.now().millisecondsSinceEpoch);

  String _getRandomFilePath(String basePath) {
    while (true) {
      var filePath = p.join(basePath, "${random.nextInt(1000)}.md");
      if (File(filePath).existsSync()) {
        filePath = null;
        continue;
      }

      return filePath;
    }
  }

  group('Flattened Notes Folder Test', () {
    Directory tempDir;
    NotesFolderFS rootFolder;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('__sorted_folder_test__');

      rootFolder = NotesFolderFS(null, tempDir.path, Settings());

      for (var i = 0; i < 3; i++) {
        var note = Note(rootFolder, _getRandomFilePath(rootFolder.folderPath));
        note.modified = DateTime(2020, 1, 10 + (i * 2));
        note.body = "$i";
        await note.save();
      }

      Directory(p.join(tempDir.path, "sub1")).createSync();
      Directory(p.join(tempDir.path, "sub1", "p1")).createSync();
      Directory(p.join(tempDir.path, "sub2")).createSync();

      var sub1Folder =
          NotesFolderFS(rootFolder, p.join(tempDir.path, "sub1"), Settings());
      for (var i = 0; i < 2; i++) {
        var note = Note(
          sub1Folder,
          _getRandomFilePath(sub1Folder.folderPath),
        );
        note.modified = DateTime(2020, 1, 10 + (i * 2));
        note.body = "sub1-$i";
        await note.save();
      }

      var sub2Folder =
          NotesFolderFS(rootFolder, p.join(tempDir.path, "sub2"), Settings());
      for (var i = 0; i < 2; i++) {
        var note = Note(
          sub2Folder,
          _getRandomFilePath(sub2Folder.folderPath),
        );
        note.modified = DateTime(2020, 1, 10 + (i * 2));
        note.body = "sub2-$i";
        await note.save();
      }

      var p1Folder = NotesFolderFS(
          sub1Folder, p.join(tempDir.path, "sub1", "p1"), Settings());
      for (var i = 0; i < 2; i++) {
        var note = Note(
          p1Folder,
          _getRandomFilePath(p1Folder.folderPath),
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
      var f = FlattenedNotesFolder(rootFolder, title: "foo");
      expect(f.hasNotes, true);
      expect(f.isEmpty, false);
      expect(f.name, "foo");
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

    test('Should add a note properly', () async {
      var f = FlattenedNotesFolder(rootFolder, title: "");

      var p1 = (f.fsFolder as NotesFolderFS).getFolderWithSpec("sub1/p1");
      var note = Note(p1, p.join(p1.folderPath, "new.md"));
      note.modified = DateTime(2020, 2, 1);
      note.body = "new";
      await note.save();
      p1.add(note);

      expect(f.notes.length, 10);

      var notes = List<Note>.from(f.notes);
      notes.sort((Note n1, Note n2) => n1.body.compareTo(n2.body));

      expect(notes[0].body, "0");
      expect(notes[1].body, "1");
      expect(notes[2].body, "2");
      expect(notes[3].body, "new");
      expect(notes[4].body, "p1-0");
      expect(notes[5].body, "p1-1");
      expect(notes[6].body, "sub1-0");
      expect(notes[7].body, "sub1-1");
      expect(notes[8].body, "sub2-0");
      expect(notes[9].body, "sub2-1");

      // FIXME: Check if the callback for added is called with the correct index
    });

    // Test adding a note
    // Test removing a note
    // Test loading it incrementally
    // Test renaming a file
  });
}
