/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';

typedef NoteFolderCallback = void Function(NotesFolderFS);

class FolderSelectionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notesFolder = Provider.of<NotesFolderFS>(context);

    var body = SizedBox(
      width: double.maxFinite,
      child: FolderTreeView(
        rootFolder: notesFolder,
        onFolderEntered: (NotesFolderFS destFolder) {
          Navigator.of(context).pop(destFolder);
        },
      ),
    );

    return AlertDialog(
      title: Text(tr(LocaleKeys.widgets_FolderSelectionDialog_title)),
      content: body,
    );
  }
}

typedef FolderSelectedCallback = void Function(NotesFolderFS folder);

class FolderTreeView extends StatelessWidget {
  final NotesFolderFS rootFolder;
  final FolderSelectedCallback onFolderEntered;

  const FolderTreeView({
    Key? key,
    required this.rootFolder,
    required this.onFolderEntered,
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
  final NotesFolderFS folder;
  final FolderSelectedCallback onTap;

  const FolderMiniTile({
    required this.folder,
    required this.onTap,
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

    return Card(
      child: ListTile(
        leading: Container(
          width: 16,
          height: 16,
          alignment: Alignment.center,
          child: Icon(
            Icons.folder,
            size: 24,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        title: Text(folder.publicName),
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
    for (var folder in widget.folder.subFolders) {
      children.add(FolderMiniTile(
        folder: folder as NotesFolderFS,
        onTap: widget.onTap,
      ));
    }

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
