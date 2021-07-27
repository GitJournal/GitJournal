import 'package:gitjournal/settings/settings.dart';
import 'note.dart';
import 'notes_folder.dart';
import 'notes_folder_notifier.dart';

class VirtualNotesFolder with NotesFolderNotifier implements NotesFolder {
  final List<Note> _notes;
  final Settings settings;

  VirtualNotesFolder(this._notes, this.settings);

  @override
  List<Note> get notes => _notes;

  @override
  List<NotesFolder> get subFolders => [];

  @override
  bool get isEmpty => _notes.isEmpty;

  @override
  bool get hasNotes => _notes.isNotEmpty;

  @override
  NotesFolder? get parent => null;

  @override
  String pathSpec() => "";

  @override
  String get name => "";

  @override
  String get publicName => "";

  @override
  NotesFolder? get fsFolder {
    return null;
  }

  @override
  NotesFolderConfig get config {
    // FIXME: This isn't expecting null!
    return NotesFolderConfig('_');
  }
}
