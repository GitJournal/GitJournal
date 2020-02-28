import 'package:flutter/material.dart';
import 'package:gitjournal/settings.dart';

import 'note.dart';
import 'notes_folder.dart';
import 'notes_folder_notifier.dart';

class SortedNotesFolder
    with NotesFolderNotifier
    implements NotesFolderReadOnly {
  final NotesFolder folder;
  SortingMode sortingMode;

  List<Note> _notes = [];

  SortedNotesFolder({
    @required this.folder,
    @required this.sortingMode,
  }) {
    _notes = List<Note>.from(folder.notes);
    _notes.sort(_compare);

    folder.addFolderAddedListener(_folderAddedListener);
    folder.addFolderRemovedListener(_folderRemovedListener);

    folder.addNoteAddedListener(_noteAddedListener);
    folder.addNoteRemovedListener(_noteRemovedListener);

    folder.addListener(_entityChanged);
  }

  @override
  void dispose() {
    folder.removeFolderAddedListener(_folderAddedListener);
    folder.removeFolderRemovedListener(_folderRemovedListener);

    folder.removeNoteAddedListener(_noteAddedListener);
    folder.removeNoteRemovedListener(_noteRemovedListener);

    folder.removeListener(_entityChanged);

    super.dispose();
  }

  void _folderAddedListener(int index, NotesFolder folder) {
    notifyFolderAdded(index, folder);
  }

  void _folderRemovedListener(int index, NotesFolder folder) {
    notifyFolderRemoved(index, folder);
  }

  void _noteAddedListener(int _, Note note) {
    assert(folder.notes.length == _notes.length + 1);

    var i = 0;
    for (; i < _notes.length; i++) {
      var n = _notes[i];
      if (_compare(n, note) > 0) {
        break;
      }
    }
    _notes.insert(i, note);
    notifyNoteAdded(i, note);
  }

  void _noteRemovedListener(int _, Note note) {
    assert(folder.notes.length == _notes.length - 1);

    var index = _notes.indexWhere((n) => n.filePath == note.filePath);
    assert(index != -1);
    _notes.removeAt(index);

    notifyNoteRemoved(index, note);
  }

  void _entityChanged() {
    _notes.sort(_compare);
    notifyListeners();
  }

  int _compare(Note a, Note b) {
    switch (sortingMode) {
      case SortingMode.Created:
        // vHanda FIXME: We should use when the file was created in the FS, but that doesn't
        //               seem to be acessible via dart
        var aDt = a.created ?? a.fileLastModified;
        var bDt = b.created ?? b.fileLastModified;
        if (aDt == null && bDt != null) {
          return -1;
        }
        if (aDt != null && bDt == null) {
          return -1;
        }
        if (bDt == null || aDt == null) {
          return 0;
        }
        return bDt.compareTo(aDt);

      case SortingMode.Modified:
        var aDt = a.modified ?? a.fileLastModified;
        var bDt = b.modified ?? b.fileLastModified;
        if (aDt == null && bDt != null) {
          return -1;
        }
        if (aDt != null && bDt == null) {
          return -1;
        }
        if (bDt == null || aDt == null) {
          return 0;
        }
        if (bDt == null || aDt == null) {
          return 0;
        }
        return bDt.compareTo(aDt);
    }
    return 0;
  }

  @override
  List<Note> get notes => _notes;

  @override
  bool get hasNotes => folder.hasNotes;

  @override
  bool get isEmpty => folder.isEmpty;

  void changeSortingMode(SortingMode sm) {
    sortingMode = sm;
    _notes.sort(_compare);
    notifyListeners();
  }
}
