import 'package:flutter/material.dart';

import 'package:gitjournal/widgets/app_bar_menu_button.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:gitjournal/widgets/folder_tree_view.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/core/notes_folder.dart';

import 'journal_listing.dart';

class FolderListingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    final appState = container.appState;

    var treeView = FolderTreeView(
      rootFolder: appState.notesFolder,
      onFolderSelected: (NotesFolder folder) {
        var route = MaterialPageRoute(
          builder: (context) => JournalListingScreen(
            notesFolder: folder,
          ),
        );
        Navigator.of(context).push(route);
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders'),
        leading: GJAppBarMenuButton(),
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
          final appState = container.appState;

          container.createFolder(appState.notesFolder, folderName);
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
