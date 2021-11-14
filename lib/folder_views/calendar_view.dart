/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:table_calendar/table_calendar.dart';

import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/note.dart';

class CalendarFolderView extends StatefulWidget {
  final NoteSelectedFunction noteTapped;
  final NoteSelectedFunction noteLongPressed;
  final NoteBoolPropertyFunction isNoteSelected;

  final NotesFolder folder;
  final String? emptyText;

  final String searchTerm;

  const CalendarFolderView({
    required this.folder,
    required this.noteTapped,
    required this.noteLongPressed,
    required this.isNoteSelected,
    required this.emptyText,
    required this.searchTerm,
  });

  @override
  State<CalendarFolderView> createState() => _CalendarFolderViewState();
}

class _CalendarFolderViewState extends State<CalendarFolderView> {
  late DateTime _firstDay;
  late DateTime _lastDay;

  final _events = <DateTime, List<Note>>{};

  @override
  void initState() {
    super.initState();

    var folder = widget.folder.fsFolder! as NotesFolderFS;
    if (folder.isEmpty) {
      _firstDay = DateTime.now();
      _lastDay = DateTime.now();
    } else {
      // FIXME: Should it operate on created / modified
      var note = folder.notes.first;
      _firstDay = note.created;
      _lastDay = note.created;
    }

    folder.visit((f) {
      if (f is! Note) return;
      var c = f.created;
      print(c);
      if (c.isBefore(_firstDay)) _firstDay = c;
      if (c.isAfter(_lastDay)) _lastDay = c;

      var dateOnly = DateTime(c.year, c.month, c.day);
      if (_events.containsKey(dateOnly)) {
        _events[dateOnly]!.add(f);
      } else {
        _events[dateOnly] = [f];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // * Hook up day change to show the correct list
    // * Show a symbol for what days are available.
    // * This is kind of different than the folder_view - or is it?
    // * On modifying the FolderView this should be updated!

    return SliverToBoxAdapter(
      child: TableCalendar<Note>(
        firstDay: _firstDay,
        lastDay: _lastDay,
        focusedDay: _lastDay,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
        },
        startingDayOfWeek: StartingDayOfWeek.monday,
        eventLoader: (day) {
          return _events.containsKey(day) ? _events[day]! : [];
        },
        calendarBuilders:
            CalendarBuilders(markerBuilder: (context, datetime, notes) {
          if (notes.isEmpty) {
            return const SizedBox();
          }
          print('huh $datetime');
          return Text('${notes.length}');
        }),
      ),
    );
  }
}
