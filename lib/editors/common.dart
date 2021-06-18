import 'dart:io';

import 'package:flutter/material.dart';

import 'package:function_types/function_types.dart';

import 'package:gitjournal/core/note.dart';

export 'package:gitjournal/editors/scaffold.dart';

typedef NoteCallback = void Function(Note);

abstract class Editor {
  NoteCallback get noteDeletionSelected;
  NoteCallback get noteEditorChooserSelected;
  NoteCallback get exitEditorSelected;
  NoteCallback get renameNoteSelected;
  NoteCallback get editTagsSelected;
  NoteCallback get moveNoteToFolderSelected;
  NoteCallback get discardChangesSelected;
}

abstract class EditorState with ChangeNotifier {
  Note getNote();
  Future<void> addImage(File file);

  bool get noteModified;
}

class TextEditorState {
  late String text;
  late int cursorPos;

  TextEditorState(this.text, this.cursorPos);

  TextEditorState.fromValue(TextEditingValue val) {
    text = val.text;
    cursorPos = val.selection.baseOffset;

    if (cursorPos == -1) {
      cursorPos = 0;
    }
  }

  TextEditingValue toValue() {
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursorPos),
    );
  }
}

class EditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Editor editor;
  final EditorState editorState;
  final bool noteModified;
  final IconButton? extraButton;
  final bool allowEdits;
  final Func0<void> onEditingModeChange;

  EditorAppBar({
    Key? key,
    required this.editor,
    required this.editorState,
    required this.noteModified,
    required this.allowEdits,
    required this.onEditingModeChange,
    this.extraButton,
  })  : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        key: const ValueKey("NewEntry"),
        icon: Icon(noteModified ? Icons.check : Icons.close),
        onPressed: () {
          editor.exitEditorSelected(editorState.getNote());
        },
      ),
      actions: <Widget>[
        if (extraButton != null) extraButton!,
        IconButton(
          icon: allowEdits
              ? const Icon(Icons.remove_red_eye)
              : const Icon(Icons.edit),
          onPressed: onEditingModeChange,
        ),
        IconButton(
          key: const ValueKey("EditorSelector"),
          icon: const Icon(Icons.library_books),
          onPressed: () {
            var note = editorState.getNote();
            editor.noteEditorChooserSelected(note);
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            var note = editorState.getNote();
            editor.noteDeletionSelected(note);
          },
        ),
      ],
    );
  }
}
