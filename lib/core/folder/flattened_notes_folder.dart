/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_notifier.dart';
import 'package:gitjournal/core/note.dart';

typedef NotesFilter = Future<bool> Function(Note note);

class FlattenedNotesFolder with NotesFolderNotifier implements NotesFolder {
  final NotesFolder _parentFolder;
  final String title;

  final _notes = <String, Note>{};
  final _folders = <NotesFolder>[];

  FlattenedNotesFolder(this._parentFolder, {required this.title}) {
    _addFolder(_parentFolder);
  }

  void _addFolder(NotesFolder folder) {
    _folders.add(folder);

    // Add Change notifiers
    folder.addFolderAddedListener(_folderAdded);
    folder.addFolderRemovedListener(_folderRemoved);

    folder.addNoteAddedListener(_noteAdded);
    folder.addNoteRemovedListener(_noteRemoved);
    folder.addNoteModifiedListener(_noteModified);
    folder.addNoteRenameListener(_noteRenamed);

    // Add Individual Notes
    for (var note in folder.notes) {
      _noteAdded(-1, note);
    }

    // Add Sub-Folders
    for (var folder in folder.subFolders) {
      _addFolder(folder);
    }
  }

  @override
  void dispose() {
    for (var folder in _folders) {
      _folderRemoved(-1, folder);
    }

    super.dispose();
  }

  void _folderAdded(int _, NotesFolder folder) {
    _addFolder(folder);
  }

  void _folderRemoved(int _, NotesFolder folder) {
    //
    // FIXME: Wouldn't all the notes from this folder also need to be removed?
    //
    folder.removeFolderAddedListener(_folderAdded);
    folder.removeFolderRemovedListener(_folderRemoved);

    folder.removeNoteAddedListener(_noteAdded);
    folder.removeNoteRemovedListener(_noteRemoved);
    folder.removeNoteModifiedListener(_noteModified);
    folder.removeNoteRenameListener(_noteRenamed);
  }

  void _noteAdded(int _, Note note) {
    if (_notes.containsKey(note.filePath)) {
      assert(
          false, '_noteAdded called on a note already added ${note.filePath}');
      _notes[note.filePath] = note;
      notifyNoteModified(-1, note);
      return;
    }
    _notes[note.filePath] = note;
    notifyNoteAdded(_notes.length - 1, note);
  }

  void _noteRemoved(int _, Note note) {
    var n = _notes.remove(note.filePath);

    if (n == null) {
      assert(false, "_noteRemoved called on untracked note ${note.filePath}");
      return;
    }
    notifyNoteRemoved(-1, note);
  }

  Future<void> _noteModified(int _, Note note) async {
    if (!_notes.containsKey(note.filePath)) {
      assert(
          false, '_noteModified called on a note NOT added ${note.filePath}');
      _noteAdded(_, note);
      return;
    }

    notifyNoteModified(-1, note);
  }

  void _noteRenamed(int _, Note note, String oldPath) {
    var oldNote = _notes.remove(oldPath);
    if (oldNote == null) {
      assert(false, '_noteRenamed called on a note NOT added ${note.filePath}');
    }

    _notes[note.filePath] = note;
    notifyNoteRenamed(-1, note, oldPath);
  }

  @override
  List<Note> get notes => _notes.values.toList();

  @override
  List<NotesFolder> get subFolders => [];

  @override
  bool get hasNotes => _notes.isNotEmpty;

  @override
  bool get isEmpty => _notes.isEmpty;

  @override
  NotesFolder? get parent => null;

  @override
  NotesFolder? get fsFolder => _parentFolder.fsFolder;

  @override
  String get name => title;

  @override
  String get publicName => title;

  @override
  NotesFolderConfig get config {
    return _parentFolder.config;
  }
}
