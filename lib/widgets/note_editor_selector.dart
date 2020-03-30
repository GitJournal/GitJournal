import 'package:flutter/material.dart';
import 'package:gitjournal/screens/note_editor.dart';

class NoteEditorSelector extends StatelessWidget {
  final EditorType currentEditor;

  NoteEditorSelector(this.currentEditor);

  @override
  Widget build(BuildContext context) {
    var onEditorChange = (EditorType et) => Navigator.of(context).pop(et);

    var children = <Widget>[
      // FIXME: Change this to ListTiles with nice icons
      RadioListTile<EditorType>(
        title: const Text("Markdown Editor"),
        value: EditorType.Markdown,
        groupValue: currentEditor,
        onChanged: onEditorChange,
      ),
      RadioListTile<EditorType>(
        title: const Text("Raw Editor"),
        value: EditorType.Raw,
        groupValue: currentEditor,
        onChanged: onEditorChange,
      ),
      RadioListTile<EditorType>(
        title: const Text("Checklist Editor"),
        value: EditorType.Checklist,
        groupValue: currentEditor,
        onChanged: onEditorChange,
      ),
      RadioListTile<EditorType>(
        title: const Text("Journal Editor"),
        value: EditorType.Journal,
        groupValue: currentEditor,
        onChanged: onEditorChange,
      ),
    ];

    return AlertDialog(
      title: const Text("Choose Editor"),
      content: Column(
        children: children,
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }
}
