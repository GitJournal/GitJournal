import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gitjournal/folder_views/list_view.dart';

import 'package:intl/intl.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';

class StandardView extends StatelessWidget {
  final NoteSelectedFunction noteSelectedFunction;
  final NotesFolderReadOnly folder;
  final String emptyText;

  StandardView({
    @required this.folder,
    @required this.noteSelectedFunction,
    @required this.emptyText,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return FolderListView(
      folder: folder,
      noteSelectedFunction: noteSelectedFunction,
      emptyText: emptyText,
      noteTileBuilder: _buildRow,
    );
  }

  Widget _buildRow(BuildContext context, Note note) {
    var textTheme = Theme.of(context).textTheme;

    var title = note.title;
    if (title == null || title.isEmpty) {
      title = note.fileName;
    }
    var titleTheme =
        textTheme.title.copyWith(fontSize: textTheme.title.fontSize * 0.95);
    Widget titleWidget = Text(title, style: titleTheme);
    Widget trailing = Container();

    var date = note.modified ?? note.created;
    if (date != null) {
      var formatter = DateFormat('dd MMM, yyyy');
      var dateStr = formatter.format(date);
      trailing = Text(dateStr, style: textTheme.caption);
    }

    var children = <Widget>[
      const SizedBox(height: 8.0),
      Text(
        note.summary,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: textTheme.body1,
      ),
    ];

    var titleRow = Row(
      children: <Widget>[Expanded(child: titleWidget), trailing],
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
    );

    var tile = ListTile(
      isThreeLine: true,
      title: titleRow,
      subtitle: Column(
        children: children,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      onTap: () => noteSelectedFunction(note),
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
