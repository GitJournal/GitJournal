import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/sorting_mode.dart';
import 'package:gitjournal/folder_views/list_view.dart';

class JournalView extends StatelessWidget {
  final NoteSelectedFunction noteTapped;
  final NoteSelectedFunction noteLongPressed;
  final NotesFolder folder;
  final String emptyText;

  static final _dateFormat = DateFormat('dd MMM, yyyy  ');
  static final _timeFormat = DateFormat('Hm');

  JournalView({
    @required this.folder,
    @required this.noteTapped,
    @required this.noteLongPressed,
    @required this.emptyText,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return FolderListView(
      folder: folder,
      emptyText: emptyText,
      noteTileBuilder: _buildRow,
    );
  }

  Widget _buildRow(BuildContext context, Note note) {
    Widget titleWidget = Container();
    var textTheme = Theme.of(context).textTheme;

    DateTime date;
    var sortingMode = folder.config.sortingMode;
    if (sortingMode == SortingMode.Created) {
      date = note.created;
    } else {
      date = note.modified;
    }

    if (date != null) {
      var dateStr = _dateFormat.format(date);
      var time = _timeFormat.format(date);

      var timeColor = textTheme.bodyText2.color.withAlpha(100);

      titleWidget = Row(
        children: <Widget>[
          Text(dateStr, style: textTheme.headline6),
          Text(time, style: textTheme.bodyText2.copyWith(color: timeColor)),
        ],
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
      );
    }

    var children = <Widget>[
      const SizedBox(height: 8.0),
      Text(
        note.summary + '\n', // no minLines option
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodyText2,
      ),
    ];

    var tile = ListTile(
      isThreeLine: true,
      title: titleWidget,
      subtitle: Column(
        children: children,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      onTap: () => noteTapped(note),
      onLongPress: () => noteLongPressed(note),
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
