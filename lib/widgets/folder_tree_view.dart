import 'package:flutter/material.dart';

import 'package:gitjournal/core/note_folder.dart';

typedef void FolderSelectedCallback(NoteFolder folder);

class FolderTreeView extends StatelessWidget {
  final NoteFolder rootFolder;
  final FolderSelectedCallback onFolderSelected;

  FolderTreeView({
    @required this.rootFolder,
    @required this.onFolderSelected,
  });

  @override
  Widget build(BuildContext context) {
    var folderTiles = <FolderTile>[];
    rootFolder.entities.forEach((entity) {
      if (entity.isNote) return;

      folderTiles.add(FolderTile(entity.folder, onFolderSelected));
    });

    return ListView(
      children: folderTiles,
    );
  }
}

class FolderTile extends StatefulWidget {
  final NoteFolder folder;
  final FolderSelectedCallback onFolderSelected;

  FolderTile(this.folder, this.onFolderSelected);

  @override
  FolderTileState createState() => FolderTileState();
}

class FolderTileState extends State<FolderTile> {
  final MainAxisSize mainAxisSize = MainAxisSize.min;
  final CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start;
  final MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center;

  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      children: <Widget>[
        GestureDetector(
          child: _buildFolderTile(),
          onTap: () => widget.onFolderSelected(widget.folder),
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

    return Card(
      child: ListTile(
        leading: Icon(Icons.folder),
        title: Text(folder.name),
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

    var children = <FolderTile>[];
    widget.folder.entities.forEach((entity) {
      if (entity.isNote) return;
      children.add(FolderTile(entity.folder, widget.onFolderSelected));
    });

    return Container(
      margin: const EdgeInsets.only(left: 16.0),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      ),
    );
  }
}
