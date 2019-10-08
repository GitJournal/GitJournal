import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gitjournal/note.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/utils/markdown.dart';
import 'package:gitjournal/widgets/icon_dismissable.dart';
import 'package:path/path.dart';

typedef void NoteSelectedFunction(int noteIndex);

class JournalList extends StatelessWidget {
  final NoteSelectedFunction noteSelectedFunction;
  final List<Note> notes;
  final String emptyText;

  JournalList({
    @required this.notes,
    @required this.noteSelectedFunction,
    @required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return Center(
        child: Text(
          emptyText,
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
        return IconDismissable(
          key: ValueKey("JournalList_" + note.filePath),
          child: _buildRow(context, note, i),
          backgroundColor: Colors.red[800],
          iconData: Icons.delete,
          onDismissed: (direction) {
            final stateContainer = StateContainer.of(context);
            stateContainer.removeNote(note);

            showUndoDeleteSnackbar(context, stateContainer, note, i);
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

    var body = stripMarkdownFormatting(journal.body);

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
