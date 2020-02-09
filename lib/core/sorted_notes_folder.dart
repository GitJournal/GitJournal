import 'note.dart';
import 'notes_folder.dart';
import 'notes_folder_notifier.dart';

class SortedNotesFolder with NotesFolderNotifier implements NotesFolder {
  final NotesFolder folder;

  List<Note> _notes = [];

  SortedNotesFolder(this.folder) {
    _notes = List<Note>.from(folder.notes);
    _notes.sort(_compare);

    folder.addFolderAddedListener(_folderAddedListener);
    folder.addFolderRemovedListener(_folderRemovedListener);

    folder.addNoteAddedListener(_noteAddedListener);
    folder.addNoteRemovedListener(_noteRemovedListener);

    folder.addListener(_entityChanged);
  }

  @override
  void dispose() {
    folder.removeFolderAddedListener(_folderAddedListener);
    folder.removeFolderRemovedListener(_folderRemovedListener);

    folder.removeNoteAddedListener(_noteAddedListener);
    folder.removeNoteRemovedListener(_noteRemovedListener);

    folder.removeListener(_entityChanged);

    super.dispose();
  }

  void _folderAddedListener(int index, NotesFolder folder) {
    notifyFolderAdded(index, folder);
  }

  void _folderRemovedListener(int index, NotesFolder folder) {
    notifyFolderRemoved(index, folder);
  }

  void _noteAddedListener(int _, Note note) {
    assert(folder.notes.length == _notes.length + 1);

    var i = 0;
    for (; i < _notes.length; i++) {
      var n = _notes[i];
      if (_compare(n, note) > 0) {
        break;
      }
    }
    _notes.insert(i, note);
    notifyNoteAdded(i, note);
  }

  void _noteRemovedListener(int _, Note note) {
    assert(folder.notes.length == _notes.length - 1);

    var index = _notes.indexWhere((n) => n.filePath == note.filePath);
    assert(index != -1);
    _notes.removeAt(index);

    notifyNoteRemoved(index, note);
  }

  void _entityChanged() {
    notifyListeners();
  }

  int _compare(Note a, Note b) {
    return b.compareTo(a);
  }

  @override
  List<Note> get notes => _notes;

  @override
  List<NotesFolder> getFolders() => folder.getFolders();

  //
  // Dumb Interface Implementation
  //
  @override
  NotesFolder get parent => folder.parent;

  @override
  String get folderPath => folder.folderPath;

  @override
  bool get isEmpty => folder.isEmpty;

  @override
  String get name => folder.name;

  @override
  String get fullName => folder.fullName;

  @override
  bool get hasSubFolders => folder.hasSubFolders;

  @override
  bool get hasNotes => folder.hasNotes;

  @override
  bool get hasNotesRecursive => folder.hasNotesRecursive;

  @override
  int get numberOfNotes => folder.numberOfNotes;

  @override
  Future<void> loadRecursively() => folder.loadRecursively();

  @override
  Future<void> load() => folder.load();

  @override
  void add(Note note) => folder.add(note);

  @override
  void insert(int index, Note note) => folder.insert(index, note);

  @override
  void remove(Note note) => folder.remove(note);

  @override
  void create() => folder.create();

  @override
  void addFolder(NotesFolder folder) => folder.addFolder(folder);

  @override
  void removeFolder(NotesFolder folder) => folder.removeFolder(folder);

  @override
  void rename(String newName) => folder.rename(newName);

  @override
  String pathSpec() => folder.pathSpec();

  @override
  int compareTo(NotesFolder other) {
    return folderPath.compareTo(other.folderPath);
  }
}
