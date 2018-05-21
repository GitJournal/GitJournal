import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
import 'package:journal/app.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:journal/file_storage.dart';

/*
import 'note.dart';

Future<List<Note>> fetchNotes() async {
  final response = await http.get('http://192.168.1.132:8000/notes');
  final responseJson = json.decode(response.body);

  var notes = <Note>[];
  for (var postJson in responseJson) {
    notes.add(new Note.fromJson(postJson));
  }

  return notes;
}
*/

void main() {
  runApp(new JournalApp(
    fileStorage: FileStorage(
      getDirectory: getNotesDir,
    ),
  ));
}

Future<Directory> getNotesDir() async {
  var appDir = await getApplicationDocumentsDirectory();
  var dir = new Directory(p.join(appDir.path, "notes"));
  await dir.create();

  return dir;
}
