import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder_config.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/core/sorting_mode.dart';

void main() {
  group('Sorting Mode', () {
    late NotesFolderConfig config;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      config = NotesFolderConfig('', await SharedPreferences.getInstance());
    });

    test('Created', () async {
      var folder = NotesFolderFS(null, '/tmp/', config);
      var n1 = Note(folder, '/tmp/1.md');
      n1.created = DateTime(2020, 10, 01);

      var n2 = Note(folder, '/tmp/2.md');
      n2.created = DateTime(2020, 10, 02);

      var n3 = Note(folder, '/tmp/3.md');
      n3.created = null;

      var n4 = Note(folder, '/tmp/4.md');
      n4.created = null;

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
      var folder = NotesFolderFS(null, '/tmp/', config);
      var n1 = Note(folder, '/tmp/1.md');
      n1.modified = DateTime(2020, 10, 01);

      var n2 = Note(folder, '/tmp/2.md');
      n2.modified = DateTime(2020, 10, 02);

      var n3 = Note(folder, '/tmp/3.md');
      n3.modified = null;

      var n4 = Note(folder, '/tmp/4.md');
      n4.modified = null;

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
