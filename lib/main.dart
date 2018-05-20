import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'note.dart';
import 'note_editor.dart';
import 'note_viewer.dart';
import 'journal_list.dart';

Future<List<Note>> fetchNotes() async {
  final response = await http.get('http://192.168.1.132:8000/notes');
  final responseJson = json.decode(response.body);

  var notes = <Note>[];
  for (var postJson in responseJson) {
    notes.add(new Note.fromJson(postJson));
  }

  return notes;
}

void main() => runApp(new MyApp());

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var createButton = new FloatingActionButton(
      onPressed: () => _newPost(context),
      child: new Icon(Icons.add),
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Journal'),
      ),
      floatingActionButton: createButton,
      body: new FutureBuilder<List<Note>>(
          future: fetchNotes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var notes = snapshot.data;
              return new JournalList(
                notes: notes,
                noteSelectedFunction: (note) => _noteSelected(note, context),
              );
            } else if (snapshot.hasError) {
              return new Text("${snapshot.error}");
            }

            return new CircularProgressIndicator();
          }),
    );
  }

  void _noteSelected(Note note, BuildContext context) {
    var route =
        new MaterialPageRoute(builder: (context) => new NoteViewer(note: note));
    Navigator.of(context).push(route);
  }

  void _newPost(BuildContext context) {
    var route = new MaterialPageRoute(builder: (context) => new NoteEditor());
    Navigator.of(context).push(route);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Journal',
      home: new HomeScreen(),
      theme: new ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.lightBlue[800],
        accentColor: Colors.cyan[600],
      ),
    );
  }
}
