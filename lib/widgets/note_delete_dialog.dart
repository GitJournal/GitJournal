/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/app_localizations_context.dart';

class NoteDeleteDialog extends StatelessWidget {
  final int num;

  const NoteDeleteDialog({super.key, required this.num});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LocaleKeys.widgets_NoteDeleteDialog_title.plural(num)),
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
