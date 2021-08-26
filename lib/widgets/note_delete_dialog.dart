import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';

class NoteDeleteDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(tr(LocaleKeys.widgets_NoteDeleteDialog_title)),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(tr(LocaleKeys.widgets_NoteDeleteDialog_no)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(tr(LocaleKeys.widgets_NoteDeleteDialog_yes)),
        ),
      ],
    );
  }
}
