import 'package:flutter/material.dart';

import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/sorted_notes_folder.dart';
import 'package:gitjournal/core/sorting_mode.dart';
import 'package:gitjournal/screens/note_editor.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:gitjournal/widgets/app_bar_menu_button.dart';
import 'package:gitjournal/widgets/note_search_delegate.dart';
import 'package:gitjournal/widgets/sync_button.dart';
import 'package:gitjournal/folder_views/common.dart';

import 'package:provider/provider.dart';

class FolderView extends StatefulWidget {
  final NotesFolder notesFolder;

  FolderView({@required this.notesFolder});

  @override
  _FolderViewState createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  SortedNotesFolder sortedNotesFolder;
  FolderViewType _viewType;

  @override
  void initState() {
    super.initState();
    sortedNotesFolder = SortedNotesFolder(
      folder: widget.notesFolder,
      sortingMode: Settings.instance.sortingMode,
    );
    _viewType = FolderViewType.Standard;
  }

  @override
  Widget build(BuildContext context) {
    var container = Provider.of<StateContainer>(context);
    final appState = container.appState;

    var createButton = FloatingActionButton(
      key: const ValueKey("FAB"),
      onPressed: () => _newPost(context),
      child: Icon(Icons.add),
    );

    var title = widget.notesFolder.parent == null
        ? "Notes"
        : widget.notesFolder.pathSpec();

    var folderView = Builder(
      builder: (BuildContext context) {
        const emptyText = "Let's add some notes?";
        return buildFolderView(
          context,
          _viewType,
          sortedNotesFolder,
          emptyText,
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: GJAppBarMenuButton(),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.library_books),
            onPressed: _folderViewChooserSelected,
          ),
          if (appState.remoteGitRepoConfigured) SyncButton(),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NoteSearchDelegate(
                  sortedNotesFolder.notes,
                  _viewType,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _sortButtonPressed,
          ),
        ],
      ),
      floatingActionButton: createButton,
      body: Center(
        child: Builder(
          builder: (context) => RefreshIndicator(
            child: Scrollbar(child: folderView),
            onRefresh: () async => _syncRepo(context),
          ),
        ),
      ),
      drawer: AppDrawer(),
    );
  }

  void _syncRepo(BuildContext context) async {
    try {
      var container = Provider.of<StateContainer>(context, listen: false);
      await container.syncNotes();
    } catch (e) {
      showSnackbar(context, e.toString());
    }
  }

  void _newPost(BuildContext context) {
    var route = MaterialPageRoute(
        builder: (context) => NoteEditor.newNote(widget.notesFolder));
    Navigator.of(context).push(route);
  }

  void _sortButtonPressed() async {
    var newSortingMode = await showDialog<SortingMode>(
      context: context,
      builder: (BuildContext context) {
        var children = <Widget>[
          RadioListTile<SortingMode>(
            title: const Text("Last Modified"),
            value: SortingMode.Modified,
            groupValue: sortedNotesFolder.sortingMode,
            onChanged: (SortingMode sm) => Navigator.of(context).pop(sm),
          ),
          RadioListTile<SortingMode>(
            title: const Text("Created"),
            value: SortingMode.Created,
            groupValue: sortedNotesFolder.sortingMode,
            onChanged: (SortingMode sm) => Navigator.of(context).pop(sm),
          ),
        ];

        return AlertDialog(
          title: const Text("Sorting Criteria"),
          content: Column(
            children: children,
            mainAxisSize: MainAxisSize.min,
          ),
        );
      },
    );

    if (newSortingMode != null) {
      setState(() {
        sortedNotesFolder.changeSortingMode(newSortingMode);
        Settings.instance.sortingMode = newSortingMode;
        Settings.instance.save();
      });
    }
  }

  void _folderViewChooserSelected() async {
    var onViewChange = (FolderViewType vt) => Navigator.of(context).pop(vt);

    var newViewType = await showDialog<FolderViewType>(
      context: context,
      builder: (BuildContext context) {
        var children = <Widget>[
          RadioListTile<FolderViewType>(
            title: const Text("Standard View"),
            value: FolderViewType.Standard,
            groupValue: _viewType,
            onChanged: onViewChange,
          ),
          RadioListTile<FolderViewType>(
            title: const Text("Journal View"),
            value: FolderViewType.Journal,
            groupValue: _viewType,
            onChanged: onViewChange,
          ),
          RadioListTile<FolderViewType>(
            title: const Text("Compact View"),
            value: FolderViewType.Compact,
            groupValue: _viewType,
            onChanged: onViewChange,
          ),
        ];

        return AlertDialog(
          title: const Text("Select View"),
          content: Column(
            children: children,
            mainAxisSize: MainAxisSize.min,
          ),
        );
      },
    );

    if (newViewType != null) {
      setState(() {
        _viewType = newViewType;
      });
    }
  }
}
