import 'dart:io';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/sorting_mode.dart';
import 'package:test/test.dart';

void main() {
  group('Sorting Mode', () {
    test('Created', () async {
      var folder = NotesFolder(null, '/tmp/');
      var n1 = Note(folder, '/tmp/1.md');
      n1.created = DateTime(2020, 10, 01);

      var n2 = Note(folder, '/tmp/2.md');
      n2.created = DateTime(2020, 10, 02);

      var n3 = Note(folder, '/tmp/3.md');
      n3.created = null;

      var n4 = Note(folder, '/tmp/4.md');
      n4.created = null;

      var notes = [n1, n2, n3, n4];
      var sortFn = SortingMode.Created.sortingFunction();

      notes.sort(sortFn);
      expect(notes[0], n2);
      expect(notes[1], n1);
      expect(notes[2], n3);
      expect(notes[3], n4);
    });

    test('Modified', () async {
      var folder = NotesFolder(null, '/tmp/');
      var n1 = Note(folder, '/tmp/1.md');
      n1.modified = DateTime(2020, 10, 01);

      var n2 = Note(folder, '/tmp/2.md');
      n2.modified = DateTime(2020, 10, 02);

      var n3 = Note(folder, '/tmp/3.md');
      n3.modified = null;

      var n4 = Note(folder, '/tmp/4.md');
      n4.modified = null;

      var notes = [n1, n2, n3, n4];
      var sortFn = SortingMode.Modified.sortingFunction();

      notes.sort(sortFn);
      expect(notes[0], n2);
      expect(notes[1], n1);
      expect(notes[2], n3);
      expect(notes[3], n4);
    });
  });
}
