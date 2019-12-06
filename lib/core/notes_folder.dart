import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';

import 'note.dart';
import 'note_fs_entity.dart';

class NotesFolder with ChangeNotifier {
  NotesFolder parent;
  List<NoteFSEntity> _entities = [];
  String folderPath;

  NotesFolder(this.parent, this.folderPath);

  bool get isEmpty {
    return _entities.isEmpty;
  }

  String get name {
    return basename(folderPath);
  }

  bool get hasSubFolders {
    return _entities.firstWhere((e) => e.isFolder, orElse: () => null) != null;
  }

  bool get hasNotes {
    return _entities.firstWhere((e) => e.isNote, orElse: () => null) != null;
  }

  int get numberOfNotes {
    int i = 0;
    _entities.forEach((e) {
      if (e.isNote) i++;
    });
    return i;
  }

  // Recurisvely gets all Notes within this folder
  List<Note> getAllNotes() {
    var notes = <Note>[];

    for (var entity in _entities) {
      if (entity.isNote) {
        notes.add(entity.note);
      } else {
        notes.addAll(entity.folder.getAllNotes());
      }
    }
    return notes;
  }

  List<Note> getNotes() {
    return _entities.where((e) => e.isNote).map((e) => e.note).toList();
  }

  List<NotesFolder> getFolders() {
    return _entities.where((e) => e.isFolder).map((e) => e.folder).toList();
  }

  // FIXME: This asynchronously loads everything. Maybe it should just list them, and the individual _entities
  //        should be loaded as required?
  // FIXME: This should not reconstruct the Notes or NotesFolders once constructed.
  Future<void> loadRecursively() async {
    final dir = Directory(folderPath);
    _entities = [];

    var lister = dir.list(recursive: false, followLinks: false);
    await for (var fsEntity in lister) {
      if (fsEntity is Directory) {
        var subFolder = NotesFolder(this, fsEntity.path);
        if (subFolder.name.startsWith('.')) {
          continue;
        }
        await subFolder.loadRecursively();

        var noteFSEntity = NoteFSEntity(folder: subFolder);
        _entities.add(noteFSEntity);
      }

      var note = Note(this, fsEntity.path);
      if (!note.filePath.toLowerCase().endsWith('.md')) {
        continue;
      }
      await note.load();

      var noteFSEntity = NoteFSEntity(note: note);
      _entities.add(noteFSEntity);
    }

    notifyListeners();
  }

  void add(Note note) {
    assert(note.parent == this);
    _entities.add(NoteFSEntity(note: note));

    notifyListeners();
  }

  void insert(int index, Note note) {
    assert(note.parent == this);

    for (var i = 0; i < _entities.length; i++) {
      var e = _entities[i];
      if (e is NotesFolder) continue;

      if (index == 0) {
        _entities.insert(i, NoteFSEntity(note: note));
        notifyListeners();
        return;
      }
      index--;
    }
  }

  void remove(Note note) {
    assert(note.parent == this);
    var i = _entities.indexWhere((e) {
      if (e.isFolder) return false;
      return e.note.filePath == note.filePath;
    });
    assert(i != -1);

    _entities.removeAt(i);
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
  }

  void addFolder(NotesFolder folder) {
    assert(folder.parent == this);
    _entities.add(NoteFSEntity(folder: folder));

    notifyListeners();
  }
}
