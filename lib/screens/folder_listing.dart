import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/widgets/app_bar_menu_button.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:gitjournal/widgets/folder_tree_view.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/core/notes_folder.dart';

import 'journal_listing.dart';

class FolderListingScreen extends StatefulWidget {
  @override
  _FolderListingScreenState createState() => _FolderListingScreenState();
}

class _FolderListingScreenState extends State<FolderListingScreen> {
  NotesFolder selectedFolder;

  @override
  Widget build(BuildContext context) {
    final notesFolder = Provider.of<NotesFolder>(context);

    var treeView = FolderTreeView(
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
              value: "Rename Folder",
            )
          ];
        },
        onSelected: (String _) async {
          var folderName = await showDialog(
            context: context,
            builder: (_) => RenameFolderDialog(selectedFolder),
          );
          if (folderName is String) {
            final container = StateContainer.of(context);
            container.renameFolder(selectedFolder, folderName);
          }
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders'),
        leading: GJAppBarMenuButton(),
        actions: <Widget>[
          if (selectedFolder != null) action,
        ],
      ),
      body: treeView,
      drawer: AppDrawer(),
      floatingActionButton: CreateFolderButton(),
    );
  }
}

class CreateFolderButton extends StatefulWidget {
  @override
  _CreateFolderButtonState createState() => _CreateFolderButtonState();
}

class _CreateFolderButtonState extends State<CreateFolderButton> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      key: const ValueKey("FAB"),
      onPressed: () async {
        var folderName =
            await showDialog(context: context, builder: _buildAlert);
        if (folderName is String) {
          final container = StateContainer.of(context);
          final notesFolder = Provider.of<NotesFolder>(context);

          container.createFolder(notesFolder, folderName);
        }
      },
      child: Icon(Icons.add),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Widget _buildAlert(BuildContext context) {
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
}

class RenameFolderDialog extends StatefulWidget {
  final NotesFolder folder;

  RenameFolderDialog(this.folder);

  @override
  _RenameFolderDialogState createState() => _RenameFolderDialogState();
}

class _RenameFolderDialogState extends State<RenameFolderDialog> {
  TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.folder.name);
  }

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
            controller: _textController,
          ),
        ],
      ),
    );

    return AlertDialog(
      title: const Text("Rename Folder"),
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
