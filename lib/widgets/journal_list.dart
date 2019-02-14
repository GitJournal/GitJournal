import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    return ListView.builder(
      itemBuilder: (context, i) {
        if (i >= notes.length) {
          return null;
        }

        var note = notes[i];
        return Dismissible(
          key: Key(note.filePath),
          child: _buildRow(context, note, i),
          background: Container(color: Theme.of(context).accentColor),
          onDismissed: (direction) {
            final stateContainer = StateContainer.of(context);
            stateContainer.removeNote(note);

            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text("Note deleted"),
              action: SnackBarAction(
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
    var formatter = DateFormat('dd MMM, yyyy');
    var title = formatter.format(journal.created);

    var timeFormatter = DateFormat('Hm');
    var time = timeFormatter.format(journal.created);

    var body = journal.body;
    body = body.replaceAll("\n", " ");

    return ListTile(
      isThreeLine: true,
      title: Text(
        title,
        style: _biggerFont,
      ),
      subtitle: Text(
        time + "\n" + body,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => noteSelectedFunction(noteIndex),
    );
  }
}
