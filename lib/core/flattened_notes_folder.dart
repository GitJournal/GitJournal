import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/notes_folder_notifier.dart';

class FlattenedNotesFolder with NotesFolderNotifier implements NotesFolder {
  final NotesFolder _parentFolder;

  var _notes = <Note>[];
  var _noteExtraInfo = <Note, int>{};

  var _folders = <NotesFolder>[];

  FlattenedNotesFolder(this._parentFolder) {
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
    folder.removeFolderAddedListener(_folderAdded);
    folder.removeFolderRemovedListener(_folderRemoved);

    folder.removeNoteAddedListener(_noteAdded);
    folder.removeNoteRemovedListener(_noteRemoved);
    folder.removeNoteModifiedListener(_noteModified);
  }

  void _noteAdded(int _, Note note) {
    _notes.add(note);
    _noteExtraInfo[note] = _notes.length - 1;

    notifyNoteAdded(-1, note);
  }

  void _noteRemoved(int _, Note note) {
    assert(_noteExtraInfo.containsKey(note));

    var i = _noteExtraInfo[note];
    _notes.removeAt(i);

    notifyNoteRemoved(-1, note);
  }

  void _noteModified(int i, Note note) {
    notifyNoteModified(-1, note);
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
  NotesFolder get parent => null;

  @override
  String pathSpec() => "";

  @override
  NotesFolder get fsFolder {
    return _parentFolder;
  }

  @override
  String get name => "All Notes";
}
