import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'note.dart';

typedef void NoteSelectedFunction(Note note);

class JournalList extends StatelessWidget {
  final NoteSelectedFunction noteSelectedFunction;
  final List<Note> notes;

  final _biggerFont = const TextStyle(fontSize: 18.0);

  JournalList({this.noteSelectedFunction, this.notes});

  @override
  Widget build(BuildContext context) {
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
      onTap: () => noteSelectedFunction(journal),
    );
  }
}
