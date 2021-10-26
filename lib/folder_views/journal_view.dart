/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/folder/sorting_mode.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/views/summary_view.dart';
import 'package:gitjournal/folder_views/list_view.dart';
import 'package:gitjournal/widgets/highlighted_text.dart';

class JournalView extends StatelessWidget {
  final NoteSelectedFunction noteTapped;
  final NoteSelectedFunction noteLongPressed;
  final NoteBoolPropertyFunction isNoteSelected;

  final NotesFolder folder;
  final String? emptyText;
  final String searchTerm;
  final String searchTermLowerCase;

  static final _dateFormat = DateFormat('dd MMM, yyyy  ');
  static final _timeFormat = DateFormat('Hm');

  JournalView({
    required this.folder,
    required this.noteTapped,
    required this.noteLongPressed,
    required this.isNoteSelected,
    required this.emptyText,
    required this.searchTerm,
  }) : searchTermLowerCase = searchTerm.toLowerCase();

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

  Widget _buildRow(BuildContext context, Note note, bool isSelected) {
    var summaryProvider = NoteSummaryProvider.of(context);

    return FutureBuilder(
      future: () async {
        var summary = await summaryProvider.fetch(note);
        return _buildRowWithSummary(context, note, isSelected, summary);
      }(),
      builder: (context, AsyncSnapshot<Widget> snapshot) {
        if (snapshot.hasData) {
          return snapshot.data as Widget;
        }
        return _buildRowWithSummary(context, note, isSelected, "");
      },
    );
  }

  Widget _buildRowWithSummary(
    BuildContext context,
    Note note,
    bool isSelected,
    String noteSummary,
  ) {
    var textTheme = Theme.of(context).textTheme;

    DateTime? date;
    var sortingField = folder.config.sortingMode.field;
    if (sortingField == SortingField.Created) {
      date = note.created;
    } else {
      date = note.modified;
    }

    var dateStr = _dateFormat.format(date);
    var time = _timeFormat.format(date);

    var timeColor = textTheme.bodyText2!.color!.withAlpha(100);

    var titleWidget = Row(
      children: <Widget>[
        Text(dateStr, style: textTheme.headline6),
        Text(time, style: textTheme.bodyText2!.copyWith(color: timeColor)),
      ],
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
    );

    var children = <Widget>[
      const SizedBox(height: 8.0),
      HighlightedText(
        text: noteSummary + '\n', // no minLines option
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodyText2!,
        highlightText: searchTerm,
        highlightTextLowerCase: searchTermLowerCase,
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
    var divider = SizedBox(
      height: 1.0,
      child: Divider(color: dc.withOpacity(dc.opacity / 3)),
    );

    if (!isSelected) {
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
    } else {
      var borderColor = Theme.of(context).colorScheme.secondary;
      var viewItem = Column(
        children: <Widget>[
          divider,
          Padding(
            padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
            child: tile,
          ),
          divider,
        ],
      );
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2.0),
        ),
        child: viewItem,
      );
    }
  }
}
