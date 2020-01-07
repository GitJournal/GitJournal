import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/utils/markdown.dart';
import 'package:gitjournal/widgets/icon_dismissable.dart';

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
        return const Divider();
      },
      itemBuilder: (context, i) {
        if (i >= notes.length) {
          return null;
        }

        var note = notes[i];
        return IconDismissable(
          key: ValueKey("JournalList_" + note.filePath),
          child: Hero(
            tag: note.filePath,
            child: _buildRow(context, note, i),
            flightShuttleBuilder: (BuildContext flightContext,
                    Animation<double> animation,
                    HeroFlightDirection flightDirection,
                    BuildContext fromHeroContext,
                    BuildContext toHeroContext) =>
                Material(child: toHeroContext.widget),
          ),
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

  Widget _buildRow(BuildContext context, Note note, int noteIndex) {
    var textTheme = Theme.of(context).textTheme;
    var title = note.title;
    Widget titleWidget = Text(title, style: textTheme.title);
    if (title.isEmpty) {
      var date = note.modified ?? note.created;
      if (date != null) {
        var formatter = DateFormat('dd MMM, yyyy  ');
        var dateStr = formatter.format(date);

        var timeFormatter = DateFormat('Hm');
        var time = timeFormatter.format(date);

        var timeColor = textTheme.body1.color.withAlpha(100);

        titleWidget = Row(
          children: <Widget>[
            Text(dateStr, style: textTheme.title),
            Text(time, style: textTheme.body1.copyWith(color: timeColor)),
          ],
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
        );
      } else {
        titleWidget = Text(note.fileName, style: textTheme.title);
      }
    }

    var body = stripMarkdownFormatting(note.body);

    var children = <Widget>[
      const SizedBox(height: 8.0),
      Text(
        body,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: textTheme.body1,
      ),
    ];

    var tile = ListTile(
      isThreeLine: true,
      title: titleWidget,
      subtitle: Column(
        children: children,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      onTap: () => noteSelectedFunction(noteIndex),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: tile,
    );
  }

  /*
  Widget _buildJournalRow(BuildContext context, Note journal, int noteIndex) {
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
        const SizedBox(height: 4.0),
        Text(time, style: textTheme.body1),
      ]);
    }

    children.addAll(<Widget>[
      const SizedBox(height: 4.0),
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
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: tile,
    );
  }
  */
}
