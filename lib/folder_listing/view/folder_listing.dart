/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gitjournal/core/folder/flattened_notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/folder_listing/bloc/folder_listing_bloc.dart';
import 'package:gitjournal/folder_listing/bloc/folder_listing_event.dart';
import 'package:gitjournal/folder_listing/bloc/folder_listing_state.dart';
import 'package:gitjournal/folder_listing/view/folder_tree_view.dart';
import 'package:gitjournal/folder_views/folder_view.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:gitjournal/utils/utils.dart';
import 'package:gitjournal/widgets/app_bar_menu_button.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:gitjournal/widgets/note_delete_dialog.dart';
import 'package:gitjournal/widgets/rename_dialog.dart';

class FolderListingScreen extends StatelessWidget {
  static const routePath = '/folders';

  Widget _buildLoaded(BuildContext context, FolderListingLoaded state) {
    var treeView = FolderTreeView(
      rootFolder: state.folder,
      selectedPath: state.selectedFolderPath,
      onFolderEntered: (folder) async {
        var settings = context.read<AppConfig>();

        var rootFolder = context.read<NotesFolderFS>();
        var notesFolder = rootFolder.getFolderWithSpec(folder.path);
        if (notesFolder == null) {
          showErrorSnackbar(context, "Folder not found");
          return;
        }

        var destination = settings.experimentalSubfolders
            ? FlattenedNotesFolder(
                notesFolder,
                title: folder.publicName,
              )
            : notesFolder;

        var route = MaterialPageRoute(
          builder: (context) => FolderView(
            notesFolder: destination,
          ),
          settings: const RouteSettings(name: '/folder/'),
        );
        Navigator.push(context, route);
      },
      onFolderSelected: (folder) {
        var bloc = context.read<FolderListingBloc>();
        bloc.add(FolderListingFolderSelected(folder.path));
      },
      onFolderUnselected: () {
        var bloc = context.read<FolderListingBloc>();
        bloc.add(FolderListingFolderUnselected());
      },
    );

    var selectedFolderPath = state.selectedFolderPath;
    var action = selectedFolderPath == null
        ? null
        : PopupMenuButton(
            itemBuilder: (context) {
              return [
                if (state.canRename)
                  PopupMenuItem<String>(
                    value: "Rename",
                    child: Text(context.loc.screensFoldersActionsRename),
                  ),
                if (state.canCreate)
                  PopupMenuItem<String>(
                    value: "Create",
                    child: Text(context.loc.screensFoldersActionsSubFolder),
                  ),
                if (state.canDelete)
                  PopupMenuItem<String>(
                    value: "Delete",
                    child: Text(context.loc.screensFoldersActionsDelete),
                  ),
              ];
            },
            onSelected: (String value) async {
              if (value == "Rename") {
                var folderName = await showDialog(
                  context: context,
                  builder: (_) => RenameDialog(
                    oldPath: selectedFolderPath,
                    inputDecoration:
                        context.loc.screensFoldersActionsDecoration,
                    dialogTitle: context.loc.screensFoldersActionsRename,
                  ),
                );
                if (folderName is String) {
                  var bloc = context.read<FolderListingBloc>();
                  bloc.add(FolderListingFolderRenamed(
                    oldPath: selectedFolderPath,
                    newPath: folderName,
                  ));
                }
              } else if (value == "Create") {
                var folderName = await showDialog(
                  context: context,
                  builder: (_) => CreateFolderAlertDialog(),
                );
                if (folderName is String) {
                  var bloc = context.read<FolderListingBloc>();
                  bloc.add(FolderListingFolderCreated(folderName));
                }
              } else if (value == "Delete") {
                var shouldDelete = await showDialog(
                  context: context,
                  builder: (context) => const NotesFolderDeleteDialog(),
                );
                if (shouldDelete != true) return;

                var bloc = context.read<FolderListingBloc>();
                bloc.add(FolderListingFolderDeleted(selectedFolderPath));
              }
            },

            // _folderTreeViewKey.currentState!.resetSelection();
          );

    var backButton = IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        var bloc = context.read<FolderListingBloc>();
        bloc.add(FolderListingFolderUnselected());
      },
    );

    var title = state.selectedFolderPath == null
        ? Text(context.loc.screensFoldersTitle)
        : Text(context.loc.screensFoldersSelected);

    return Scaffold(
      appBar: AppBar(
        title: title,
        leading: state.selectedFolderPath == null
            ? GJAppBarMenuButton()
            : backButton,
        actions: <Widget>[
          if (action != null) action,
        ],
      ),
      body: Scrollbar(child: treeView),
      drawer: AppDrawer(),
      floatingActionButton: CreateFolderButton(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final view = BlocConsumer<FolderListingBloc, FolderListingState>(
      builder: (context, state) {
        if (state is FolderListingLoaded) {
          return _buildLoaded(context, state);
        }

        Widget? child;
        if (state is FolderListingError) {
          child = Center(child: Text(state.message));
        }

        if (state is FolderListingLoading) {
          child = const SizedBox();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(context.loc.screensFoldersTitle),
            leading: GJAppBarMenuButton(),
          ),
          body: child,
          drawer: AppDrawer(),
          floatingActionButton: CreateFolderButton(),
        );
      },
      listener: (context, state) {
        if (state is FolderListingLoaded) {
          var errMessage = state.errorMessage;
          if (errMessage != null) {
            showErrorSnackbar(context, errMessage);
          }
        }
      },
    );

    return BlocProvider(
      create: (context) {
        var repo = context.read<GitJournalRepo>();
        return FolderListingBloc(repo)..add(FolderListingStarted());
      },
      child: view,
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

        var bloc = context.read<FolderListingBloc>();
        bloc.add(FolderListingFolderCreated(folderName));
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
              labelText: context.loc.screensFoldersActionsDecoration,
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return context.loc.screensFoldersActionsEmpty;
              }
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
      title: Text(context.loc.screensFoldersDialogTitle),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            context.loc.screensFoldersDialogDiscard,
          ),
        ),
        TextButton(
          onPressed: () {
            var newFolderName = _textController.text;
            return Navigator.of(context).pop(newFolderName);
          },
          child: Text(context.loc.screensFoldersDialogCreate),
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
      title: Text(context.loc.screensFoldersErrorDialogTitle),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          child: Text(context.loc.screensFoldersErrorDialogOk),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class DeleteFolderErrorDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var text = context.loc.screensFoldersErrorDialogDeleteContent;
    return FolderErrorDialog(text);
  }
}
