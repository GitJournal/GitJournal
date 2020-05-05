import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:share/share.dart';

import 'package:image_picker/image_picker.dart';

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
  Future<void> addImage(File file);
}

enum DropDownChoices { Rename, DiscardChanges, Share }

AppBar buildEditorAppBar(
  Editor editor,
  EditorState editorState, {
  @required bool noteModified,
  List<IconButton> extraButtons,
}) {
  return AppBar(
    leading: IconButton(
      key: const ValueKey("NewEntry"),
      icon: Icon(noteModified ? Icons.check : Icons.close),
      onPressed: () {
        editor.exitEditorSelected(editorState.getNote());
      },
    ),
    actions: <Widget>[
      ...?extraButtons,
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
      PopupMenuButton<DropDownChoices>(
        onSelected: (DropDownChoices choice) {
          switch (choice) {
            case DropDownChoices.Rename:
              var note = editorState.getNote();
              editor.renameNoteSelected(note);
              return;

            case DropDownChoices.DiscardChanges:
              var note = editorState.getNote();
              editor.discardChangesSelected(note);
              return;

            case DropDownChoices.Share:
              var note = editorState.getNote();
              Share.share(note.body);
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
            value: DropDownChoices.DiscardChanges,
            child: Text('Discard Changes'),
          ),
          const PopupMenuItem<DropDownChoices>(
            value: DropDownChoices.Share,
            child: Text('Share Note'),
          ),
        ],
      ),
    ],
  );
}

Widget buildEditorBottonBar(
  BuildContext context,
  Editor editor,
  EditorState editorState,
  NotesFolderFS parentFolder,
) {
  var folderName = parentFolder.pathSpec();
  if (folderName.isEmpty) {
    folderName = "Root Folder";
  }

  var s = Scaffold.of(context);
  print("s $s");
  return StickyBottomAppBar(
    child: BottomAppBar(
      elevation: 0.0,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (c) => _buildAddBottomSheet(c, editor, editorState),
                elevation: 0,
              );
            },
          ),
          Expanded(
            child: FlatButton.icon(
              icon: Icon(Icons.folder),
              label: Text(folderName),
              onPressed: () {
                var note = editorState.getNote();
                editor.moveNoteToFolderSelected(note);
              },
            ),
          ),
          const SizedBox(
            height: 32.0,
            width: 32.0,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    ),
  );
}

class StickyBottomAppBar extends StatelessWidget {
  final BottomAppBar child;
  StickyBottomAppBar({@required this.child});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0.0, -1 * MediaQuery.of(context).viewInsets.bottom),
      child: child,
    );
  }
}

Widget _buildAddBottomSheet(
  BuildContext context,
  Editor editor,
  EditorState editorState,
) {
  return Container(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.camera),
          title: const Text("Take Photo"),
          onTap: () async {
            try {
              var image = await ImagePicker.pickImage(
                source: ImageSource.camera,
              );

              if (image != null) {
                await editorState.addImage(image);
              }
            } catch (e) {
              reportError(e, StackTrace.current);
            }
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          leading: Icon(Icons.image),
          title: const Text("Add Image"),
          onTap: () async {
            try {
              var image = await ImagePicker.pickImage(
                source: ImageSource.gallery,
              );

              if (image != null) {
                await editorState.addImage(image);
              }
            } catch (e) {
              reportError(e, StackTrace.current);
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}
