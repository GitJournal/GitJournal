/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart' as io;

import 'package:gitjournal/core/file/file_storage.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/folder/sorting_mode.dart';
import 'package:gitjournal/core/note.dart';

void main() {
  group('Sorting Mode', () {
    late NotesFolderConfig config;
    late FileStorage fileStorage;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      config = NotesFolderConfig('', await SharedPreferences.getInstance());

      var tempDir = await io.Directory.systemTemp.createTemp();
      fileStorage = await FileStorage.fake(tempDir.path);
    });

    test('Created', () async {
      var folder = NotesFolderFS.root(config, fileStorage);
      var n1 = Note.newNote(folder,
          fileName: '1.md', fileFormat: NoteFileFormat.Markdown);
      n1.apply(created: DateTime(2020, 10, 01));

      var n2 = Note.newNote(folder,
          fileName: '2.md', fileFormat: NoteFileFormat.Markdown);
      n2.apply(created: DateTime(2020, 10, 02));

      var n3 = Note.newNote(folder,
          fileName: '3.md', fileFormat: NoteFileFormat.Markdown);
      n3.apply(created: DateTime(2020, 9, 04));

      var n4 = Note.newNote(folder,
          fileName: '4.md', fileFormat: NoteFileFormat.Markdown);
      n4.apply(created: DateTime(2020, 9, 03));

      var notes = [n1, n2, n3, n4];
      var sortFn = SortingMode(SortingField.Created, SortingOrder.Descending)
          .sortingFunction();

      notes.sort(sortFn);
      expect(notes[0], n2);
      expect(notes[1], n1);
      expect(notes[2], n3);
      expect(notes[3], n4);
    });

    test('Modified', () async {
      var folder = NotesFolderFS.root(config, fileStorage);
      var n1 = Note.newNote(folder,
          fileName: '1.md', fileFormat: NoteFileFormat.Markdown);
      n1.apply(modified: DateTime(2020, 10, 01));

      var n2 = Note.newNote(folder,
          fileName: '2.md', fileFormat: NoteFileFormat.Markdown);
      n2.apply(modified: DateTime(2020, 10, 02));

      var n3 = Note.newNote(folder,
          fileName: '3.md', fileFormat: NoteFileFormat.Markdown);
      n3.apply(modified: DateTime(2020, 9, 04));

      var n4 = Note.newNote(folder,
          fileName: '4.md', fileFormat: NoteFileFormat.Markdown);
      n4.apply(modified: DateTime(2020, 9, 03));

      var notes = [n1, n2, n3, n4];
      var sortFn = SortingMode(SortingField.Modified, SortingOrder.Descending)
          .sortingFunction();

      notes.sort(sortFn);
      expect(notes[0], n2);
      expect(notes[1], n1);
      expect(notes[2], n3);
      expect(notes[3], n4);
    });
  });
}
