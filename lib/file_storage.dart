import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart' as p;

import './note.dart';

class FileStorage {
  final Future<Directory> Function() getDirectory;

  FileStorage(this.getDirectory);

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
    final json = JsonDecoder().convert(string);
    return new Note.fromJson(json);
  }

  Future<Directory> saveNotes(List<Note> notes) async {
    final dir = await getDirectory();
    //await dir.delete(recursive: true);

    for (var note in notes) {
      var filePath = p.join(dir.path, note.id);

      var file = new File(filePath);
      var contents = JsonEncoder().convert(note.toJson());
      await file.writeAsString(contents);
    }

    return dir;
  }
}
