import 'package:synchronized/synchronized.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/notes_folder_notifier.dart';

typedef NotesFilter = Future<bool> Function(Note note);

class FlattenedFilteredNotesFolder
    with NotesFolderNotifier
    implements NotesFolder {
  final NotesFolder _parentFolder;
  final NotesFilter filter;
  final String title;

  final _lock = Lock();

  var _notes = <Note>[];
  var _folders = <NotesFolder>[];

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
      _notes.add(note);
      notifyNoteAdded(-1, note);
    });
  }

  Future<void> _noteRemoved(int _, Note note) async {
    await _lock.synchronized(() {
      var i = _notes.indexWhere((n) => n.filePath == note.filePath);
      if (i == -1) {
        return;
      }
      assert(i != -1);

      _notes.removeAt(i);
      notifyNoteRemoved(i, note);
    });
  }

  Future<void> _noteModified(int i, Note note) async {
    return await _lock.synchronized(() async {
      if (_notes.contains(note)) {
        if (await filter(note)) {
          notifyNoteModified(-1, note);
        } else {
          _noteRemoved(-1, note);
        }
      } else {
        if (await filter(note)) {
          _noteAdded(-1, note);
        }
      }
    });
  }

  void _noteRenamed(int i, Note note, String oldPath) {
    notifyNoteRenamed(i, note, oldPath);
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
  String pathSpec() => "";

  @override
  NotesFolder get fsFolder {
    return _parentFolder;
  }

  @override
  String get name => title;

  @override
  String get publicName => title;

  @override
  NotesFolderConfig get config {
    return _parentFolder.config;
  }
}
