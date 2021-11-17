/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:math';

import 'package:gitjournal/core/folder/sorting_mode.dart';
import 'package:gitjournal/logger/logger.dart';
import '../note.dart';
import 'notes_folder.dart';
import 'notes_folder_notifier.dart';

class SortedNotesFolder with NotesFolderNotifier implements NotesFolder {
  final NotesFolder folder;

  late SortingMode _sortingMode;
  late SortingFunction _sortFunc;

  List<Note> _notes = [];

  SortedNotesFolder({
    required this.folder,
    required SortingMode sortingMode,
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
    folder.addNoteRenameListener(_noteRenamedListener);
  }

  @override
  void dispose() {
    folder.removeFolderAddedListener(_folderAddedListener);
    folder.removeFolderRemovedListener(_folderRemovedListener);

    folder.removeNoteAddedListener(_noteAddedListener);
    folder.removeNoteRemovedListener(_noteRemovedListener);
    folder.removeNoteModifiedListener(_noteModifiedListener);
    folder.removeNoteRenameListener(_noteRenamedListener);

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
    var _ = _notes.removeAt(index);

    notifyNoteRemoved(index, note);
  }

  void _noteModifiedListener(int _, Note note) {
    var i = _notes.indexWhere((Note n) => note.filePath == n.filePath);
    assert(i != -1);
    // FIXME: This should never be happening
    //        However, lets not crash!
    if (i == -1) {
      return;
    }

    dynamic _;
    _ = _notes.removeAt(i);
    _ = _insertInCorrectPos(note);

    notifyNoteModified(-1, note);
  }

  void _noteRenamedListener(int _, Note note, String oldPath) {
    notifyNoteRenamed(-1, note, oldPath);
  }

  int _insertInCorrectPos(Note note) {
    if (_notes.isEmpty) {
      _notes.add(note);
      return 0;
    }

    var i = _getInsertPos(note, 0, _notes.length - 1);
    if (i == _notes.length) {
      _notes.add(note);
    } else {
      _notes.insert(i, note);
    }
    return i;
  }

  int _getInsertPos(Note note, int low, int high) {
    assert(low <= high);

    int mid = high;

    while (low <= high) {
      mid = low + ((high - low) ~/ 2);

      var r = _sortFunc(_notes[mid], note);
      if (r == 0) {
        return mid;
      }

      if (low == high) {
        if (r < 0) {
          return low + 1;
        } else {
          return low;
        }
      }

      if (r < 0) {
        low = mid + 1;
      } else {
        high = max(low, mid - 1);
      }
    }

    assert(false);
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
    Log.d(
        "Setting sorting to me ${sm.field.toInternalString()} ${sm.order.toInternalString()}");
    _sortingMode = sm;
    _sortFunc = _sortingMode.sortingFunction();

    _notes.sort(_sortFunc);
    notifyListeners();
  }

  SortingMode get sortingMode => _sortingMode;

  @override
  NotesFolder? get parent => folder.parent;

  @override
  String get name => folder.name;

  @override
  String get publicName => folder.publicName;

  @override
  NotesFolder? get fsFolder => folder.fsFolder;

  @override
  NotesFolderConfig get config {
    return folder.config;
  }
}
