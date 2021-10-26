/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:function_types/function_types.dart';

import 'package:gitjournal/core/folder/notes_folder_fs.dart';

typedef FolderSelectedCallback = void Function(NotesFolderFS folder);

class FolderTreeView extends StatefulWidget {
  final NotesFolderFS rootFolder;

  final FolderSelectedCallback onFolderSelected;
  final Func0<void> onFolderUnselected;
  final FolderSelectedCallback onFolderEntered;

  const FolderTreeView({
    Key? key,
    required this.rootFolder,
    required this.onFolderEntered,
    this.onFolderSelected = _doNothing,
    this.onFolderUnselected = _doNothing2,
  }) : super(key: key);

  @override
  FolderTreeViewState createState() => FolderTreeViewState();

  static void _doNothing(NotesFolderFS f) {}
  static void _doNothing2() {}
}

class FolderTreeViewState extends State<FolderTreeView> {
  bool inSelectionMode = false;
  NotesFolderFS? selectedFolder;

  @override
  Widget build(BuildContext context) {
    var tile = FolderTile(
      folder: widget.rootFolder,
      onTap: (NotesFolderFS folder) {
        if (!inSelectionMode) {
          widget.onFolderEntered(folder);
        } else {
          setState(() {
            inSelectionMode = false;
            selectedFolder = null;
          });
          widget.onFolderUnselected();
        }
      },
      onLongPress: (folder) {
        setState(() {
          inSelectionMode = true;
          selectedFolder = folder;
        });
        widget.onFolderSelected(folder);
      },
      selectedFolder: selectedFolder,
    );

    return ListView(
      children: <Widget>[tile],
    );
  }

  void resetSelection() {
    setState(() {
      selectedFolder = null;
    });
    widget.onFolderUnselected();
  }
}

class FolderTile extends StatefulWidget {
  final NotesFolderFS folder;
  final FolderSelectedCallback onTap;
  final FolderSelectedCallback onLongPress;
  final NotesFolderFS? selectedFolder;

  const FolderTile({
    required this.folder,
    required this.onTap,
    required this.onLongPress,
    required this.selectedFolder,
  });

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
          onTap: () => widget.onTap(widget.folder),
          onLongPress: () => widget.onLongPress(widget.folder),
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

    // FIXME: Translate
    var subtitle = folder.numberOfNotes.toString() + " Notes";

    final theme = Theme.of(context);

    var publicName = folder.publicName;
    if (folder.parent != null) {
      if (publicName.startsWith('/')) {
        publicName = publicName.substring(1);
      }
    }

    var selected = widget.selectedFolder == widget.folder;
    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            Icons.folder,
            size: 36,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        title: Text(publicName),
        subtitle: Text(subtitle),
        trailing: trailling,
        selected: selected,
      ),
      color: selected ? theme.selectedRowColor : theme.cardColor,
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
    for (var folder in widget.folder.subFolders) {
      children.add(FolderTile(
        folder: folder as NotesFolderFS,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        selectedFolder: widget.selectedFolder,
      ));
    }

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
