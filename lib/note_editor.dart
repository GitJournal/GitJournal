import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:journal/note.dart';

class NoteEditor extends StatelessWidget {
  static final GlobalKey<FormFieldState<String>> noteTextKey =
      GlobalKey<FormFieldState<String>>();
  final NoteAdder noteAdder;
  final DateTime _createdAt;

  NoteEditor({
    @required this.noteAdder,
  }) : _createdAt = new DateTime.now();

  @override
  Widget build(BuildContext context) {
    var bodyWidget = new Container(
      child: new TextFormField(
        key: noteTextKey,
        autofocus: true,
        keyboardType: TextInputType.multiline,
        maxLines: 5000,
        decoration: new InputDecoration(
          hintText: 'Write here',
        ),
      ),
      padding: const EdgeInsets.all(8.0),
    );

    var formatter = new DateFormat('dd MMM, yyyy');
    var title = formatter.format(_createdAt);

    var newJournalScreen = new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      body: bodyWidget,
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            var body = noteTextKey.currentState.value;
            var note = new Note(
              id: "1",
              createdAt: _createdAt,
              body: body,
            );
            noteAdder(note);

            Navigator.pop(context);
          }),
    );

    return newJournalScreen;
  }
}
