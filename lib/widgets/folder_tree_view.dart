import 'package:flutter/material.dart';

import 'package:gitjournal/core/notes_folder.dart';

typedef void FolderSelectedCallback(NotesFolder folder);

class FolderTreeView extends StatelessWidget {
  final NotesFolder rootFolder;
  final FolderSelectedCallback onFolderSelected;

  FolderTreeView({
    @required this.rootFolder,
    @required this.onFolderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        FolderTile(rootFolder, onFolderSelected),
      ],
    );
  }
}

class FolderTile extends StatefulWidget {
  final NotesFolder folder;
  final FolderSelectedCallback onFolderSelected;

  FolderTile(this.folder, this.onFolderSelected);

  @override
  FolderTileState createState() => FolderTileState();
}

class FolderTileState extends State<FolderTile> {
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

    var folderName = folder.name;
    if (folder.parent == null) {
      folderName = "Notes";
    }
    var subtitle = folder.numberOfNotes.toString() + " Notes";

    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(Icons.folder, size: 36),
        ),
        title: Text(folderName),
        subtitle: Text(subtitle),
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
