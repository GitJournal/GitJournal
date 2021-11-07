/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:function_types/function_types.dart';

import 'package:gitjournal/core/note.dart';
import 'search.dart';

export 'package:gitjournal/editors/scaffold.dart';
export 'search.dart';

typedef NoteCallback = void Function(Note);

abstract class Editor {
  EditorCommon get common;
}

abstract class EditorCommon {
  void discardChanges(Note note);
  void renameNote(Note note);
  void editTags(Note note);
  void deleteNote(Note note);

  void noteEditorChooserSelected(Note note);
  void moveNoteToFolderSelected(Note note);
  void exitEditorSelected(Note note);
}

abstract class EditorState with ChangeNotifier {
  Note getNote();
  Future<void> addImage(String filePath);

  bool get noteModified;

  SearchInfo search(String? text);
  void scrollToResult(String text, int num);
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

  const EditorAppBar({
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
          editor.common.exitEditorSelected(editorState.getNote());
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
            editor.common.noteEditorChooserSelected(note);
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            var note = editorState.getNote();
            editor.common.deleteNote(note);
          },
        ),
      ],
    );
  }
}

Size textSize(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: ui.TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}
