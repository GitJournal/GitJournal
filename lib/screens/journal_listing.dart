import 'package:flutter/material.dart';
import 'package:fimber/fimber.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/sorted_notes_folder.dart';
import 'package:gitjournal/screens/note_editor.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:gitjournal/widgets/app_bar_menu_button.dart';
import 'package:gitjournal/widgets/journal_list.dart';
import 'package:gitjournal/widgets/note_search_delegate.dart';
import 'package:gitjournal/widgets/sync_button.dart';

class JournalListingScreen extends StatefulWidget {
  final NotesFolder notesFolder;

  JournalListingScreen({@required this.notesFolder});

  @override
  _JournalListingScreenState createState() => _JournalListingScreenState();
}

class _JournalListingScreenState extends State<JournalListingScreen> {
  SortedNotesFolder sortedNotesFolder;

  @override
  void initState() {
    super.initState();
    sortedNotesFolder = SortedNotesFolder(
      folder: widget.notesFolder,
      sortingMode: SortingMode.Modified,
    );
  }

  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    final appState = container.appState;

    var createButton = FloatingActionButton(
      key: const ValueKey("FAB"),
      onPressed: () => _newPost(context),
      child: Icon(Icons.add),
    );

    var title = widget.notesFolder.parent == null
        ? "Notes"
        : widget.notesFolder.pathSpec();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: GJAppBarMenuButton(),
        actions: <Widget>[
          if (appState.remoteGitRepoConfigured) SyncButton(),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NoteSearchDelegate(sortedNotesFolder.notes),
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
            child: Scrollbar(child: buildJournalList(sortedNotesFolder)),
            onRefresh: () async => _syncRepo(context),
          ),
        ),
      ),
      drawer: AppDrawer(),
    );
  }

  void _syncRepo(BuildContext context) async {
    try {
      final container = StateContainer.of(context);
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

  Widget buildJournalList(NotesFolderReadOnly folder) {
    return Builder(
      builder: (context) {
        return JournalList(
          folder: folder,
          noteSelectedFunction: (Note note) async {
            var route = MaterialPageRoute(
              builder: (context) => NoteEditor.fromNote(note),
            );
            var showUndoSnackBar = await Navigator.of(context).push(route);
            if (showUndoSnackBar != null) {
              Fimber.d("Showing an undo snackbar");

              var snackBar = buildUndoDeleteSnackbar(context, note);
              Scaffold.of(context).showSnackBar(snackBar);
            }
          },
          emptyText: "Let's add some notes?",
        );
      },
    );
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

    setState(() {
      sortedNotesFolder.changeSortingMode(newSortingMode);
    });
  }
}
