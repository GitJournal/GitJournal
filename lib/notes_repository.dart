import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:journal/file_storage.dart';
import 'package:journal/note.dart';
import 'package:journal/serializers.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

abstract class NoteRepository {
  // Syncs the repo
  // - git pull with an auto merge
  // - git push

  // TODO: Better error message!
  Future<bool> sync();

  Future<bool> addNote(Note note);
  Future<bool> updateNote(Note note);
  Future<bool> removeNote(Note note);

  Future<List<Note>> listNotes();
}

Future<Directory> getNotesDir() async {
  var appDir = await getApplicationDocumentsDirectory();
  var dir = new Directory(p.join(appDir.path, "notes"));
  await dir.create();

  return dir;
}

class GitNoteRepository implements NoteRepository {
  FileStorage _fileStorage = new FileStorage(
    getDirectory: getNotesDir,
    noteSerializer: new MarkdownYAMLSerializer(),
    fileNameGenerator: (Note note) => note.id,
  );
  final String gitUrl;
  final String dirPath;

  GitNoteRepository({
    @required this.gitUrl,
    @required this.dirPath,
  }) {
    // FIXME: This isn't correct. The gitUrl might not be cloned at this point!
  }

  @override
  Future<bool> addNote(Note note) async {
    return _fileStorage.addNote(note);
  }

  @override
  Future<List<Note>> listNotes() {
    return _fileStorage.listNotes();
  }

  @override
  Future<bool> removeNote(Note note) async {
    return _fileStorage.removeNote(note);
  }

  @override
  Future<bool> sync() async {
    return false;
  }

  @override
  Future<bool> updateNote(Note note) async {
    return _fileStorage.updateNote(note);
  }
}
