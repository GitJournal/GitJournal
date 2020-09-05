import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/sorting_mode.dart';
import 'package:gitjournal/folder_views/list_view.dart';

enum StandardViewHeader {
  TitleOrFileName,
  FileName,
  TitleGenerated,
}

class StandardView extends StatelessWidget {
  final NoteSelectedFunction noteTapped;
  final NoteSelectedFunction noteLongPressed;
  final NoteBoolPropertyFunction isNoteSelected;

  final NotesFolder folder;
  final String emptyText;

  final StandardViewHeader headerType;
  final bool showSummary;

  final String searchTerm;

  static final _dateFormat = DateFormat('dd MMM, yyyy');

  StandardView({
    @required this.folder,
    @required this.noteTapped,
    @required this.noteLongPressed,
    @required this.emptyText,
    @required this.headerType,
    @required this.showSummary,
    @required this.isNoteSelected,
    @required this.searchTerm,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return FolderListView(
      folder: folder,
      emptyText: emptyText,
      noteTileBuilder: _buildRow,
      isNoteSelected: isNoteSelected,
      searchTerm: searchTerm,
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
        title = note.title;
        if (title == null || title.isEmpty) {
          title = note.summary;
        }
        break;

      default:
        assert(false, "StandardViewHeader must not be null");
    }

    Widget titleWidget = Text(
      title,
      style: textTheme.headline6,
      overflow: TextOverflow.ellipsis,
    );
    Widget trailing = Container();

    DateTime date;
    var sortingField = folder.config.sortingMode.field;
    if (sortingField == SortingField.Modified) {
      date = note.modified;
    } else if (sortingField == SortingField.Created) {
      date = note.created;
    }

    if (date != null) {
      var dateStr = _dateFormat.format(date);
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
          note.summary + '\n', // no minLines option
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyText2,
        ),
      ];

      tile = ListTile(
        isThreeLine: true,
        title: titleRow,
        subtitle: Column(
          children: summary,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        onTap: () => noteTapped(note),
        onLongPress: () => noteLongPressed(note),
      );
    } else {
      tile = ListTile(
        isThreeLine: false,
        title: titleRow,
        onTap: () => noteTapped(note),
        onLongPress: () => noteLongPressed(note),
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
