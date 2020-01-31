import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';

import 'note.dart';
import 'note_fs_entity.dart';

class NotesFolder with ChangeNotifier implements Comparable<NotesFolder> {
  final NotesFolder parent;
  String folderPath;

  List<NoteFSEntity> _entities = [];
  Map<String, NoteFSEntity> _entityMap = {};

  NotesFolder(this.parent, this.folderPath);

  @override
  void dispose() {
    _entities.forEach((e) {
      if (e.isFolder) {
        e.folder.removeListener(_entityChanged);
      } else {
        e.note.removeListener(_entityChanged);
      }
    });
    super.dispose();
  }

  void _entityChanged() {
    notifyListeners();
  }

  bool get isEmpty {
    return _entities.isEmpty;
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
    return _entities.firstWhere((e) => e.isFolder, orElse: () => null) != null;
  }

  bool get hasNotes {
    return _entities.firstWhere((e) => e.isNote, orElse: () => null) != null;
  }

  bool get hasNotesRecursive {
    bool has = hasNotes;
    if (has) return true;

    for (var i = 0; i < _entities.length; i++) {
      var e = _entities[i];
      if (e.isNote) continue;

      has = has || e.folder.hasNotes;
      if (has) {
        return true;
      }
    }

    return has;
  }

  int get numberOfNotes {
    int i = 0;
    _entities.forEach((e) {
      if (e.isNote) i++;
    });
    return i;
  }

  List<Note> getNotes() {
    return _entities.where((e) => e.isNote).map((e) => e.note).toList();
  }

  List<NotesFolder> getFolders() {
    var list = _entities.where((e) => e.isFolder).map((e) => e.folder).toList();
    list.sort();
    return list;
  }

  // FIXME: This asynchronously loads everything. Maybe it should just list them, and the individual _entities
  //        should be loaded as required?
  Future<void> loadRecursively() async {
    const maxParallel = 10;
    var futures = <Future>[];

    await load();
    for (var i = 0; i < _entities.length; i++) {
      var e = _entities[i];
      if (e.isFolder) {
        var f = e.folder.loadRecursively();
        futures.add(f);
      } else {
        // FIXME: Collected all the Errors, and report them back, along with "WHY", and the contents of the Note
        //        Each of these needs to be reported to crashlytics, as Note loading should never fail
        var f = e.note.load();
        futures.add(f);
      }

      if (futures.length >= maxParallel) {
        await Future.wait(futures);
        futures = <Future>[];
      }
    }
  }

  // FIXME: This should not reconstruct the Notes or NotesFolders once constructed.
  Future<void> load() async {
    Set<String> pathsFound = {};

    var entitiesAdded = false;
    var entitiesRemoved = false;

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
        var subFolder = NotesFolder(this, fsEntity.path);
        if (subFolder.name.startsWith('.')) {
          continue;
        }
        subFolder.addListener(_entityChanged);

        var noteFSEntity = NoteFSEntity(folder: subFolder);
        _entities.add(noteFSEntity);
        _entityMap[fsEntity.path] = noteFSEntity;

        pathsFound.add(fsEntity.path);
        entitiesAdded = true;
        continue;
      }

      var note = Note(this, fsEntity.path);
      if (!note.filePath.toLowerCase().endsWith('.md')) {
        continue;
      }
      note.addListener(_entityChanged);

      var noteFSEntity = NoteFSEntity(note: note);
      _entities.add(noteFSEntity);
      _entityMap[fsEntity.path] = noteFSEntity;

      pathsFound.add(fsEntity.path);
      entitiesAdded = true;
    }

    Set<String> pathsRemoved = _entityMap.keys.toSet().difference(pathsFound);
    pathsRemoved.forEach((path) {
      var e = _entityMap[path];
      assert(e != null);

      if (e.isFolder) {
        e.folder.removeListener(_entityChanged);
      } else {
        e.note.removeListener(_entityChanged);
      }

      _entityMap.remove(path);
    });
    _entities.removeWhere((e) {
      String path = e.isFolder ? e.folder.folderPath : e.note.filePath;
      return pathsRemoved.contains(path);
    });

    entitiesRemoved = pathsRemoved.isNotEmpty;
    if (entitiesAdded || entitiesRemoved) {
      notifyListeners();
    }
  }

  void add(Note note) {
    assert(note.parent == this);
    note.addListener(_entityChanged);

    var entity = NoteFSEntity(note: note);
    _entities.add(entity);
    _entityMap[note.filePath] = entity;

    notifyListeners();
  }

  void insert(int index, Note note) {
    assert(note.parent == this);
    assert(index >= 0);
    note.addListener(_entityChanged);

    if (_entities.isEmpty) {
      var entity = NoteFSEntity(note: note);
      _entities.add(entity);
      _entityMap[note.filePath] = entity;
      notifyListeners();
      return;
    }

    for (var i = 0; i < _entities.length; i++) {
      var e = _entities[i];
      if (e is NotesFolder) continue;

      if (index == 0) {
        var entity = NoteFSEntity(note: note);
        _entities.insert(i, entity);
        _entityMap[note.filePath] = entity;
        notifyListeners();
        return;
      }
      index--;
    }
  }

  void remove(Note note) {
    assert(note.parent == this);
    note.removeListener(_entityChanged);

    var i = _entities.indexWhere((e) {
      if (e.isFolder) return false;
      return e.note.filePath == note.filePath;
    });
    assert(i != -1);

    _entities.removeAt(i);
    _entityMap.remove(note.filePath);

    notifyListeners();
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

    var entity = NoteFSEntity(folder: folder);
    _entities.add(entity);
    _entityMap[folder.folderPath] = entity;

    notifyListeners();
  }

  void removeFolder(NotesFolder folder) {
    folder.removeListener(_entityChanged);

    var i = _entities.indexWhere((e) {
      if (e.isNote) return false;
      return e.folder.folderPath == folder.folderPath;
    });
    assert(i != -1);

    _entities.removeAt(i);
    _entityMap.remove(folder.folderPath);

    notifyListeners();
  }

  void rename(String newName) {
    var dir = Directory(folderPath);
    var parentDirName = dirname(folderPath);
    dir.renameSync(folderPath);
    folderPath = p.join(parentDirName, newName);

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
}
