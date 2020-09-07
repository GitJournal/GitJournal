import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

class NoteDeleteDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(tr('widgets.NoteDeleteDialog.title')),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(tr('widgets.NoteDeleteDialog.no')),
        ),
        FlatButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(tr('widgets.NoteDeleteDialog.yes')),
        ),
      ],
    );
  }
}
