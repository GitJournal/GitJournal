/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/l10n.dart';

class NoteDeleteDialog extends StatelessWidget {
  final int num;

  const NoteDeleteDialog({super.key, required this.num});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.loc.widgetsNoteDeleteDialogTitle(num)),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.loc.widgetsNoteDeleteDialogNo),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.loc.widgetsNoteDeleteDialogYes),
        ),
      ],
    );
  }
}

class NotesFolderDeleteDialog extends StatelessWidget {
  const NotesFolderDeleteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.loc.widgetsNotesFolderDeleteDialogTitle),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.loc.widgetsNoteDeleteDialogNo),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.loc.widgetsNoteDeleteDialogYes),
        ),
      ],
    );
  }
}
