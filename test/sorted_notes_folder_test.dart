/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:math';

import 'package:dart_git/utils/result.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/note_storage.dart';
import 'package:gitjournal/core/notes_folder_config.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/core/sorted_notes_folder.dart';
import 'package:gitjournal/core/sorting_mode.dart';

void main() {
  group('Sorted Notes Folder Test', () {
    late Directory tempDir;
    late NotesFolderFS folder;
    late NotesFolderConfig config;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('__sorted_folder_test__');
      SharedPreferences.setMockInitialValues({});
      config = NotesFolderConfig('', await SharedPreferences.getInstance());

      folder = NotesFolderFS(null, tempDir.path, config);

      var random = Random();
      for (var i = 0; i < 5; i++) {
        var note = Note(
            folder,
            p.join(folder.folderPath, "${random.nextInt(1000)}.md"),
            DateTime.now());
        note.modified = DateTime(2020, 1, 10 + (i * 2));
        note.body = "$i\n";
        await NoteStorage().save(note).throwOnError();
      }
      await folder.loadRecursively();
    });

    tearDown(() async {
      tempDir.deleteSync(recursive: true);
    });

    test('Should load the notes sorted', () async {
      var sf = SortedNotesFolder(
        folder: folder,
        sortingMode:
            SortingMode(SortingField.Modified, SortingOrder.Descending),
      );
      expect(sf.hasNotes, true);
      expect(sf.isEmpty, false);
      expect(sf.name.startsWith("__sorted_folder_test__"), true);
      expect(sf.subFolders.length, 0);
      expect(sf.notes.length, 5);

      expect(sf.notes[0].body, "4\n");
      expect(sf.notes[1].body, "3\n");
      expect(sf.notes[2].body, "2\n");
      expect(sf.notes[3].body, "1\n");
      expect(sf.notes[4].body, "0\n");
    });

    test('Should on modification remains sorted', () async {
      var sf = SortedNotesFolder(
        folder: folder,
        sortingMode:
            SortingMode(SortingField.Modified, SortingOrder.Descending),
      );

      var i = sf.notes.indexWhere((n) => n.body == "1\n");
      sf.notes[i].modified = DateTime(2020, 2, 1);

      expect(sf.notes[0].body, "1\n");
      expect(sf.notes[1].body, "4\n");
      expect(sf.notes[2].body, "3\n");
      expect(sf.notes[3].body, "2\n");
      expect(sf.notes[4].body, "0\n");
    });

    test('Should add new note correctly', () async {
      var sf = SortedNotesFolder(
        folder: folder,
        sortingMode:
            SortingMode(SortingField.Modified, SortingOrder.Descending),
      );

      var note =
          Note(folder, p.join(folder.folderPath, "new.md"), DateTime.now());
      folder.add(note);

      note.modified = DateTime(2020, 2, 1);
      note.body = "new\n";
      await NoteStorage().save(note).throwOnError();

      expect(sf.notes.length, 6);

      expect(sf.notes[0].body, "new\n");
      expect(sf.notes[1].body, "4\n");
      expect(sf.notes[2].body, "3\n");
      expect(sf.notes[3].body, "2\n");
      expect(sf.notes[4].body, "1\n");
      expect(sf.notes[5].body, "0\n");
    });

    test('Should add new note to end works correctly', () async {
      var sf = SortedNotesFolder(
        folder: folder,
        sortingMode:
            SortingMode(SortingField.Modified, SortingOrder.Descending),
      );

      var note =
          Note(folder, p.join(folder.folderPath, "new.md"), DateTime.now());
      folder.add(note);

      note.modified = DateTime(2020, 1, 1);
      note.body = "new\n";
      await NoteStorage().save(note).throwOnError();

      expect(sf.notes.length, 6);

      expect(sf.notes[0].body, "4\n");
      expect(sf.notes[1].body, "3\n");
      expect(sf.notes[2].body, "2\n");
      expect(sf.notes[3].body, "1\n");
      expect(sf.notes[4].body, "0\n");
      expect(sf.notes[5].body, "new\n");
    });

    test('If still sorted while loading the notes', () async {
      var folder = NotesFolderFS(null, tempDir.path, config);
      var sf = SortedNotesFolder(
        folder: folder,
        sortingMode:
            SortingMode(SortingField.Modified, SortingOrder.Descending),
      );

      await folder.loadRecursively();

      expect(sf.hasNotes, true);
      expect(sf.isEmpty, false);
      expect(sf.name.startsWith("__sorted_folder_test__"), true);
      expect(sf.subFolders.length, 0);
      expect(sf.notes.length, 5);

      expect(sf.notes[0].body, "4\n");
      expect(sf.notes[1].body, "3\n");
      expect(sf.notes[2].body, "2\n");
      expect(sf.notes[3].body, "1\n");
      expect(sf.notes[4].body, "0\n");
    });
  });
}
