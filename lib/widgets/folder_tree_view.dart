import 'package:flutter/material.dart';

import 'package:gitjournal/note_folder.dart';

typedef void ParentSelectChanged(bool isSelected);

class FolderTreeView extends StatelessWidget {
  final NoteFolder rootFolder;

  FolderTreeView(this.rootFolder);

  @override
  Widget build(BuildContext context) {
    var folderTiles = <FolderTile>[];
    rootFolder.entities.forEach((entity) {
      if (entity.isNote) return;

      folderTiles.add(FolderTile(entity.folder));
    });

    return ListView(
      children: folderTiles,
    );
  }
}

class FolderTile extends StatefulWidget {
  final NoteFolder folder;
  //final ParentSelectChanged callback;

  FolderTile(this.folder);

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
          onTap: expand,
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
    //if (widget.callback != null) widget.callback(_isExpanded);
    setState(() {
      _isExpanded = _toggleBool(_isExpanded);
    });
  }

  bool _toggleBool(bool b) {
    return b ? false : true;
  }

  Widget _getChild() {
    if (!_isExpanded) return Container();

    var children = <FolderTile>[];
    widget.folder.entities.forEach((entity) {
      if (entity.isNote) return;
      children.add(FolderTile(entity.folder));
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
