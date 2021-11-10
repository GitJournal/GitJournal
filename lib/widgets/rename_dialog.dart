/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';
import 'package:universal_io/io.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';

class RenameDialog extends StatefulWidget {
  final String oldPath;
  final String inputDecoration;
  final String dialogTitle;

  const RenameDialog({
    required this.oldPath,
    required this.inputDecoration,
    required this.dialogTitle,
  });

  @override
  _RenameDialogState createState() => _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  late TextEditingController _textController;
  final _formKey = GlobalKey<FormState>();

  bool noExtension = false;
  bool changeExtension = false;

  var oldExt = "";
  var newExt = "";

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: basename(widget.oldPath));

    oldExt = p.extension(widget.oldPath);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var form = Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (noExtension)
            _DialogWarningText(LocaleKeys.widgets_rename_noExt.tr()),
          if (changeExtension && !noExtension)
            _DialogWarningText(
              LocaleKeys.widgets_rename_changeExt.tr(args: [oldExt, newExt]),
            ),
          TextFormField(
            decoration: InputDecoration(labelText: widget.inputDecoration),
            validator: (value) {
              if (value!.isEmpty) {
                return tr(LocaleKeys.widgets_rename_validator_empty);
              }

              if (value.contains(p.separator)) {
                return tr(LocaleKeys.widgets_rename_validator_contains);
              }

              WidgetsBinding.instance!.addPostFrameCallback((_) {
                setState(() {
                  newExt = p.extension(value).toLowerCase();
                  noExtension = newExt.isEmpty && oldExt.isNotEmpty;
                  changeExtension = oldExt != newExt;
                });
              });

              var newPath = join(dirname(widget.oldPath), value);
              if (FileSystemEntity.typeSync(newPath) !=
                  FileSystemEntityType.notFound) {
                return tr(LocaleKeys.widgets_rename_validator_exists);
              }

              return null;
            },
            autofocus: true,
            keyboardType: TextInputType.text,
            controller: _textController,
          ),
        ],
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );

    return AlertDialog(
      title: Text(widget.dialogTitle),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr(LocaleKeys.widgets_rename_no)),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              var newName = _textController.text;
              Navigator.of(context).pop(newName);
            }
          },
          child: Text(tr(LocaleKeys.widgets_rename_yes)),
        ),
      ],
      content: form,
    );
  }
}

class _DialogWarningText extends StatelessWidget {
  final String text;

  const _DialogWarningText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Text(text, style: textTheme.subtitle2);
  }
}
