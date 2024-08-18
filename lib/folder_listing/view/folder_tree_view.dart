/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:function_types/function_types.dart';
import 'package:gitjournal/folder_listing/model/folder_listing_model.dart';
import 'package:gitjournal/l10n.dart';

typedef FolderSelectedCallback = void Function(FolderListingFolder folder);

class FolderTreeView extends StatelessWidget {
  final FolderListingFolder rootFolder;
  final String? selectedPath;

  final FolderSelectedCallback onFolderSelected;
  final Func0<void> onFolderUnselected;
  final FolderSelectedCallback onFolderEntered;

  const FolderTreeView({
    super.key,
    required this.rootFolder,
    required this.selectedPath,
    required this.onFolderEntered,
    required this.onFolderSelected,
    required this.onFolderUnselected,
  });

  @override
  Widget build(BuildContext context) {
    var tile = FolderTile(
      folder: rootFolder,
      onTap: (FolderListingFolder folder) {
        if (selectedPath == null) {
          onFolderEntered(folder);
        } else {
          onFolderUnselected();
        }
      },
      onLongPress: (folder) {
        onFolderSelected(folder);
      },
      selectedPath: selectedPath,
    );

    return ListView(
      children: <Widget>[tile],
    );
  }
}

class FolderTile extends StatefulWidget {
  final FolderListingFolder folder;
  final FolderSelectedCallback onTap;
  final FolderSelectedCallback onLongPress;
  final String? selectedPath;

  const FolderTile({
    required this.folder,
    required this.onTap,
    required this.onLongPress,
    required this.selectedPath,
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

    final subtitle = context.loc
        .widgetsFolderTreeViewNotesCount(folder.noteCount.toString());

    final theme = Theme.of(context);

    var selected = widget.selectedPath == widget.folder.path;
    return Card(
      color: selected ? theme.highlightColor : theme.cardColor,
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
        title:
            Text(folder.publicName.isEmpty ? "Root Folder" : folder.publicName),
        subtitle: Text(subtitle),
        trailing: trailling,
        selected: selected,
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
    for (var folder in widget.folder.subFolders) {
      children.add(FolderTile(
        folder: folder,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        selectedPath: widget.selectedPath,
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
