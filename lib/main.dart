import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;

import 'package:journal/app.dart';
import 'package:journal/state_container.dart';

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
  runApp(new StateContainer(
    child: JournalApp(),
  ));
}
