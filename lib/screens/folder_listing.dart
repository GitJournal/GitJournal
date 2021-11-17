/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/folder/flattened_notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/folder_views/folder_view.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:gitjournal/widgets/app_bar_menu_button.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:gitjournal/widgets/folder_tree_view.dart';
import 'package:gitjournal/widgets/rename_dialog.dart';

class FolderListingScreen extends StatefulWidget {
  static const routePath = '/folders';

  @override
  _FolderListingScreenState createState() => _FolderListingScreenState();
}

class _FolderListingScreenState extends State<FolderListingScreen> {
  final _folderTreeViewKey = GlobalKey<FolderTreeViewState>();
  NotesFolderFS? selectedFolder;

  @override
  Widget build(BuildContext context) {
    final notesFolder = Provider.of<NotesFolderFS>(context);

    // Load experimental setting
    var settings = Provider.of<AppConfig>(context);

    var treeView = FolderTreeView(
      key: _folderTreeViewKey,
      rootFolder: notesFolder,
      onFolderEntered: (NotesFolderFS folder) {
        late NotesFolder destination;
        if (settings.experimentalSubfolders) {
          destination = FlattenedNotesFolder(folder, title: folder.name);
        } else {
          destination = folder;
        }

        var route = MaterialPageRoute(
          builder: (context) => FolderView(
            notesFolder: destination,
          ),
          settings: const RouteSettings(name: '/folder/'),
        );
        var _ = Navigator.push(context, route);
      },
      onFolderSelected: (folder) {
        setState(() {
          selectedFolder = folder;
        });
      },
      onFolderUnselected: () {
        setState(() {
          selectedFolder = null;
        });
      },
    );

    Widget? action;
    if (selectedFolder != null) {
      action = PopupMenuButton(
        itemBuilder: (context) {
          return [
            PopupMenuItem<String>(
              child: Text(tr("screens.folders.actions.rename")),
              value: "Rename",
            ),
            PopupMenuItem<String>(
              child: Text(tr("screens.folders.actions.subFolder")),
              value: "Create",
            ),
            PopupMenuItem<String>(
              child: Text(tr("screens.folders.actions.delete")),
              value: "Delete",
            ),
          ];
        },
        onSelected: (String value) async {
          if (value == "Rename") {
            if (selectedFolder!.folderPath.isEmpty) {
              var _ = await showDialog(
                context: context,
                builder: (_) => RenameFolderErrorDialog(),
              );
              _folderTreeViewKey.currentState!.resetSelection();
              return;
            }
            var folderName = await showDialog(
              context: context,
              builder: (_) => RenameDialog(
                oldPath: selectedFolder!.folderPath,
                inputDecoration: tr("screens.folders.actions.decoration"),
                dialogTitle: tr("screens.folders.actions.rename"),
              ),
            );
            if (folderName is String) {
              var container = context.read<GitJournalRepo>();
              container.renameFolder(selectedFolder!, folderName);
            }
          } else if (value == "Create") {
            var folderName = await showDialog(
              context: context,
              builder: (_) => CreateFolderAlertDialog(),
            );
            if (folderName is String) {
              var container = context.read<GitJournalRepo>();
              container.createFolder(selectedFolder!, folderName);
            }
          } else if (value == "Delete") {
            if (selectedFolder!.hasNotesRecursive) {
              var _ = await showDialog(
                context: context,
                builder: (_) => DeleteFolderErrorDialog(),
              );
            } else {
              var container = context.read<GitJournalRepo>();
              container.removeFolder(selectedFolder!);
            }
          }

          _folderTreeViewKey.currentState!.resetSelection();
        },
      );
    }

    var backButton = IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        _folderTreeViewKey.currentState!.resetSelection();
      },
    );

    var title = Text(tr(LocaleKeys.screens_folders_title));
    if (selectedFolder != null) {
      title = Text(tr("screens.folders.selected"));
    }

    return Scaffold(
      appBar: AppBar(
        title: title,
        leading: selectedFolder == null ? GJAppBarMenuButton() : backButton,
        actions: <Widget>[
          if (selectedFolder != null) action!,
        ],
      ),
      body: Scrollbar(child: treeView),
      drawer: AppDrawer(),
      floatingActionButton: CreateFolderButton(),
    );
  }
}

class CreateFolderButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      key: const ValueKey("FAB"),
      onPressed: () async {
        var folderName = await showDialog(
          context: context,
          builder: (_) => CreateFolderAlertDialog(),
        );
        if (folderName is String) {
          var container = context.read<GitJournalRepo>();
          final notesFolder =
              Provider.of<NotesFolderFS>(context, listen: false);

          container.createFolder(notesFolder, folderName);
        }
      },
      child: const Icon(Icons.add),
    );
  }
}

class CreateFolderAlertDialog extends StatefulWidget {
  @override
  _CreateFolderAlertDialogState createState() =>
      _CreateFolderAlertDialogState();
}

class _CreateFolderAlertDialogState extends State<CreateFolderAlertDialog> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var form = Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              labelText: tr("screens.folders.actions.decoration"),
            ),
            validator: (value) {
              if (value!.isEmpty) return tr("screens.folders.actions.empty");
              return "";
            },
            autofocus: true,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.words,
            controller: _textController,
          ),
        ],
      ),
    );

    return AlertDialog(
      title: Text(tr("screens.folders.dialog.title")),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(tr("screens.folders.dialog.discard")),
        ),
        TextButton(
          onPressed: () {
            var newFolderName = _textController.text;
            return Navigator.of(context).pop(newFolderName);
          },
          child: Text(tr("screens.folders.dialog.create")),
        ),
      ],
      content: form,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class FolderErrorDialog extends StatelessWidget {
  final String content;

  const FolderErrorDialog(this.content);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(tr("screens.folders.errorDialog.title")),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          child: Text(tr("screens.folders.errorDialog.ok")),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class DeleteFolderErrorDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FolderErrorDialog(tr("screens.folders.errorDialog.deleteContent"));
  }
}

class RenameFolderErrorDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FolderErrorDialog(tr("screens.folders.errorDialog.renameContent"));
  }
}
