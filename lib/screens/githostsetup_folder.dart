import 'package:flutter/material.dart';
import 'package:function_types/function_types.dart';

import 'githostsetup_button.dart';

class GitHostSetupFolderPage extends StatelessWidget {
  final List<String> folders;
  final Func0<void> rootFolderSelected;
  final Func1<String, void> subFolderSelected;

  GitHostSetupFolderPage({
    @required this.folders,
    @required this.rootFolderSelected,
    @required this.subFolderSelected,
  });

  @override
  Widget build(BuildContext context) {
    var columns = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Would you like to store your journal entries in an existing folder?',
          style: Theme.of(context).textTheme.title,
        ),
        const SizedBox(height: 32.0),
        FolderListWidget(
          folders: folders,
          onSelected: subFolderSelected,
        ),
        const SizedBox(height: 16.0),
        GitHostSetupButton(
          text: "Ignore",
          onPressed: rootFolderSelected,
        ),
      ],
    );

    return Center(
      child: SingleChildScrollView(
        child: columns,
      ),
    );
  }
}

// FIXME: This needs to be made much much prettier!
class FolderListWidget extends StatelessWidget {
  final List<String> folders;
  final Func1<String, void> onSelected;

  FolderListWidget({
    @required this.folders,
    @required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    var buttons = <Widget>[];
    for (var folderName in folders) {
      var button = GitHostSetupButton(
        text: folderName,
        onPressed: () {
          onSelected(folderName);
        },
      );
      buttons.add(button);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: buttons,
    );
  }
}
