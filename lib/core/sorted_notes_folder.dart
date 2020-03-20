import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:gitjournal/core/sorting_mode.dart';

import 'note.dart';
import 'notes_folder.dart';
import 'notes_folder_notifier.dart';

class SortedNotesFolder with NotesFolderNotifier implements NotesFolder {
  final NotesFolder folder;

  SortingMode _sortingMode;
  NoteSortingFunction _sortFunc;

  List<Note> _notes = [];

  SortedNotesFolder({
    @required this.folder,
    @required SortingMode sortingMode,
  }) {
    _sortingMode = sortingMode;
    _sortFunc = _sortingMode.sortingFunction();

    _notes = List<Note>.from(folder.notes);
    _notes.sort(_sortFunc);

    folder.addFolderAddedListener(_folderAddedListener);
    folder.addFolderRemovedListener(_folderRemovedListener);

    folder.addNoteAddedListener(_noteAddedListener);
    folder.addNoteRemovedListener(_noteRemovedListener);
    folder.addNoteModifiedListener(_noteModifiedListener);
  }

  @override
  void dispose() {
    folder.removeFolderAddedListener(_folderAddedListener);
    folder.removeFolderRemovedListener(_folderRemovedListener);

    folder.removeNoteAddedListener(_noteAddedListener);
    folder.removeNoteRemovedListener(_noteRemovedListener);
    folder.removeNoteModifiedListener(_noteModifiedListener);

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

    var i = _insertInCorrectPos(note);
    notifyNoteAdded(i, note);
  }

  void _noteRemovedListener(int _, Note note) {
    assert(folder.notes.length == _notes.length - 1);

    var index = _notes.indexWhere((n) => n.filePath == note.filePath);
    assert(index != -1);
    _notes.removeAt(index);

    notifyNoteRemoved(index, note);
  }

  void _noteModifiedListener(int _, Note note) {
    var i = _notes.indexWhere((Note n) => note.filePath == n.filePath);
    assert(i != -1);

    _notes.removeAt(i);
    _insertInCorrectPos(note);

    notifyNoteModified(-1, note);
  }

  int _insertInCorrectPos(Note note) {
    var i = _getInsertPos(note, 0, _notes.length - 1);
    _notes.insert(i, note);
    return i;
  }

  int _getInsertPos(Note note, int low, int high) {
    int mid;
    while (low <= high) {
      mid = low + ((high - low) ~/ 2);

      var r = _sortFunc(_notes[mid], note);
      if (r == 0) {
        return mid;
      } else if (r < 0) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    return mid;
  }

  @override
  List<Note> get notes => _notes;

  @override
  List<NotesFolder> get subFolders => folder.subFolders;

  @override
  bool get hasNotes => folder.hasNotes;

  @override
  bool get isEmpty => folder.isEmpty;

  void changeSortingMode(SortingMode sm) {
    Fimber.d("Setting sorting to me ${sm.toInternalString()}");
    _sortingMode = sm;
    _sortFunc = _sortingMode.sortingFunction();

    _notes.sort(_sortFunc);
    notifyListeners();
  }

  SortingMode get sortingMode => _sortingMode;

  @override
  NotesFolder get parent => folder.parent;

  @override
  String pathSpec() => folder.pathSpec();

  @override
  String get name => folder.name;

  @override
  NotesFolder get fsFolder {
    return folder;
  }
}
