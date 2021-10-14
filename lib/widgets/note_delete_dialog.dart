/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';

class NoteDeleteDialog extends StatelessWidget {
  final int num;

  const NoteDeleteDialog({Key? key, required this.num}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LocaleKeys.widgets_NoteDeleteDialog_title.plural(num)),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(LocaleKeys.widgets_NoteDeleteDialog_no.tr()),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(LocaleKeys.widgets_NoteDeleteDialog_yes.tr()),
        ),
      ],
    );
  }
}
