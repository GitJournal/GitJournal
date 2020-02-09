import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/utils/markdown.dart';
import 'package:gitjournal/widgets/icon_dismissable.dart';

typedef void NoteSelectedFunction(Note note);

class JournalList extends StatefulWidget {
  final NoteSelectedFunction noteSelectedFunction;
  final NotesFolderReadOnly folder;
  final String emptyText;

  JournalList({
    @required this.folder,
    @required this.noteSelectedFunction,
    @required this.emptyText,
  });

  @override
  _JournalListState createState() => _JournalListState();
}

class _JournalListState extends State<JournalList> {
  var _listKey = GlobalKey<AnimatedListState>();
  var deletedViaDismissed = <String>[];

  @override
  void initState() {
    super.initState();

    widget.folder.addNoteAddedListener(_noteAdded);
    widget.folder.addNoteRemovedListener(_noteRemoved);
    widget.folder.addListener(_folderChanged);
  }

  @override
  void dispose() {
    widget.folder.removeNoteAddedListener(_noteAdded);
    widget.folder.removeNoteRemovedListener(_noteRemoved);
    widget.folder.removeListener(_folderChanged);

    super.dispose();
  }

  void _noteAdded(int index, Note _) {
    if (_listKey.currentState == null) {
      return;
    }
    _listKey.currentState.insertItem(index);
  }

  void _noteRemoved(int index, Note note) {
    if (_listKey.currentState == null) {
      return;
    }
    _listKey.currentState.removeItem(index, (context, animation) {
      var i = deletedViaDismissed.indexWhere((path) => path == note.filePath);
      if (i == -1) {
        return _buildNote(context, note, animation);
      } else {
        deletedViaDismissed.removeAt(i);
        return Container();
      }
    });
  }

  void _folderChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.folder.notes.isEmpty) {
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
      initialItemCount: widget.folder.notes.length,
    );
  }

  Widget _buildItem(BuildContext context, int i, Animation<double> animation) {
    // vHanda FIXME: Why does this method get called with i >= length ?
    if (i >= widget.folder.notes.length) {
      return Container();
    }

    var note = widget.folder.notes[i];
    return _buildNote(context, note, animation);
  }

  Widget _buildNote(
      BuildContext context, Note note, Animation<double> animation) {
    var viewItem = IconDismissable(
      key: ValueKey("JournalList_" + note.filePath),
      child: Hero(
        tag: note.filePath,
        child: _buildRow(context, note),
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
        deletedViaDismissed.add(note.filePath);

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

  Widget _buildRow(BuildContext context, Note note) {
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
      onTap: () => widget.noteSelectedFunction(note),
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
}
