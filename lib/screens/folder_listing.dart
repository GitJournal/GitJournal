import 'package:flutter/material.dart';

import 'package:gitjournal/widgets/app_bar_menu_button.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:gitjournal/state_container.dart';

import 'package:gitjournal/note_folder.dart';

typedef void ParentSelectChanged(bool isSelected);

class TreeView extends StatelessWidget {
  final List<FolderTile> parentList;

  TreeView({
    this.parentList = const <FolderTile>[],
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return parentList[index];
      },
      itemCount: parentList.length,
    );
  }
}

class FolderTile extends StatefulWidget {
  final NoteFolder folder;
  final ChildList childList;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final ParentSelectChanged callback;

  FolderTile({
    @required this.folder,
    @required this.childList,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
    this.callback,
  });

  @override
  FolderTileState createState() => FolderTileState();
}

class FolderTileState extends State<FolderTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: widget.mainAxisSize,
      crossAxisAlignment: widget.crossAxisAlignment,
      mainAxisAlignment: widget.mainAxisAlignment,
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
    if (widget.callback != null) widget.callback(_isExpanded);
    setState(() {
      _isExpanded = _toggleBool(_isExpanded);
    });
  }

  bool _toggleBool(bool b) {
    return b ? false : true;
  }

  Widget _getChild() {
    return _isExpanded ? widget.childList : Container();
  }
}

/// # ChildList widget
///
/// The [ChildList] widget holds a [List] of widget which will be displayed as
/// children of the [FolderTile] widget
class ChildList extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  ChildList({
    this.children = const <Widget>[],
    this.mainAxisSize = MainAxisSize.min,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}

class FolderListingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    final appState = container.appState;

    var treeView = TreeView(
      parentList: _constructParentList(appState.noteFolder.entities),
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

  List<FolderTile> _constructParentList(List<NoteFSEntity> entities) {
    var parents = <FolderTile>[];
    entities.forEach((entity) {
      if (entity.isNote) {
        return;
      }

      var folder = entity.folder;
      var p = FolderTile(
        folder: folder,
        childList: _constructChildList(folder.entities),
      );

      parents.add(p);
    });
    return parents;
  }

  ChildList _constructChildList(List<NoteFSEntity> entities) {
    var children = <Widget>[];
    entities.forEach((entity) {
      if (entity.isNote) {
        return;
      }

      var folder = entity.folder;
      var p = FolderTile(
        folder: folder,
        childList: _constructChildList(folder.entities),
      );

      children.add(p);
    });

    return ChildList(children: children);
  }
}
