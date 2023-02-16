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
import 'package:gitjournal/folder_views/journal_view.dart';
import 'package:gitjournal/folder_views/list_view.dart';
import 'package:gitjournal/widgets/highlighted_text.dart';

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
  final String? emptyText;

  final StandardViewHeader headerType;
  final bool showSummary;

  final String searchTerm;
  final String searchTermLowerCase;

  StandardView({
    required this.folder,
    required this.noteTapped,
    required this.noteLongPressed,
    required this.emptyText,
    required this.headerType,
    required this.showSummary,
    required this.isNoteSelected,
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
        if (note.type == NoteType.Journal) {
          return JournalNoteListTile(
            searchTerm: searchTerm,
            searchTermLowerCase: searchTermLowerCase,
            noteTapped: noteTapped,
            noteLongPressed: noteLongPressed,
            note: note,
            isSelected: isSelected,
            noteSummary: summary,
          );
        }
        return StandardNoteListTile(
          headerType: headerType,
          searchTerm: searchTerm,
          searchTermLowerCase: searchTermLowerCase,
          showSummary: showSummary,
          noteTapped: noteTapped,
          noteLongPressed: noteLongPressed,
          note: note,
          isSelected: isSelected,
          noteSummary: summary,
        );
      }(),
      builder: (context, AsyncSnapshot<Widget> snapshot) {
        if (snapshot.hasData) {
          return snapshot.data as Widget;
        }
        if (note.type == NoteType.Journal) {
          return JournalNoteListTile(
            searchTerm: searchTerm,
            searchTermLowerCase: searchTermLowerCase,
            noteTapped: noteTapped,
            noteLongPressed: noteLongPressed,
            note: note,
            isSelected: isSelected,
            noteSummary: "",
          );
        }
        return StandardNoteListTile(
          headerType: headerType,
          searchTerm: searchTerm,
          searchTermLowerCase: searchTermLowerCase,
          showSummary: showSummary,
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

class StandardNoteListTile extends StatelessWidget {
  const StandardNoteListTile({
    super.key,
    required this.headerType,
    required this.searchTerm,
    required this.searchTermLowerCase,
    required this.showSummary,
    required this.noteTapped,
    required this.noteLongPressed,
    required this.note,
    required this.isSelected,
    required this.noteSummary,
  });

  static final _dateFormat = DateFormat('dd MMM, yyyy');

  final StandardViewHeader headerType;
  final String searchTerm;
  final String searchTermLowerCase;
  final bool showSummary;
  final NoteSelectedFunction noteTapped;
  final NoteSelectedFunction noteLongPressed;
  final Note note;
  final bool isSelected;
  final String noteSummary;

  @override
  Widget build(BuildContext context) {
    String title;
    switch (headerType) {
      case StandardViewHeader.TitleOrFileName:
        title = note.title ?? note.fileName;
        break;

      case StandardViewHeader.FileName:
        title = note.fileName;
        break;

      case StandardViewHeader.TitleGenerated:
        title = note.title ?? noteSummary;
        break;
    }

    var textTheme = Theme.of(context).textTheme;
    Widget titleWidget = HighlightedText(
      text: title,
      style: textTheme.titleLarge!,
      overflow: TextOverflow.ellipsis,
      highlightText: searchTerm,
      highlightTextLowerCase: searchTermLowerCase,
    );
    Widget trailing = Container();

    DateTime? date;
    var sortingField = note.parent.config.sortingMode.field;
    if (sortingField == SortingField.Modified) {
      date = note.modified;
    } else if (sortingField == SortingField.Created) {
      date = note.created;
    }

    if (date != null) {
      var dateStr = _dateFormat.format(date);
      trailing = Text(dateStr, style: textTheme.bodySmall);
    }

    var titleRow = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[Expanded(child: titleWidget), trailing],
    );

    ListTile tile;
    if (showSummary) {
      var summary = <Widget>[
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

      tile = ListTile(
        isThreeLine: true,
        title: titleRow,
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: summary,
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
    var divider = SizedBox(
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
