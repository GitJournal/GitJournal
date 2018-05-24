import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:journal/state_container.dart';
import 'package:journal/widgets/journal_list.dart';
import 'package:journal/note.dart';
import 'package:journal/note_editor.dart';
import 'package:journal/note_viewer.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    final appState = container.appState;

    var createButton = new FloatingActionButton(
      onPressed: () => _newPost(context),
      child: new Icon(Icons.add),
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Journal'),
      ),
      floatingActionButton: createButton,
      /*
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
      */
      body: new JournalList(
        notes: appState.notes,
        noteSelectedFunction: (note) => _noteSelected(note, context),
      ),
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
