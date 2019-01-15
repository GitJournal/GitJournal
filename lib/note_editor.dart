import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journal/note.dart';
import 'package:journal/state_container.dart';

class NoteEditor extends StatefulWidget {
  @override
  NoteEditorState createState() {
    return new NoteEditorState();
  }
}

class NoteEditorState extends State<NoteEditor> {
  static final GlobalKey<FormFieldState<String>> noteTextKey =
      GlobalKey<FormFieldState<String>>();

  final DateTime _createdAt;

  NoteEditorState() : _createdAt = new DateTime.now();

  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);

    var bodyWidget = new Container(
      child: new Form(
        // Show a dialog if discarding non-empty notes
        onWillPop: () {
          return Future(() {
            var noteContent = noteTextKey.currentState.value.trim();
            if (noteContent.isEmpty) {
              return true;
            }
            return showDialog(
              context: context,
              builder: (BuildContext context) {
                return new AlertDialog(
                  title: new Text('Are you sure?'),
                  content: new Text('Do you want to discard the entry'),
                  actions: <Widget>[
                    new FlatButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: new Text('No'),
                    ),
                    new FlatButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: new Text('Yes'),
                    ),
                  ],
                );
              },
            );
          });
        },
        child: TextFormField(
          key: noteTextKey,
          autofocus: true,
          keyboardType: TextInputType.multiline,
          maxLines: 5000,
          decoration: new InputDecoration(
            hintText: 'Write here',
          ),
        ),
      ),
      padding: const EdgeInsets.all(8.0),
    );

    var newJournalScreen = new Scaffold(
      appBar: new AppBar(
        title: new Text("New Journal Entry"),
      ),
      body: bodyWidget,
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.check),
          onPressed: () {
            var noteContent = noteTextKey.currentState.value;
            var note = new Note(
              created: _createdAt,
              body: noteContent,
            );
            container.addNote(note);

            Navigator.pop(context);
          }),
    );

    return newJournalScreen;
  }
}
