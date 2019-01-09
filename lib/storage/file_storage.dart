import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:journal/note.dart';
import 'package:journal/storage/notes_repository.dart';
import 'package:journal/storage/serializers.dart';
import 'package:path/path.dart' as p;

typedef String NoteFileNameGenerator(Note note);

/// Each Note is saved in a different file
class FileStorage implements NoteRepository {
  final Future<Directory> Function() getDirectory;
  final NoteSerializer noteSerializer;
  final NoteFileNameGenerator fileNameGenerator;

  const FileStorage({
    @required this.getDirectory,
    @required this.noteSerializer,
    @required this.fileNameGenerator,
  });

  @override
  Future<List<Note>> listNotes() async {
    final dir = await getDirectory();

    var notes = new List<Note>();
    var lister = dir.list(recursive: false);
    await for (var fileEntity in lister) {
      Note note = await _loadNote(fileEntity);
      if (note == null) {
        continue;
      }
      if (note.id == null) {
        String filename = p.basename(fileEntity.path);
        note.id = filename;
      }
      notes.add(note);
    }

    // Reverse sort
    notes.sort((a, b) => b.compareTo(a));
    return notes;
  }

  Future<Note> _loadNote(FileSystemEntity entity) async {
    if (entity is! File) {
      return null;
    }
    var file = entity as File;
    final string = await file.readAsString();
    return noteSerializer.decode(string);
  }

  @override
  Future<NoteRepoResult> addNote(Note note) async {
    final dir = await getDirectory();
    var filePath = p.join(dir.path, fileNameGenerator(note));

    var file = new File(filePath);
    if (file == null) {
      return NoteRepoResult(error: true);
    }
    var contents = noteSerializer.encode(note);
    await file.writeAsString(contents);

    return NoteRepoResult(noteFilePath: filePath, error: false);
  }

  @override
  Future<NoteRepoResult> removeNote(Note note) async {
    final dir = await getDirectory();
    var filePath = p.join(dir.path, fileNameGenerator(note));

    var file = new File(filePath);
    await file.delete();

    return NoteRepoResult(noteFilePath: filePath, error: false);
  }

  @override
  Future<NoteRepoResult> updateNote(Note note) async {
    return addNote(note);
  }

  @override
  Future<bool> sync() async {
    return false;
  }

  Future<Directory> saveNotes(List<Note> notes) async {
    final dir = await getDirectory();
    // FIXME: Why do we need to delete everything?
    // await dir.delete(recursive: true);

    for (var note in notes) {
      var filePath = p.join(dir.path, fileNameGenerator(note));

      var file = new File(filePath);
      var contents = noteSerializer.encode(note);
      await file.writeAsString(contents);
    }

    return dir;
  }
}
