import 'note.dart';
import 'notes_folder.dart';
import 'notes_folder_notifier.dart';

class VirtualNotesFolder with NotesFolderNotifier implements NotesFolder {
  final List<Note> _notes;

  VirtualNotesFolder(this._notes);

  @override
  List<Note> get notes => _notes;

  @override
  List<NotesFolder> getFolders() => [];

  //
  // Dumb Interface Implementation
  //
  @override
  NotesFolder get parent => null;

  @override
  String get folderPath => "";

  @override
  bool get isEmpty => _notes.isEmpty;

  @override
  String get name => "";

  @override
  String get fullName => "";

  @override
  bool get hasSubFolders => false;

  @override
  bool get hasNotes => _notes.isNotEmpty;

  @override
  bool get hasNotesRecursive => hasNotes;

  @override
  int get numberOfNotes => _notes.length;

  @override
  Future<void> loadRecursively() async {}

  @override
  Future<void> load() async {}

  @override
  void add(Note note) {}

  @override
  void insert(int index, Note note) {}

  @override
  void remove(Note note) {}

  @override
  void create() {}

  @override
  void addFolder(NotesFolder folder) {}

  @override
  void removeFolder(NotesFolder folder) {}

  @override
  void rename(String newName) {}

  @override
  String pathSpec() => "";

  @override
  int compareTo(NotesFolder other) {
    return folderPath.compareTo(other.folderPath);
  }
}
