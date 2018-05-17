import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'note.dart';
import 'note_editor.dart';
import 'note_viewer.dart';

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

class JournalList extends StatelessWidget {
  final _biggerFont = const TextStyle(fontSize: 18.0);

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
              return _buildSuggestions(context, notes);
            } else if (snapshot.hasError) {
              return new Text("${snapshot.error}");
            }

            return new CircularProgressIndicator();
          }),
    );
  }

  Widget _buildRow(BuildContext context, Note journal) {
    var formatter = new DateFormat('dd MMM, yyyy');
    var title = formatter.format(journal.createdAt);

    var timeFormatter = new DateFormat('Hm');
    var time = timeFormatter.format(journal.createdAt);

    var body = journal.body;
    if (body.length >= 100) {
      body = body.substring(0, 100);
    }
    body = body.replaceAll("\n", " ");

    return new ListTile(
      isThreeLine: true,
      title: new Text(
        title,
        style: _biggerFont,
      ),
      subtitle: new Text(time + "\n" + body),
      onTap: () => _itemTapped(context, journal),
    );
  }

  void _itemTapped(BuildContext context, Note note) {
    var route =
        new MaterialPageRoute(builder: (context) => new NoteViewer(note: note));
    Navigator.of(context).push(route);
  }

  Widget _buildSuggestions(BuildContext context, List<Note> notes) {
    return new ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (context, i) {
        if (i >= notes.length) {
          return null;
        }
        //if (i.isOdd) return new Divider();
        return _buildRow(context, notes[i]);
      },
    );
  }

  void _newPost(BuildContext context) {
    var route = new MaterialPageRoute(builder: (context) => new NoteEditor());
    Navigator.of(context).push(route);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(title: 'Journal', home: new JournalList());
  }
}
