import 'dart:io';

import 'package:gitjournal/features.dart';
import 'package:gitjournal/utils/logger.dart';

import 'package:path/path.dart' as p;
import 'package:path/path.dart';
import 'package:synchronized/synchronized.dart';

import 'note.dart';
import 'notes_folder.dart';
import 'notes_folder_notifier.dart';

class NotesFolderFS with NotesFolderNotifier implements NotesFolder {
  final NotesFolderFS _parent;
  String _folderPath;
  var _lock = Lock();

  List<Note> _notes = [];
  List<NotesFolderFS> _folders = [];

  Map<String, dynamic> _entityMap = {};
  NotesFolderConfig _config;

  NotesFolderFS(this._parent, this._folderPath);

  @override
  void dispose() {
    _folders.forEach((f) => f.removeListener(_entityChanged));
    _notes.forEach((f) => f.removeListener(_entityChanged));

    super.dispose();
  }

  @override
  NotesFolder get parent => _parent;

  NotesFolderFS get parentFS => _parent;

  void _entityChanged() {
    notifyListeners();
  }

  void _noteModified(Note note) {
    notifyNoteModified(-1, note);
  }

  void reset(String folderPath) {
    _folderPath = folderPath;

    var notesCopy = List<Note>.from(_notes);
    notesCopy.forEach(remove);

    var foldersCopy = List<NotesFolderFS>.from(_folders);
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

  @override
  String get name => basename(folderPath);

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

  @override
  List<NotesFolder> get subFolders => subFoldersFS;

  List<NotesFolderFS> get subFoldersFS {
    // FIXME: This is really not ideal
    _folders.sort((NotesFolderFS a, NotesFolderFS b) =>
        a.folderPath.compareTo(b.folderPath));
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

  Future<void> load() async {
    return _lock.synchronized(() async {
      return _load();
    });
  }

  // FIXME: This should not reconstruct the Notes or NotesFolders once constructed.
  Future<void> _load() async {
    Set<String> pathsFound = {};

    // Load the Folder config if exists
    if (Features.perFolderConfig) {
      _config = await NotesFolderConfig.fromFS(this);
    }

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
        //Log.d("Found directory ${fsEntity.path}");
        var subFolder = NotesFolderFS(this, fsEntity.path);
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
        //Log.d("Ignoring file ${fsEntity.path}");
        continue;
      }
      //Log.d("Found file ${fsEntity.path}");
      note.addModifiedListener(_noteModified);

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
      _entityMap.remove(path);

      if (e is Note) {
        Log.d("File $path was no longer found");
        e.removeModifiedListener(_noteModified);
        var i = _notes.indexWhere((n) => n.filePath == path);
        assert(i != -1);
        var note = _notes[i];
        _notes.removeAt(i);
        notifyNoteRemoved(i, note);
      } else {
        Log.d("Folder $path was no longer found");
        e.removeListener(_entityChanged);
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
    note.addModifiedListener(_noteModified);

    _notes.add(note);
    _entityMap[note.filePath] = note;

    notifyNoteAdded(_notes.length - 1, note);
  }

  void insert(int index, Note note) {
    assert(note.parent == this);
    assert(index >= 0);
    note.addModifiedListener(_noteModified);

    _notes.insert(index, note);
    _entityMap[note.filePath] = note;

    notifyNoteAdded(index, note);
  }

  void remove(Note note) {
    assert(note.parent == this);
    note.removeModifiedListener(_noteModified);

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

  void addFolder(NotesFolderFS folder) {
    assert(folder.parent == this);
    folder.addListener(_entityChanged);

    _folders.add(folder);
    _entityMap[folder.folderPath] = folder;

    notifyFolderAdded(_folders.length - 1, folder);
  }

  void removeFolder(NotesFolderFS folder) {
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

  @override
  String pathSpec() {
    if (parent == null) {
      return "";
    }
    return p.join(parent.pathSpec(), name);
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

  @override
  NotesFolder get fsFolder {
    return this;
  }

  NotesFolderFS getFolderWithSpec(String spec) {
    if (pathSpec() == spec) {
      return this;
    }
    for (var f in _folders) {
      var res = f.getFolderWithSpec(spec);
      if (res != null) {
        return res;
      }
    }

    return null;
  }

  Note getNoteWithSpec(String spec) {
    var parts = spec.split(p.separator);
    var folder = this;
    while (parts.length != 1) {
      var folderName = parts[0];

      bool foundFolder = false;
      for (var f in _folders) {
        if (f.name == folderName) {
          folder = f;
          foundFolder = true;
          break;
        }
      }

      if (!foundFolder) {
        return null;
      }
      parts.removeAt(0);
    }

    var fileName = parts[0];
    for (var note in folder.notes) {
      if (note.fileName == fileName) {
        return note;
      }
    }

    return null;
  }

  @override
  NotesFolderConfig get config {
    if (Features.perFolderConfig && _config != null) {
      return _config;
    }
    return NotesFolderConfig.fromSettings(this);
  }

  @override
  set config(NotesFolderConfig config) {
    if (Features.perFolderConfig) {
      _config = config;
    } else {
      config.saveToSettings();
    }
  }
}
