/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:gitjournal/core/note.dart';

class JournalEditorHeader extends StatelessWidget {
  final Note note;

  const JournalEditorHeader(this.note);

  @override
  Widget build(BuildContext context) {
    var created = note.created;
    if (created == null) {
      return Container();
    }
    var dateStr = DateFormat('MMMM, yyyy').format(created);
    var timeStr = DateFormat('EEEE HH:mm').format(created);

    var bigNum = Text(
      created.day.toString(),
      style: const TextStyle(fontSize: 40.0),
    );

    var dateText = Text(
      dateStr,
      style: const TextStyle(fontSize: 18.0),
    );

    var timeText = Text(
      timeStr,
      style: const TextStyle(fontSize: 18.0),
    );

    var w = Row(
      children: <Widget>[
        bigNum,
        const SizedBox(width: 8.0),
        Column(
          children: <Widget>[
            dateText,
            timeText,
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 18.0),
      child: w,
    );
  }
}
