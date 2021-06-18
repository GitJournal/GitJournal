import 'dart:collection';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';
import 'package:synchronized/synchronized.dart';

import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/utils/logger.dart';
import 'note.dart';
import 'notes_folder.dart';
import 'notes_folder_notifier.dart';

enum IgnoreReason {
  HiddenFile,
  InvalidExtension,
}

class IgnoredFile {
  String filePath;
  IgnoreReason reason;

  IgnoredFile({required this.filePath, required this.reason});

  String get fileName {
    return p.basename(filePath);
  }
}

class NotesFolderFS with NotesFolderNotifier implements NotesFolder {
  final NotesFolderFS? _parent;
  String _folderPath;
  var _lock = Lock();

  List<Note> _notes = [];
  List<NotesFolderFS> _folders = [];
  List<IgnoredFile> _ignoredFiles = [];

  Map<String, dynamic> _entityMap = {};
  Settings settings;

  NotesFolderFS(this._parent, this._folderPath, this.settings);

  @override
  void dispose() {
    _folders.forEach((f) => f.removeListener(_entityChanged));
    _notes.forEach((f) => f.removeListener(_entityChanged));

    super.dispose();
  }

  @override
  NotesFolder? get parent => _parent;

  NotesFolderFS? get parentFS => _parent;

  void _entityChanged() {
    notifyListeners();
  }

  void _noteModified(Note note) {
    notifyNoteModified(-1, note);
  }

  void _noteRenamed(Note note, String oldPath) {
    assert(_entityMap.containsKey(oldPath));
    _entityMap.remove(oldPath);
    _entityMap[note.filePath] = note;

    notifyNoteRenamed(-1, note, oldPath);
  }

  void _subFolderRenamed(NotesFolderFS folder, String oldPath) {
    assert(_entityMap.containsKey(oldPath));
    _entityMap.remove(oldPath);
    _entityMap[folder.folderPath] = folder;
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

  List<IgnoredFile> get ignoredFiles => _ignoredFiles;

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
      //        Each of these needs to be reported to sentry, as Note loading should never fail
      var f = note.load();
      futures.add(f);

      if (futures.length >= maxParallel) {
        await Future.wait(futures);
        futures = <Future>[];
      }
    }

    await Future.wait(futures);
    futures = <Future>[];

    // Remove notes which have errors
    var errFunc = (Note n) => n.loadState == NoteLoadState.Error;
    var hasBadNotes = _notes.any(errFunc);
    if (hasBadNotes) {
      while (true) {
        var i = _notes.indexWhere(errFunc);
        if (i == -1) {
          break;
        }
        var note = _notes.removeAt(i);
        notifyNoteRemoved(i, note);
      }
    }

    for (var folder in _folders) {
      var f = folder.loadRecursively();
      futures.add(f);
    }

    await Future.wait(futures);
  }

  Future<void> load() async {
    return _lock.synchronized(() async {
      return _load();
    });
  }

  // FIXME: This should not reconstruct the Notes or NotesFolders once constructed.
  Future<void> _load() async {
    var ignoreFilePath = p.join(folderPath, ".gjignore");
    if (File(ignoreFilePath).existsSync()) {
      Log.i("Ignoring $folderPath as it has .gjignore");
      return;
    }
    Set<String> pathsFound = {};

    // Load the Folder config if exists
    /*
    if (Features.perFolderConfig) {
      _config = await NotesFolderConfig.fromFS(this);
    } */

    _ignoredFiles = <IgnoredFile>[];

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
        var subFolder = NotesFolderFS(this, fsEntity.path, settings);
        if (subFolder.name.startsWith('.')) {
          // Log.v("Ignoring Folder", props: {
          //   "path": fsEntity.path,
          //   "reason": "Hidden folder",
          // });
          continue;
        }
        // Log.v("Found Folder", props: {"path": fsEntity.path});
        _addFolderListeners(subFolder);

        _folders.add(subFolder);
        _entityMap[fsEntity.path] = subFolder;

        pathsFound.add(fsEntity.path);
        notifyFolderAdded(_folders.length - 1, subFolder);
        continue;
      }

      var note = Note(this, fsEntity.path);
      if (note.fileName.startsWith('.')) {
        // FIXME: Why does 'tr' not work over here
        var ignoredFile = IgnoredFile(
          filePath: fsEntity.path,
          reason: IgnoreReason.HiddenFile,
        );
        _ignoredFiles.add(ignoredFile);

        // Log.v("Ignoring file", props: {
        //   "path": ignoredFile.filePath,
        //   "reason": ignoredFile.reason.toString(),
        // });
        continue;
      }
      if (!NoteFileFormatInfo.isAllowedFileName(note.filePath)) {
        var ignoredFile = IgnoredFile(
          filePath: fsEntity.path,
          reason: IgnoreReason.InvalidExtension,
        );
        _ignoredFiles.add(ignoredFile);

        // Log.v("Ignoring file", props: {
        //   "path": ignoredFile.filePath,
        //   "reason": ignoredFile.reason.toString(),
        // });
        continue;
      }
      // Log.v("Found file", props: {"path": fsEntity.path});
      _addNoteListeners(note);

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
        // Log.v("File $path was no longer found");
        _removeNoteListeners(e);

        var i = _notes.indexWhere((n) => n.filePath == path);
        assert(i != -1);
        var note = _notes[i];
        _notes.removeAt(i);
        notifyNoteRemoved(i, note);
      } else {
        // Log.v("Folder $path was no longer found");
        _removeFolderListeners(e);

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
    _addNoteListeners(note);

    _notes.add(note);
    _entityMap[note.filePath] = note;

    notifyNoteAdded(_notes.length - 1, note);
  }

  void remove(Note note) {
    assert(note.parent == this);
    _removeNoteListeners(note);

    assert(_notes.indexWhere((n) => n.filePath == note.filePath) != -1);
    assert(_entityMap.containsKey(note.filePath));

    var index = _notes.indexWhere((n) => n.filePath == note.filePath);
    assert(index != -1);
    _notes.removeAt(index);
    _entityMap.remove(note.filePath);

    notifyNoteRemoved(index, note);
  }

  void _addNoteListeners(Note note) {
    note.addModifiedListener(_noteModified);
    note.addRenameListener(_noteRenamed);
  }

  void _removeNoteListeners(Note note) {
    note.removeModifiedListener(_noteModified);
    note.removeRenameListener(_noteRenamed);
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
    _addFolderListeners(folder);

    _folders.add(folder);
    _entityMap[folder.folderPath] = folder;

    notifyFolderAdded(_folders.length - 1, folder);
  }

  void removeFolder(NotesFolderFS folder) {
    var notesCopy = List<Note>.from(folder._notes);
    notesCopy.forEach(folder.remove);

    var foldersCopy = List<NotesFolderFS>.from(folder._folders);
    foldersCopy.forEach(folder.removeFolder);

    _removeFolderListeners(folder);

    assert(_folders.indexWhere((f) => f.folderPath == folder.folderPath) != -1);
    assert(_entityMap.containsKey(folder.folderPath));

    var index = _folders.indexWhere((f) => f.folderPath == folder.folderPath);
    assert(index != -1);
    _folders.removeAt(index);
    _entityMap.remove(folder.folderPath);

    notifyFolderRemoved(index, folder);
  }

  void rename(String newName) {
    var oldPath = _folderPath;
    var dir = Directory(_folderPath);
    _folderPath = p.join(dirname(_folderPath), newName);
    dir.renameSync(_folderPath);

    notifyThisFolderRenamed(this, oldPath);
  }

  void _addFolderListeners(NotesFolderFS folder) {
    folder.addListener(_entityChanged);
    folder.addThisFolderRenamedListener(_subFolderRenamed);
  }

  void _removeFolderListeners(NotesFolderFS folder) {
    folder.removeListener(_entityChanged);
    folder.removeThisFolderRenamedListener(_subFolderRenamed);
  }

  @override
  String pathSpec() {
    if (parent == null) {
      return "";
    }
    return p.join(parent!.pathSpec(), name);
  }

  @override
  String get publicName {
    var spec = pathSpec();
    if (spec.isEmpty) {
      return tr("rootFolder");
    }
    return spec;
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

  NotesFolderFS? getFolderWithSpec(String spec) {
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

  NotesFolderFS get rootFolder {
    var folder = this;
    while (folder.parent != null) {
      folder = folder.parent as NotesFolderFS;
    }
    return folder;
  }

  Note? getNoteWithSpec(String spec) {
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
    return NotesFolderConfig.fromSettings(this, settings);
  }

  SplayTreeSet<String> getNoteTagsRecursively() {
    return _fetchTags(this, SplayTreeSet<String>());
  }

  Future<List<Note>> matchNotes(NoteMatcherAsync pred) async {
    var matchedNotes = <Note>[];
    await _matchNotes(matchedNotes, pred);
    return matchedNotes;
  }

  Future<List<Note>> _matchNotes(
    List<Note> matchedNotes,
    NoteMatcherAsync pred,
  ) async {
    for (var note in _notes) {
      var matches = await pred(note);
      if (matches) {
        matchedNotes.add(note);
      }
    }

    for (var folder in _folders) {
      await folder._matchNotes(matchedNotes, pred);
    }
    return matchedNotes;
  }
}

typedef NoteMatcherAsync = Future<bool> Function(Note n);

SplayTreeSet<String> _fetchTags(NotesFolder folder, SplayTreeSet<String> tags) {
  for (var note in folder.notes) {
    tags.addAll(note.tags);
    tags.addAll(note.inlineTags);
  }

  for (var folder in folder.subFolders) {
    tags = _fetchTags(folder, tags);
  }

  return tags;
}
