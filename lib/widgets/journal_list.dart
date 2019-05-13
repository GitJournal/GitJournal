import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journal/note.dart';
import 'package:journal/state_container.dart';
import 'package:journal/utils.dart';
import 'package:journal/utils/markdown.dart';
import 'package:path/path.dart';

typedef void NoteSelectedFunction(int noteIndex);

class JournalList extends StatelessWidget {
  final NoteSelectedFunction noteSelectedFunction;
  final List<Note> notes;

  JournalList({
    @required this.notes,
    @required this.noteSelectedFunction,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return Center(
        child: Text(
          "Why not add your first\n Journal Entry?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.w300,
            color: Colors.grey[350],
          ),
        ),
      );
    }

    return ListView.separated(
      separatorBuilder: (context, index) {
        return Divider(
          color: Theme.of(context).primaryColorLight,
        );
      },
      itemBuilder: (context, i) {
        if (i >= notes.length) {
          return null;
        }

        var note = notes[i];
        return Dismissible(
          key: ValueKey("JournalList_" + note.filePath),
          child: _buildRow(context, note, i),
          background: Container(color: Theme.of(context).accentColor),
          onDismissed: (direction) {
            final stateContainer = StateContainer.of(context);
            stateContainer.removeNote(note);

            Scaffold.of(context)
                .showSnackBar(buildUndoDeleteSnackbar(context, note, i));
          },
        );
      },
      itemCount: notes.length,
    );
  }

  Widget _buildRow(BuildContext context, Note journal, int noteIndex) {
    var title = "";
    var time = "";

    if (journal.hasValidDate()) {
      var formatter = DateFormat('dd MMM, yyyy - EE');
      title = formatter.format(journal.created);

      var timeFormatter = DateFormat('Hm');
      time = timeFormatter.format(journal.created);
    } else {
      title = basename(journal.filePath);
    }

    var body = markdownToPlainText(journal.body);

    var textTheme = Theme.of(context).textTheme;
    var children = <Widget>[];
    if (time.isNotEmpty) {
      children.addAll(<Widget>[
        SizedBox(height: 4.0),
        Text(time, style: textTheme.body1),
      ]);
    }

    children.addAll(<Widget>[
      SizedBox(height: 4.0),
      Text(
        body,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: textTheme.body1,
      ),
    ]);

    var tile = ListTile(
      isThreeLine: true,
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        children: children,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      onTap: () => noteSelectedFunction(noteIndex),
    );

    return Padding(
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: tile,
    );
  }
}
