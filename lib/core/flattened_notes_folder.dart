import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/notes_folder_notifier.dart';

typedef NotesFilter = Future<bool> Function(Note note);

class FlattenedNotesFolder with NotesFolderNotifier implements NotesFolder {
  final NotesFolder _parentFolder;
  final NotesFilter? filter;
  final String title;

  var _notes = <Note>[];
  var _folders = <NotesFolder>[];

  FlattenedNotesFolder(this._parentFolder, {required this.title})
      : filter = null {
    _addFolder(_parentFolder);
  }

  FlattenedNotesFolder._internal(this._parentFolder, this.title, this.filter);

  static Future<FlattenedNotesFolder> load(
    NotesFolder parentFolder, {
    required String title,
    required NotesFilter filter,
  }) async {
    var folder = FlattenedNotesFolder._internal(parentFolder, title, filter);
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
    folder.removeFolderAddedListener(_folderAdded);
    folder.removeFolderRemovedListener(_folderRemoved);

    folder.removeNoteAddedListener(_noteAdded);
    folder.removeNoteRemovedListener(_noteRemoved);
    folder.removeNoteModifiedListener(_noteModified);
    folder.removeNoteRenameListener(_noteRenamed);
  }

  Future<void> _noteAdded(int _, Note note) async {
    var _filter = filter;
    if (_filter != null) {
      var shouldAllow = await _filter(note);
      if (!shouldAllow) {
        return;
      }
    }

    // FIXME: Add a lock?
    _notes.add(note);
    notifyNoteAdded(-1, note);
  }

  void _noteRemoved(int _, Note note) {
    var i = _notes.indexWhere((n) => n.filePath == note.filePath);
    assert(filter == null ? i != -1 : true);

    if (i == -1) {
      return;
    }
    assert(i != -1);

    _notes.removeAt(i);
    notifyNoteRemoved(-1, note);
  }

  Future<void> _noteModified(int i, Note note) async {
    var _filter = filter;
    if (_filter == null) {
      notifyNoteModified(-1, note);
      return;
    }

    if (_notes.contains(note)) {
      if (await _filter(note)) {
        notifyNoteModified(-1, note);
      } else {
        _noteRemoved(-1, note);
      }
    } else {
      if (await _filter(note)) {
        _noteAdded(-1, note);
      }
    }
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
