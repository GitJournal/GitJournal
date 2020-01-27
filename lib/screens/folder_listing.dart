import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/widgets/app_bar_menu_button.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:gitjournal/widgets/folder_tree_view.dart';
import 'package:gitjournal/widgets/rename_dialog.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/core/notes_folder.dart';

import 'journal_listing.dart';

class FolderListingScreen extends StatefulWidget {
  @override
  _FolderListingScreenState createState() => _FolderListingScreenState();
}

class _FolderListingScreenState extends State<FolderListingScreen> {
  final _folderTreeViewKey = GlobalKey<FolderTreeViewState>();
  NotesFolder selectedFolder;

  @override
  Widget build(BuildContext context) {
    final notesFolder = Provider.of<NotesFolder>(context);

    var treeView = FolderTreeView(
      key: _folderTreeViewKey,
      rootFolder: notesFolder,
      onFolderEntered: (NotesFolder folder) {
        var route = MaterialPageRoute(
          builder: (context) => JournalListingScreen(
            notesFolder: folder,
          ),
        );
        Navigator.of(context).push(route);
      },
      onFolderSelected: (folder) {
        setState(() {
          selectedFolder = folder;
        });
      },
      onFolderUnselected: () {
        setState(() {
          selectedFolder = null;
        });
      },
    );

    Widget action;
    if (selectedFolder != null) {
      action = PopupMenuButton(
        itemBuilder: (context) {
          return [
            const PopupMenuItem<String>(
              child: Text("Rename Folder"),
              value: "Rename",
            ),
            const PopupMenuItem<String>(
              child: Text("Create Sub-Folder"),
              value: "Create",
            ),
            const PopupMenuItem<String>(
              child: Text("Delete Folder"),
              value: "Delete",
            ),
          ];
        },
        onSelected: (String value) async {
          if (value == "Rename") {
            var folderName = await showDialog(
              context: context,
              builder: (_) => RenameDialog(
                oldPath: selectedFolder.folderPath,
                inputDecoration: 'Folder Name',
                dialogTitle: "Rename Folder",
              ),
            );
            if (folderName is String) {
              final container = StateContainer.of(context);
              container.renameFolder(selectedFolder, folderName);
            }
          } else if (value == "Create") {
            var folderName = await showDialog(
              context: context,
              builder: (_) => CreateFolderAlertDialog(),
            );
            if (folderName is String) {
              final container = StateContainer.of(context);
              container.createFolder(selectedFolder, folderName);
            }
          } else if (value == "Delete") {
            if (selectedFolder.hasNotesRecursive) {
              await showDialog(
                context: context,
                builder: (_) => FolderErrorDialog(),
              );
            } else {
              final container = StateContainer.of(context);
              container.removeFolder(selectedFolder);
            }
          }

          _folderTreeViewKey.currentState.resetSelection();
        },
      );
    }

    var backButton = IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        _folderTreeViewKey.currentState.resetSelection();
      },
    );

    var title = const Text("Folders");
    if (selectedFolder != null) {
      title = const Text("Folder Selected");
    }

    return Scaffold(
      appBar: AppBar(
        title: title,
        leading: selectedFolder == null ? GJAppBarMenuButton() : backButton,
        actions: <Widget>[
          if (selectedFolder != null) action,
        ],
      ),
      body: Scrollbar(child: treeView),
      drawer: AppDrawer(),
      floatingActionButton: CreateFolderButton(),
    );
  }
}

class CreateFolderButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      key: const ValueKey("FAB"),
      onPressed: () async {
        var folderName = await showDialog(
          context: context,
          builder: (_) => CreateFolderAlertDialog(),
        );
        if (folderName is String) {
          final container = StateContainer.of(context);
          final notesFolder = Provider.of<NotesFolder>(context);

          container.createFolder(notesFolder, folderName);
        }
      },
      child: Icon(Icons.add),
    );
  }
}

class CreateFolderAlertDialog extends StatefulWidget {
  @override
  _CreateFolderAlertDialogState createState() =>
      _CreateFolderAlertDialogState();
}

class _CreateFolderAlertDialogState extends State<CreateFolderAlertDialog> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var form = Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(labelText: 'Folder Name'),
            validator: (value) {
              if (value.isEmpty) return 'Please enter a name';
              return "";
            },
            autofocus: true,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.words,
            controller: _textController,
          ),
        ],
      ),
    );

    return AlertDialog(
      title: const Text("Create new Folder"),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Discard"),
        ),
        FlatButton(
          onPressed: () {
            var newFolderName = _textController.text;
            return Navigator.of(context).pop(newFolderName);
          },
          child: const Text("Create"),
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

class FolderErrorDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Error"),
      content: const Text("Cannot delete a Folder which contains notes"),
      actions: <Widget>[
        FlatButton(
          child: const Text("Ok"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
