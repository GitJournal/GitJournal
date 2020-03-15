import 'note.dart';
import 'notes_folder_notifier.dart';

abstract class NotesFolder implements NotesFolderNotifier {
  bool get isEmpty;
  bool get hasNotes;
  String get name;

  List<Note> get notes;
  List<NotesFolder> get subFolders;
  NotesFolder get parent;
  NotesFolder get fsFolder;

  String pathSpec();
}
