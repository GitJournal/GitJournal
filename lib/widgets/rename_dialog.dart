import 'package:flutter/material.dart';

class RenameDialog extends StatefulWidget {
  final String oldName;
  final String inputDecoration;
  final String dialogTitle;

  RenameDialog({
    @required this.oldName,
    @required this.inputDecoration,
    @required this.dialogTitle,
  });

  @override
  _RenameDialogState createState() => _RenameDialogState();
}

// FIXME: Do not allow paths which already exist!

class _RenameDialogState extends State<RenameDialog> {
  TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.oldName);
  }

  @override
  Widget build(BuildContext context) {
    var form = Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(labelText: widget.inputDecoration),
            validator: (value) {
              if (value.isEmpty) return 'Please enter a name';
              return "";
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
        FlatButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
        FlatButton(
          onPressed: () {
            var newFolderName = _textController.text;
            return Navigator.of(context).pop(newFolderName);
          },
          child: const Text("Rename"),
        ),
      ],
      content: form,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
