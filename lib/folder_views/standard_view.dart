import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gitjournal/folder_views/list_view.dart';

import 'package:intl/intl.dart';

import 'package:gitjournal/core/sorting_mode.dart';
import 'package:gitjournal/settings.dart';
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
    var title = note.canHaveMetadata ? note.title : note.fileName;
    Widget titleWidget = Text(title, style: textTheme.title);
    if (title.isEmpty) {
      DateTime date;
      if (Settings.instance.sortingMode == SortingMode.Modified) {
        date = note.modified;
      } else if (Settings.instance.sortingMode == SortingMode.Created) {
        date = note.created;
      }
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

    var children = <Widget>[
      const SizedBox(height: 8.0),
      Text(
        note.summary,
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
