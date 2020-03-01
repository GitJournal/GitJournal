import 'package:flutter/material.dart';
import 'package:gitjournal/core/sorting_mode.dart';

import 'note.dart';
import 'notes_folder.dart';
import 'notes_folder_notifier.dart';

class SortedNotesFolder
    with NotesFolderNotifier
    implements NotesFolderReadOnly {
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
    if (note.loadState != NoteLoadState.Loaded) {
      _notes.add(note);
      notifyNoteAdded(_notes.length - 1, note);
      return;
    }

    var i = 0;
    for (; i < _notes.length; i++) {
      var n = _notes[i];
      if (_sortFunc(n, note) > 0) {
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
    _notes.sort(_sortFunc);
    notifyListeners();
  }

  @override
  List<Note> get notes => _notes;

  @override
  bool get hasNotes => folder.hasNotes;

  @override
  bool get isEmpty => folder.isEmpty;

  void changeSortingMode(SortingMode sm) {
    _notes.sort(_sortFunc);
    notifyListeners();
  }

  SortingMode get sortingMode => _sortingMode;
}
