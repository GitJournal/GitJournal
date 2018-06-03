import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:journal/serializers.dart';
import 'package:path/path.dart' as p;

import './note.dart';

typedef String NoteFileNameGenerator(Note note);

class FileStorage {
  final Future<Directory> Function() getDirectory;
  final NoteSerializer noteSerializer;
  final NoteFileNameGenerator fileNameGenerator;

  const FileStorage({
    @required this.getDirectory,
    @required this.noteSerializer,
    @required this.fileNameGenerator,
  });

  Future<List<Note>> loadNotes() async {
    final dir = await getDirectory();

    var notes = new List<Note>();
    var lister = dir.list(recursive: false);
    await for (var fileEntity in lister) {
      Note note = await _loadNote(fileEntity);
      notes.add(note);
    }

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

  Future<Directory> saveNotes(List<Note> notes) async {
    final dir = await getDirectory();
    await dir.delete(recursive: true);
    await dir.create();

    for (var note in notes) {
      var filePath = p.join(dir.path, fileNameGenerator(note));

      var file = new File(filePath);
      var contents = noteSerializer.encode(note);
      await file.writeAsString(contents);
    }

    return dir;
  }
}
