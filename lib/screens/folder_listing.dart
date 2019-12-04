import 'package:flutter/material.dart';

import 'package:gitjournal/widgets/app_bar_menu_button.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:gitjournal/widgets/folder_tree_view.dart';
import 'package:gitjournal/state_container.dart';

class FolderListingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    final appState = container.appState;

    var treeView = FolderTreeView(appState.noteFolder);

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
