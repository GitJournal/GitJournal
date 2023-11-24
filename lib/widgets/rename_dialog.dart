/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/repository.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';
import 'package:provider/provider.dart';

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

  bool _noExtension = false;
  bool _changeExtension = false;

  var _oldExt = "";
  var _newExt = "";

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: basename(widget.oldPath));

    _oldExt = p.extension(widget.oldPath);
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_noExtension) _DialogWarningText(context.loc.widgetsRenameNoExt),
          if (_changeExtension && !_noExtension)
            _DialogWarningText(
              context.loc.widgetsRenameChangeExt(_oldExt, _newExt),
            ),
          TextFormField(
            decoration: InputDecoration(labelText: widget.inputDecoration),
            validator: (value) {
              if (value!.isEmpty) {
                return context.loc.widgetsRenameValidatorEmpty;
              }

              if (value.contains(p.separator)) {
                return context.loc.widgetsRenameValidatorContains;
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _newExt = p.extension(value).toLowerCase();
                  if (_newExt == '.') _newExt = "";
                  _noExtension = _newExt.isEmpty && _oldExt.isNotEmpty;
                  _changeExtension = _oldExt != _newExt;
                });
              });

              var newPath = join(dirname(widget.oldPath), value);
              try {
                var repo = context.read<GitJournalRepo>();
                var exists = repo.fileExists(newPath);
                if (exists) {
                  return context.loc.widgetsRenameValidatorExists;
                }

                return null;
              } catch (ex) {
                return ex.toString();
              }
            },
            autofocus: true,
            keyboardType: TextInputType.text,
            controller: _textController,
          ),
        ],
      ),
    );

    return AlertDialog(
      title: Text(widget.dialogTitle),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.loc.widgetsRenameNo),
        ),
        TextButton(
          key: const ValueKey('RenameYes'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              var newName = _textController.text;
              Navigator.of(context).pop(newName);
            }
          },
          child: Text(context.loc.widgetsRenameYes),
        ),
      ],
      content: form,
    );
  }
}

class _DialogWarningText extends StatelessWidget {
  final String text;

  const _DialogWarningText(this.text);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Text(text, style: textTheme.titleSmall);
  }
}
