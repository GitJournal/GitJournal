import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gitjournal/folder_views/list_view.dart';

import 'package:intl/intl.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';

class CompactView extends StatelessWidget {
  final NoteSelectedFunction noteSelectedFunction;
  final NotesFolderReadOnly folder;
  final String emptyText;

  CompactView({
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
      title = note.summary;
    }
    var titleTheme = textTheme.title;
    Widget titleWidget = Text(
      title,
      style: titleTheme,
      overflow: TextOverflow.ellipsis,
    );
    Widget trailing = Container();

    var date = note.modified ?? note.created;
    if (date != null) {
      var formatter = DateFormat('dd MMM, yyyy');
      var dateStr = formatter.format(date);
      trailing = Text(dateStr, style: textTheme.caption);
    }

    var titleRow = Row(
      children: <Widget>[Expanded(child: titleWidget), trailing],
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
    );

    var tile = ListTile(
      title: titleRow,
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
        tile,
        divider,
      ],
    );
  }
}
