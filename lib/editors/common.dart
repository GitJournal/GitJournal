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

class EditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Editor editor;
  final EditorState editorState;
  final bool noteModified;
  final IconButton extraButton;

  EditorAppBar({
    Key key,
    @required this.editor,
    @required this.editorState,
    @required this.noteModified,
    this.extraButton,
  })  : preferredSize = Size.fromHeight(kToolbarHeight),
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
        if (extraButton != null) extraButton,
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
}

class EditorBottomBar extends StatelessWidget {
  final Editor editor;
  final EditorState editorState;
  final NotesFolderFS parentFolder;
  final bool allowEdits;

  EditorBottomBar({
    @required this.editor,
    @required this.editorState,
    @required this.parentFolder,
    @required this.allowEdits,
  });

  @override
  Widget build(BuildContext context) {
    var folderName = parentFolder.pathSpec();
    if (folderName.isEmpty) {
      folderName = "Root Folder";
    }

    var addIcon = IconButton(
      icon: Icon(Icons.attach_file),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (c) => _buildAddBottomSheet(c, editor, editorState),
          elevation: 0,
        );
      },
    );

    return BottomAppBar(
      elevation: 0.0,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: <Widget>[
          Visibility(
            child: addIcon,
            visible: allowEdits,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            maintainInteractivity: false,
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
          // Just so there is equal padding on the right side
          Visibility(
            child: addIcon,
            visible: false,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            maintainInteractivity: false,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
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

class EditorScaffold extends StatelessWidget {
  final Editor editor;
  final EditorState editorState;
  final bool noteModified;
  final IconButton extraButton;
  final Widget body;
  final NotesFolderFS parentFolder;
  final bool allowEdits;

  EditorScaffold({
    @required this.editor,
    @required this.editorState,
    @required this.noteModified,
    @required this.body,
    @required this.parentFolder,
    this.extraButton,
    this.allowEdits = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EditorAppBar(
        editor: editor,
        editorState: editorState,
        noteModified: noteModified,
        extraButton: extraButton,
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: body),
          EditorBottomBar(
            editor: editor,
            editorState: editorState,
            parentFolder: parentFolder,
            allowEdits: allowEdits,
          ),
        ],
      ),
    );
  }
}
