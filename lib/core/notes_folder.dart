import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';

import 'note.dart';
import 'notes_folder_notifier.dart';

abstract class NotesFolderReadOnly implements NotesFolderNotifier {
  bool get isEmpty;
  bool get hasNotes;
  List<Note> get notes;
}

class NotesFolder
    with NotesFolderNotifier
    implements NotesFolderReadOnly, Comparable<NotesFolder> {
  final NotesFolder parent;
  String _folderPath;

  List<Note> _notes = [];
  List<NotesFolder> _folders = [];

  Map<String, dynamic> _entityMap = {};

  NotesFolder(this.parent, this._folderPath);

  @override
  void dispose() {
    _folders.forEach((f) => f.removeListener(_entityChanged));
    _notes.forEach((f) => f.removeListener(_entityChanged));

    super.dispose();
  }

  void _entityChanged() {
    notifyListeners();
  }

  void reset(String folderPath) {
    _folderPath = folderPath;

    var notesCopy = List<Note>.from(_notes);
    notesCopy.forEach(remove);

    var foldersCopy = List<NotesFolder>.from(_folders);
    foldersCopy.forEach(removeFolder);

    assert(_notes.isEmpty);
    assert(_folders.isEmpty);

    notifyListeners();
  }

  String get folderPath => _folderPath;

  @override
  bool get isEmpty {
    return _notes.isEmpty && _folders.isEmpty;
  }

  String get name {
    return basename(folderPath);
  }

  String get fullName {
    String n = name;
    var par = parent;
    while (par != null) {
      n = p.join(par.name, n);
      par = par.parent;
    }

    return n;
  }

  bool get hasSubFolders {
    return _folders.isNotEmpty;
  }

  @override
  bool get hasNotes {
    return _notes.isNotEmpty;
  }

  bool get hasNotesRecursive {
    if (_notes.isNotEmpty) {
      return true;
    }

    for (var folder in _folders) {
      if (folder.hasNotesRecursive) {
        return true;
      }
    }
    return false;
  }

  int get numberOfNotes {
    return _notes.length;
  }

  @override
  List<Note> get notes {
    return _notes;
  }

  List<NotesFolder> get subFolders {
    // FIXME: This is really not ideal
    _folders.sort();
    return _folders;
  }

  // FIXME: This asynchronously loads everything. Maybe it should just list them, and the individual _entities
  //        should be loaded as required?
  Future<void> loadRecursively() async {
    const maxParallel = 10;
    var futures = <Future>[];

    await load();

    for (var note in _notes) {
      // FIXME: Collected all the Errors, and report them back, along with "WHY", and the contents of the Note
      //        Each of these needs to be reported to crashlytics, as Note loading should never fail
      var f = note.load();
      futures.add(f);

      if (futures.length >= maxParallel) {
        await Future.wait(futures);
        futures = <Future>[];
      }
    }

    await Future.wait(futures);
    futures = <Future>[];

    for (var folder in _folders) {
      var f = folder.loadRecursively();
      futures.add(f);
    }

    return Future.wait(futures);
  }

  // FIXME: This should not reconstruct the Notes or NotesFolders once constructed.
  Future<void> load() async {
    Set<String> pathsFound = {};

    final dir = Directory(folderPath);
    var lister = dir.list(recursive: false, followLinks: false);
    await for (var fsEntity in lister) {
      if (fsEntity is Link) {
        continue;
      }

      // If already seen before
      var existingNoteFSEntity = _entityMap[fsEntity.path];
      if (existingNoteFSEntity != null) {
        pathsFound.add(fsEntity.path);
        continue;
      }

      if (fsEntity is Directory) {
        Fimber.d("Found directory ${fsEntity.path}");
        var subFolder = NotesFolder(this, fsEntity.path);
        if (subFolder.name.startsWith('.')) {
          continue;
        }
        subFolder.addListener(_entityChanged);

        _folders.add(subFolder);
        _entityMap[fsEntity.path] = subFolder;

        pathsFound.add(fsEntity.path);
        notifyFolderAdded(_folders.length - 1, subFolder);
        continue;
      }

      var note = Note(this, fsEntity.path);
      if (!note.filePath.toLowerCase().endsWith('.md')) {
        Fimber.d("Ignoring file ${fsEntity.path}");
        continue;
      }
      Fimber.d("Found file ${fsEntity.path}");
      note.addListener(_entityChanged);

      _notes.add(note);
      _entityMap[fsEntity.path] = note;

      pathsFound.add(fsEntity.path);
      notifyNoteAdded(_notes.length - 1, note);
    }

    Set<String> pathsRemoved = _entityMap.keys.toSet().difference(pathsFound);
    pathsRemoved.forEach((path) {
      var e = _entityMap[path];
      assert(e != null);

      assert(e is NotesFolder || e is Note);
      e.removeListener(_entityChanged);
      _entityMap.remove(path);

      if (e is Note) {
        Fimber.d("File $path was no longer found");
        var i = _notes.indexWhere((n) => n.filePath == path);
        assert(i != -1);
        var note = _notes[i];
        _notes.removeAt(i);
        notifyNoteRemoved(i, note);
      } else {
        Fimber.d("Folder $path was no longer found");
        var i = _folders.indexWhere((f) => f.folderPath == path);
        assert(i != -1);
        var folder = _folders[i];
        _folders.removeAt(i);
        notifyFolderRemoved(i, folder);
      }
    });
  }

  void add(Note note) {
    assert(note.parent == this);
    note.addListener(_entityChanged);

    _notes.add(note);
    _entityMap[note.filePath] = note;

    notifyNoteAdded(_notes.length - 1, note);
  }

  void insert(int index, Note note) {
    assert(note.parent == this);
    assert(index >= 0);
    note.addListener(_entityChanged);

    _notes.insert(index, note);
    _entityMap[note.filePath] = note;

    notifyNoteAdded(index, note);
  }

  void remove(Note note) {
    assert(note.parent == this);
    note.removeListener(_entityChanged);

    assert(_notes.indexWhere((n) => n.filePath == note.filePath) != -1);
    assert(_entityMap.containsKey(note.filePath));

    var index = _notes.indexWhere((n) => n.filePath == note.filePath);
    assert(index != -1);
    _notes.removeAt(index);
    _entityMap.remove(note.filePath);

    notifyNoteRemoved(index, note);
  }

  void create() {
    // Git doesn't track Directories, only files, so we create an empty .gitignore file
    // in the directory instead.
    var gitIgnoreFilePath = p.join(folderPath, ".gitignore");
    var file = File(gitIgnoreFilePath);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    notifyListeners();
  }

  void addFolder(NotesFolder folder) {
    assert(folder.parent == this);
    folder.addListener(_entityChanged);

    _folders.add(folder);
    _entityMap[folder.folderPath] = folder;

    notifyFolderAdded(_folders.length - 1, folder);
  }

  void removeFolder(NotesFolder folder) {
    folder.removeListener(_entityChanged);

    assert(_folders.indexWhere((f) => f.folderPath == folder.folderPath) != -1);
    assert(_entityMap.containsKey(folder.folderPath));

    var index = _folders.indexWhere((f) => f.folderPath == folder.folderPath);
    assert(index != -1);
    _folders.removeAt(index);
    _entityMap.remove(folder.folderPath);

    notifyFolderRemoved(index, folder);
  }

  void rename(String newName) {
    var dir = Directory(folderPath);
    var parentDirName = dirname(folderPath);
    dir.renameSync(folderPath);
    _folderPath = p.join(parentDirName, newName);

    notifyListeners();
  }

  String pathSpec() {
    if (parent == null) {
      return "";
    }
    return p.join(parent.pathSpec(), name);
  }

  @override
  int compareTo(NotesFolder other) {
    return folderPath.compareTo(other.folderPath);
  }

  Iterable<Note> getAllNotes() sync* {
    for (var note in _notes) {
      yield note;
    }

    for (var folder in _folders) {
      var notes = folder.getAllNotes();
      for (var note in notes) {
        yield note;
      }
    }
  }
}
