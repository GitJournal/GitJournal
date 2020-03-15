import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gitjournal/core/sorting_mode.dart';
import 'package:gitjournal/folder_views/list_view.dart';
import 'package:gitjournal/settings.dart';

import 'package:intl/intl.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';

enum StandardViewHeader {
  TitleOrFileName,
  FileName,
  TitleGenerated,
}

class StandardView extends StatelessWidget {
  final NoteSelectedFunction noteSelectedFunction;
  final NotesFolder folder;
  final String emptyText;

  final StandardViewHeader headerType;
  final bool showSummary;

  StandardView({
    @required this.folder,
    @required this.noteSelectedFunction,
    @required this.emptyText,
    @required this.headerType,
    @required this.showSummary,
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

    String title;
    switch (headerType) {
      case StandardViewHeader.TitleOrFileName:
        title = note.title;
        if (title == null || title.isEmpty) {
          title = note.fileName;
        }
        break;

      case StandardViewHeader.FileName:
        title = note.fileName;
        break;

      case StandardViewHeader.TitleGenerated:
        title = note.summary;
        break;

      default:
        assert(false, "StandardViewHeader must not be null");
    }

    Widget titleWidget = Text(
      title,
      style: textTheme.title,
      overflow: TextOverflow.ellipsis,
    );
    Widget trailing = Container();

    DateTime date;
    if (Settings.instance.sortingMode == SortingMode.Modified) {
      date = note.modified;
    } else if (Settings.instance.sortingMode == SortingMode.Created) {
      date = note.created;
    }
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

    ListTile tile;
    if (showSummary) {
      var summary = <Widget>[
        const SizedBox(height: 8.0),
        Text(
          note.summary,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: textTheme.body1,
        ),
      ];

      tile = ListTile(
        isThreeLine: true,
        title: titleRow,
        subtitle: Column(
          children: summary,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        onTap: () => noteSelectedFunction(note),
      );
    } else {
      tile = ListTile(
        isThreeLine: false,
        title: titleRow,
        onTap: () => noteSelectedFunction(note),
      );
    }

    var dc = Theme.of(context).dividerColor;
    var divider = Container(
      height: 1.0,
      child: Divider(color: dc.withOpacity(dc.opacity / 3)),
    );

    if (!showSummary) {
      return Column(
        children: <Widget>[
          divider,
          tile,
          divider,
        ],
      );
    }

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
