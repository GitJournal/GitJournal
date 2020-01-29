import 'package:flutter/material.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/widgets/folder_tree_view.dart';
import 'package:provider/provider.dart';

typedef NoteFolderCallback = void Function(NotesFolder);

class FolderSelectionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notesFolder = Provider.of<NotesFolder>(context);

    var body = Container(
      width: double.maxFinite,
      child: FolderTreeView(
        rootFolder: notesFolder,
        onFolderEntered: (NotesFolder destFolder) {
          Navigator.of(context).pop(destFolder);
        },
        longPressAllowed: false,
      ),
    );

    return AlertDialog(
      title: const Text('Select a Folder'),
      content: body,
    );
  }
}

// FIXME: Add the previously as a radio button selected Folder
