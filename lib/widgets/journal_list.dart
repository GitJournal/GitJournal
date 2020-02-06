import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/utils/markdown.dart';
import 'package:gitjournal/widgets/icon_dismissable.dart';

typedef void NoteSelectedFunction(int noteIndex);

class JournalList extends StatefulWidget {
  final NoteSelectedFunction noteSelectedFunction;
  final List<Note> notes;
  final NotesFolder folder;
  final String emptyText;

  JournalList({
    @required this.notes,
    @required this.folder,
    @required this.noteSelectedFunction,
    @required this.emptyText,
  });

  @override
  _JournalListState createState() => _JournalListState();
}

class _JournalListState extends State<JournalList> {
  var _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();

    if (widget.folder != null) {
      widget.folder.addNoteAddedListener(_noteAdded);
      widget.folder.addNoteRemovedListener(_noteRemoved);
    }
  }

  @override
  void dispose() {
    if (widget.folder != null) {
      widget.folder.removeNoteAddedListener(_noteAdded);
      widget.folder.removeNoteRemovedListener(_noteRemoved);
    }

    super.dispose();
  }

  void _noteAdded(int index, Note _) {
    if (_listKey.currentState == null) {
      return;
    }
    _listKey.currentState.insertItem(index);
  }

  void _noteRemoved(int index, Note _) {
    if (_listKey.currentState == null) {
      return;
    }
    _listKey.currentState.removeItem(
      index,
      (context, animation) => _buildItem(context, 0, animation),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notes.isEmpty) {
      return Center(
        child: Text(
          widget.emptyText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.w300,
            color: Colors.grey[350],
          ),
        ),
      );
    }

    return AnimatedList(
      key: _listKey,
      itemBuilder: _buildItem,
      initialItemCount: widget.notes.length,
    );
  }

  Widget _buildItem(BuildContext context, int i, Animation<double> animation) {
    var note = widget.notes[i];
    return _buildNote(context, note, i, animation);
  }

  Widget _buildNote(
      BuildContext context, Note note, int i, Animation<double> animation) {
    var viewItem = IconDismissable(
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

        var snackBar = buildUndoDeleteSnackbar(context, note);
        Scaffold.of(context).showSnackBar(snackBar);
      },
    );

    return SizeTransition(
      key: ValueKey("JournalList_tr_" + note.filePath),
      axis: Axis.vertical,
      sizeFactor: animation,
      child: viewItem,
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
      onTap: () => widget.noteSelectedFunction(noteIndex),
    );

    var dc = Theme.of(context).dividerColor;
    var divider = Container(
      height: 1.0,
      child: Divider(color: dc.withOpacity(dc.opacity / 3)),
    );

    return Column(
      children: <Widget>[
        divider,
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
          child: tile,
        ),
        divider,
      ],
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
