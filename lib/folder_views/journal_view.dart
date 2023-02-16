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
import 'package:gitjournal/core/notes/note.dart';
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
        return JournalNoteListTile(
          searchTerm: searchTerm,
          searchTermLowerCase: searchTermLowerCase,
          noteTapped: noteTapped,
          noteLongPressed: noteLongPressed,
          note: note,
          isSelected: isSelected,
          noteSummary: summary,
        );
      }(),
      builder: (context, AsyncSnapshot<JournalNoteListTile> snapshot) {
        if (snapshot.hasData) {
          return snapshot.data as JournalNoteListTile;
        }
        return JournalNoteListTile(
          searchTerm: searchTerm,
          searchTermLowerCase: searchTermLowerCase,
          noteTapped: noteTapped,
          noteLongPressed: noteLongPressed,
          note: note,
          isSelected: isSelected,
          noteSummary: "",
        );
      },
    );
  }
}

class JournalNoteListTile extends StatelessWidget {
  static final _dateFormat = DateFormat('dd MMM, yyyy  ');
  static final _timeFormat = DateFormat('Hm');

  const JournalNoteListTile({
    super.key,
    required this.searchTerm,
    required this.searchTermLowerCase,
    required this.noteTapped,
    required this.noteLongPressed,
    required this.note,
    required this.isSelected,
    required this.noteSummary,
  });

  final String searchTerm;
  final String searchTermLowerCase;
  final NoteSelectedFunction noteTapped;
  final NoteSelectedFunction noteLongPressed;
  final Note note;
  final bool isSelected;
  final String noteSummary;

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    DateTime? date;
    var sortingField = note.parent.config.sortingMode.field;
    if (sortingField == SortingField.Created) {
      date = note.created;
    } else {
      date = note.modified;
    }

    var dateStr = _dateFormat.format(date);
    var time = _timeFormat.format(date);

    var timeColor = textTheme.bodyMedium!.color!.withAlpha(100);

    var titleWidget = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Text(dateStr, style: textTheme.titleLarge),
        Text(time, style: textTheme.bodyMedium!.copyWith(color: timeColor)),
      ],
    );

    var children = <Widget>[
      const SizedBox(height: 8.0),
      HighlightedText(
        text: '$noteSummary\n', // no minLines option
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodyMedium!,
        highlightText: searchTerm,
        highlightTextLowerCase: searchTermLowerCase,
      ),
    ];

    var tile = ListTile(
      isThreeLine: true,
      title: titleWidget,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
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
