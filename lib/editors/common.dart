import 'package:flutter/material.dart';
import 'package:gitjournal/core/note.dart';

typedef NoteCallback = void Function(Note);

abstract class Editor {
  NoteCallback get noteDeletionSelected;
  NoteCallback get noteEditorChooserSelected;
  NoteCallback get exitEditorSelected;
  NoteCallback get renameNoteSelected;
  NoteCallback get moveNoteToFolderSelected;
  NoteCallback get discardChangesSelected;
}

abstract class EditorState {
  Note getNote();
}

enum DropDownChoices { Rename, MoveToFolder, DiscardChanges }

AppBar buildEditorAppBar(
  Editor editor,
  EditorState editorState, {
  List<IconButton> extraButtons,
}) {
  return AppBar(
    leading: IconButton(
      key: const ValueKey("NewEntry"),
      icon: const Icon(Icons.check),
      onPressed: () {
        editor.exitEditorSelected(editorState.getNote());
      },
    ),
    actions: <Widget>[
      ...?extraButtons,
      IconButton(
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
      PopupMenuButton<DropDownChoices>(
        onSelected: (DropDownChoices choice) {
          switch (choice) {
            case DropDownChoices.Rename:
              var note = editorState.getNote();
              editor.renameNoteSelected(note);
              return;

            case DropDownChoices.MoveToFolder:
              var note = editorState.getNote();
              editor.moveNoteToFolderSelected(note);
              return;

            case DropDownChoices.DiscardChanges:
              var note = editorState.getNote();
              editor.discardChangesSelected(note);
              return;
          }
        },
        itemBuilder: (BuildContext context) =>
            <PopupMenuEntry<DropDownChoices>>[
          const PopupMenuItem<DropDownChoices>(
            value: DropDownChoices.Rename,
            child: Text('Edit File Name'),
          ),
          const PopupMenuItem<DropDownChoices>(
            value: DropDownChoices.MoveToFolder,
            child: Text('Move to Folder'),
          ),
          const PopupMenuItem<DropDownChoices>(
            value: DropDownChoices.DiscardChanges,
            child: Text('Discard Changes'),
          ),
        ],
      ),
    ],
  );
}

FloatingActionButton buildFAB(Editor editor, EditorState editorState) {
  return FloatingActionButton(
    child: const Icon(Icons.check),
    onPressed: () {
      editor.exitEditorSelected(editorState.getNote());
    },
  );
}
