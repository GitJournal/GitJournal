import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:journal/note.dart';
import 'package:journal/storage/notes_repository.dart';
import 'package:journal/storage/serializers.dart';
import 'package:path/path.dart' as p;

typedef String NoteFileNameGenerator(Note note);

/// Each Note is saved in a different file
/// Each note must have a fileName which ends in a .md
class FileStorage implements NoteRepository {
  final Future<Directory> Function() getDirectory;
  final NoteSerializer noteSerializer;

  const FileStorage({
    @required this.getDirectory,
    @required this.noteSerializer,
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
      if (!note.fileName.toLowerCase().endsWith('.md')) {
        continue;
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

    var note = noteSerializer.decode(string);
    note.fileName = p.basename(entity.path);
    return note;
  }

  @override
  Future<NoteRepoResult> addNote(Note note) async {
    final dir = await getDirectory();
    var filePath = p.join(dir.path, note.fileName);

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
    var filePath = p.join(dir.path, note.fileName);

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

    for (var note in notes) {
      var filePath = p.join(dir.path, note.fileName);

      var file = new File(filePath);
      var contents = noteSerializer.encode(note);
      await file.writeAsString(contents);
    }

    return dir;
  }
}
