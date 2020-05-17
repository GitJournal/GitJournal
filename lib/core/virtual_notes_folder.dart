import 'note.dart';
import 'notes_folder.dart';
import 'notes_folder_notifier.dart';

class VirtualNotesFolder with NotesFolderNotifier implements NotesFolder {
  final List<Note> _notes;

  VirtualNotesFolder(this._notes);

  @override
  List<Note> get notes => _notes;

  @override
  List<NotesFolder> get subFolders => [];

  @override
  bool get isEmpty => _notes.isEmpty;

  @override
  bool get hasNotes => _notes.isNotEmpty;

  @override
  NotesFolder get parent => null;

  @override
  String pathSpec() => "";

  @override
  String get name => "";

  @override
  String get publicName => "";

  @override
  NotesFolder get fsFolder {
    return null;
  }

  @override
  NotesFolderConfig get config {
    return NotesFolderConfig.fromSettings(fsFolder);
  }

  @override
  set config(NotesFolderConfig conf) {
    assert(false, "A Virtual Notes Folder Config cannot change");
    conf.saveToSettings();
  }
}
