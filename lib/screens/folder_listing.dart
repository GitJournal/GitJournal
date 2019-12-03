import 'package:flutter/material.dart';

import 'package:gitjournal/widgets/app_bar_menu_button.dart';
import 'package:gitjournal/widgets/app_drawer.dart';

typedef void ParentSelectChanged(bool isSelected);

/// # Tree View
///
/// Creates a tree view widget. The widget is a List View with a [List] of
/// [Parent] widgets. The [TreeView] is nested inside a [Scrollbar] if the
/// [TreeView.hasScrollBar] property is true.
class TreeView extends StatelessWidget {
  final List<Parent> parentList;
  final bool hasScrollBar;

  TreeView({
    this.parentList = const <Parent>[],
    this.hasScrollBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return hasScrollBar ? Scrollbar(child: _getTreeList()) : _getTreeList();
  }

  Widget _getTreeList() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return parentList[index];
      },
      itemCount: parentList.length,
    );
  }
}

/// # Parent widget
///
/// The [Parent] widget holds the [Parent.parent] widget and
/// [Parent.childList] which is a [List] of child widgets.
///
/// The [Parent] widget is wrapped around a [Column]. The [Parent.childList]
/// is collapsed by default. When clicked the child widget is expanded.
class Parent extends StatefulWidget {
  final Widget parent;
  final ChildList childList;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final ParentSelectChanged callback;
  final Key key;

  Parent({
    @required this.parent,
    @required this.childList,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
    this.callback,
    this.key,
  });

  @override
  ParentState createState() => ParentState();
}

class ParentState extends State<Parent> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: widget.mainAxisSize,
      crossAxisAlignment: widget.crossAxisAlignment,
      mainAxisAlignment: widget.mainAxisAlignment,
      children: <Widget>[
        GestureDetector(
          child: widget.parent,
          onTap: expand,
        ),
        _getChild(),
      ],
    );
  }

  void expand() {
    if (widget.callback != null) widget.callback(_isSelected);
    setState(() {
      _isSelected = _toggleBool(_isSelected);
    });
  }

  bool _toggleBool(bool b) {
    return b ? false : true;
  }

  Widget _getChild() {
    return _isSelected ? widget.childList : Container();
  }
}

/// # ChildList widget
///
/// The [ChildList] widget holds a [List] of widget which will be displayed as
/// children of the [Parent] widget
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
    var treeView = TreeView(
      parentList: [
        Parent(
          parent: _buildFolderTile("Desktop"),
          childList: ChildList(
            children: <Widget>[
              Parent(
                parent: _buildFolderTile('documents'),
                childList: ChildList(
                  children: <Widget>[
                    _buildFolderTile('Resume.docx'),
                    _buildFolderTile('Billing-Info.docx'),
                  ],
                ),
              ),
              _buildFolderTile('MeetingReport.xls'),
              _buildFolderTile('MeetingReport.pdf'),
              _buildFolderTile('Demo.zip'),
            ],
          ),
        ),
      ],
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

  Widget _buildFolderTile(String name) {
    // FIXME: The trailing icon should change based on if it is expanded or not

    return Card(
      child: ListTile(
        leading: Icon(Icons.folder),
        title: Text(name),
        trailing: IconButton(
          icon: Icon(Icons.navigate_next),
          onPressed: () {},
        ),
      ),
    );
  }
}
