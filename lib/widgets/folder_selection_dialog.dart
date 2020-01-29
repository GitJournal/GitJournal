import 'package:flutter/material.dart';
import 'package:gitjournal/core/notes_folder.dart';
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
      ),
    );

    return AlertDialog(
      title: const Text('Select a Folder'),
      content: body,
    );
  }
}

typedef void FolderSelectedCallback(NotesFolder folder);

class FolderTreeView extends StatelessWidget {
  final NotesFolder rootFolder;
  final FolderSelectedCallback onFolderEntered;

  FolderTreeView({
    Key key,
    @required this.rootFolder,
    @required this.onFolderEntered,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var tile = FolderMiniTile(
      folder: rootFolder,
      onTap: onFolderEntered,
    );

    return ListView(
      children: <Widget>[tile],
    );
  }
}

class FolderMiniTile extends StatefulWidget {
  final NotesFolder folder;
  final FolderSelectedCallback onTap;

  FolderMiniTile({
    @required this.folder,
    @required this.onTap,
  });

  @override
  FolderMiniTileState createState() => FolderMiniTileState();
}

class FolderMiniTileState extends State<FolderMiniTile> {
  final MainAxisSize mainAxisSize = MainAxisSize.min;
  final CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start;
  final MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center;

  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      children: <Widget>[
        GestureDetector(
          child: _buildFolderTile(),
          onTap: () => widget.onTap(widget.folder),
        ),
        _getChild(),
      ],
    );
  }

  Widget _buildFolderTile() {
    var folder = widget.folder;
    var ic = _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down;
    var trailling = folder.hasSubFolders
        ? IconButton(
            icon: Icon(ic),
            onPressed: expand,
          )
        : null;

    var folderName = folder.name;
    if (folder.parent == null) {
      folderName = "Notes";
    }

    return Card(
      child: ListTile(
        leading: Container(
          width: 16,
          height: 16,
          alignment: Alignment.center,
          child: Icon(
            Icons.folder,
            size: 24,
            color: Theme.of(context).accentColor,
          ),
        ),
        title: Text(folderName),
        trailing: trailling,
      ),
    );
  }

  void expand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Widget _getChild() {
    if (!_isExpanded) return Container();

    var children = <FolderMiniTile>[];
    widget.folder.getFolders().forEach((folder) {
      children.add(FolderMiniTile(
        folder: folder,
        onTap: widget.onTap,
      ));
    });

    return Container(
      margin: const EdgeInsets.only(left: 8.0),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      ),
    );
  }
}
