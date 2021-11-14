/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:synchronized/synchronized.dart';

import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_notifier.dart';
import 'package:gitjournal/core/note.dart';

typedef NotesFilter = Future<bool> Function(Note note);

class FlattenedFilteredNotesFolder
    with NotesFolderNotifier
    implements NotesFolder {
  final NotesFolder _parentFolder;
  final NotesFilter filter;
  final String title;

  final _lock = Lock();

  final _notes = <Note>[];
  final _folders = <NotesFolder>[];

  FlattenedFilteredNotesFolder._internal(
      this._parentFolder, this.title, this.filter);

  static Future<FlattenedFilteredNotesFolder> load(
    NotesFolder parentFolder, {
    required String title,
    required NotesFilter filter,
  }) async {
    var folder =
        FlattenedFilteredNotesFolder._internal(parentFolder, title, filter);
    await folder._addFolder(parentFolder);

    return folder;
  }

  Future<void> _addFolder(NotesFolder folder) async {
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
      await _noteAdded(-1, note);
    }

    // Add Sub-Folders
    for (var folder in folder.subFolders) {
      await _addFolder(folder);
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

  Future<void> _noteAdded(int _, Note note) async {
    var shouldAllow = await filter(note);
    if (!shouldAllow) {
      return;
    }

    await _lock.synchronized(() {
      // The filtering is async so we need to check again
      var contain = _notes.indexWhere((n) => n.filePath == note.filePath) != -1;
      if (contain) {
        notifyNoteModified(-1, note);
        return;
      }
      _notes.add(note);
      notifyNoteAdded(-1, note);
    });
  }

  Future<void> _noteRemoved(int _, Note note) async {
    await _lock.synchronized(() {
      var i = _notes.indexWhere((n) => n.filePath == note.filePath);
      // assert(i != -1);
      if (i == -1) {
        return;
      }

      var _ = _notes.removeAt(i);
      notifyNoteRemoved(-1, note);
    });
  }

  Future<void> _noteModified(int _, Note note) async {
    return await _lock.synchronized(() async {
      var contain = _notes.indexWhere((n) => n.filePath == note.filePath) != -1;
      if (contain) {
        if (await filter(note)) {
          notifyNoteModified(-1, note);
        } else {
          _noteRemoved(-1, note);
        }
      } else {
        if (await filter(note)) {
          _notes.add(note);
          notifyNoteAdded(-1, note);
        }
      }
    });
  }

  void _noteRenamed(int _, Note note, String oldPath) {
    notifyNoteRenamed(-1, note, oldPath);
  }

  @override
  List<Note> get notes => _notes;

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
