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
import 'package:universal_io/io.dart' as io;

import 'package:gitjournal/core/folder/flattened_filtered_notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/note_storage.dart';

void main() {
  var random = Random(DateTime.now().millisecondsSinceEpoch);

  String _getRandomFilePath(String basePath) {
    while (true) {
      var filePath = p.join(basePath, "${random.nextInt(1000)}.md");
      if (io.File(filePath).existsSync()) {
        continue;
      }

      return filePath;
    }
  }

  group('Flattened Notes Folder Test', () {
    late io.Directory tempDir;
    late NotesFolderFS rootFolder;
    late NotesFolderConfig config;

    final storage = NoteStorage();

    setUp(() async {
      tempDir =
          await io.Directory.systemTemp.createTemp('__sorted_folder_test__');
      SharedPreferences.setMockInitialValues({});
      config = NotesFolderConfig('', await SharedPreferences.getInstance());

      rootFolder = NotesFolderFS(null, tempDir.path, config);

      for (var i = 0; i < 3; i++) {
        var fp = _getRandomFilePath(rootFolder.folderPath);
        var note = Note.newNote(rootFolder, fileName: p.basename(fp));
        note.apply(
          modified: DateTime(2020, 1, 10 + (i * 2)),
          body: "$i\n",
        );
        await storage.save(note).throwOnError();
      }

      io.Directory(p.join(tempDir.path, "sub1")).createSync();
      io.Directory(p.join(tempDir.path, "sub1", "p1")).createSync();
      io.Directory(p.join(tempDir.path, "sub2")).createSync();

      var sub1Folder =
          NotesFolderFS(rootFolder, p.join(tempDir.path, "sub1"), config);
      for (var i = 0; i < 2; i++) {
        var fp = _getRandomFilePath(sub1Folder.folderPath);
        var note = Note.newNote(rootFolder, fileName: p.basename(fp));

        note.apply(
          modified: DateTime(2020, 1, 10 + (i * 2)),
          body: "sub1-$i\n",
        );
        await storage.save(note).throwOnError();
      }

      var sub2Folder =
          NotesFolderFS(rootFolder, p.join(tempDir.path, "sub2"), config);
      for (var i = 0; i < 2; i++) {
        var fp = _getRandomFilePath(sub2Folder.folderPath);
        var note = Note.newNote(rootFolder, fileName: p.basename(fp));

        note.apply(
          modified: DateTime(2020, 1, 10 + (i * 2)),
          body: "sub2-$i\n",
        );
        await storage.save(note).throwOnError();
      }

      var p1Folder =
          NotesFolderFS(sub1Folder, p.join(tempDir.path, "sub1", "p1"), config);
      for (var i = 0; i < 2; i++) {
        var fp = _getRandomFilePath(p1Folder.folderPath);
        var note = Note.newNote(rootFolder, fileName: p.basename(fp));

        note.apply(
          modified: DateTime(2020, 1, 10 + (i * 2)),
          body: "p1-$i\n",
        );
        await storage.save(note).throwOnError();
      }

      await rootFolder.loadRecursively();
    });

    tearDown(() async {
      tempDir.deleteSync(recursive: true);
    });

    test('Basic Filter should work', () async {
      var f = await FlattenedFilteredNotesFolder.load(
        rootFolder,
        title: "foo",
        filter: (Note note) async => note.body.contains('sub'),
      );
      expect(f.subFolders.length, 0);
      expect(f.notes.length, 4);

      var notes = List<Note>.from(f.notes);
      notes.sort((Note n1, Note n2) => n1.body.compareTo(n2.body));

      expect(notes[0].body, "sub1-0\n");
      expect(notes[1].body, "sub1-1\n");
      expect(notes[2].body, "sub2-0\n");
      expect(notes[3].body, "sub2-1\n");
    });

    // Test adding a note
    // Test removing a note
    // Test loading it incrementally
    // Test renaming a file
  });
}
