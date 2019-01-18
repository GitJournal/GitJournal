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
    return new ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (context, i) {
        if (i >= notes.length) {
          return null;
        }

        var note = notes[i];
        return new Dismissible(
          key: new Key(note.fileName),
          child: _buildRow(context, note, i),
          background: new Container(color: Theme.of(context).accentColor),
          onDismissed: (direction) {
            final stateContainer = StateContainer.of(context);
            stateContainer.removeNote(note);

            Scaffold.of(context).showSnackBar(new SnackBar(
              content: new Text("Note deleted"),
              action: new SnackBarAction(
                label: 'Undo',
                onPressed: () => stateContainer.insertNote(i, note),
              ),
            ));
          },
        );
      },
    );
  }

  Widget _buildRow(BuildContext context, Note journal, int noteIndex) {
    var formatter = new DateFormat('dd MMM, yyyy');
    var title = formatter.format(journal.created);

    var timeFormatter = new DateFormat('Hm');
    var time = timeFormatter.format(journal.created);

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
