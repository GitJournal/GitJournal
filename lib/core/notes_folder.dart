import 'note.dart';
import 'notes_folder_config.dart';
import 'notes_folder_notifier.dart';

export 'notes_folder_config.dart';

abstract class NotesFolder implements NotesFolderNotifier {
  bool get isEmpty;
  bool get hasNotes;
  String get name;

  List<Note> get notes;
  List<NotesFolder> get subFolders;
  NotesFolder get parent;
  NotesFolder get fsFolder;

  NotesFolderConfig get config;
  set config(NotesFolderConfig config);

  String pathSpec();
}
