import 'package:flutter/material.dart';

import 'package:gitjournal/widgets/app_bar_menu_button.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:gitjournal/widgets/folder_tree_view.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/note_folder.dart';

import 'journal_listing.dart';

class FolderListingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    final appState = container.appState;

    var treeView = FolderTreeView(
      rootFolder: appState.noteFolder,
      onFolderSelected: (NoteFolder folder) {
        var route = MaterialPageRoute(
          builder: (context) => JournalListingScreen(
            noteFolder: folder,
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
    );
  }
}
