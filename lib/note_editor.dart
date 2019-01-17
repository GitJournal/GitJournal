import 'dart:async';

import 'package:flutter/material.dart';

import 'package:journal/note.dart';
import 'package:journal/state_container.dart';
import 'package:journal/widgets/note_header.dart';

class NoteEditor extends StatefulWidget {
  final Note note;

  NoteEditor() : note = null;
  NoteEditor.fromNote(this.note);

  @override
  NoteEditorState createState() {
    if (note == null) {
      return new NoteEditorState();
    } else {
      return new NoteEditorState.fromNote(note);
    }
  }
}

class NoteEditorState extends State<NoteEditor> {
  Note note = new Note();
  final bool newNote;
  TextEditingController _textController = new TextEditingController();

  NoteEditorState() : newNote = true {
    note.created = new DateTime.now();
  }

  NoteEditorState.fromNote(Note n) : newNote = false {
    note = n;
    _textController = new TextEditingController(text: note.body);
  }

  @override
  Widget build(BuildContext context) {
    var bodyWidget = Form(
      // Show a dialog if discarding non-empty notes
      onWillPop: () {
        return Future(() {
          var noteContent = _textController.text.trim();
          if (noteContent.isEmpty) {
            return true;
          }
          return showDialog(
            context: context,
            builder: _buildAlertDialog,
          );
        });
      },
      child: TextFormField(
        autofocus: true,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        decoration: new InputDecoration(
          hintText: 'Write here',
          border: InputBorder.none,
        ),
        controller: _textController,
      ),
    );

    var title = newNote ? "New Journal Entry" : "Edit Journal Entry";
    var newJournalScreen = new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              NoteHeader(note),
              bodyWidget,
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.check),
          onPressed: () {
            final stateContainer = StateContainer.of(context);
            this.note.body = _textController.text;

            newNote
                ? stateContainer.addNote(note)
                : stateContainer.updateNote(note);
            Navigator.pop(context);
          }),
    );

    return newJournalScreen;
  }

  Widget _buildAlertDialog(BuildContext context) {
    return new AlertDialog(
      // FIXME: Change this to 'Save' vs 'Discard'
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
  }
}
