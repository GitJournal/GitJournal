import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:journal/note.dart';
import 'package:journal/state_container.dart';

typedef void NoteSelectedFunction(int noteIndex);

class JournalList extends StatelessWidget {
  final NoteSelectedFunction noteSelectedFunction;
  final List<Note> notes;

  final _biggerFont = const TextStyle(fontSize: 18.0);

  JournalList({
    @required this.notes,
    @required this.noteSelectedFunction,
  });

  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);

    return new ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (context, i) {
        if (i >= notes.length) {
          return null;
        }
        //if (i.isOdd) return new Divider();

        var note = notes[i];
        return new Dismissible(
          key: new Key(note.id),
          child: _buildRow(context, note, i),
          background: new Container(color: Colors.red),
          onDismissed: (direction) {
            container.removeNote(note);

            Scaffold
                .of(context)
                .showSnackBar(new SnackBar(content: new Text("Note deleted")));
          },
        );
      },
    );
  }

  Widget _buildRow(BuildContext context, Note journal, int noteIndex) {
    var formatter = new DateFormat('dd MMM, yyyy');
    var title = formatter.format(journal.createdAt);

    var timeFormatter = new DateFormat('Hm');
    var time = timeFormatter.format(journal.createdAt);

    var body = journal.body;
    body = body.replaceAll("\n", " ");

    return new ListTile(
      isThreeLine: true,
      title: new Text(
        title,
        style: _biggerFont,
      ),
      subtitle: new Text(
        time + "\n" + body,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => noteSelectedFunction(noteIndex),
    );
  }
}
