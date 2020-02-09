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

class JournalListingScreen extends StatelessWidget {
  final NotesFolder notesFolder;

  JournalListingScreen({@required this.notesFolder});

  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    final appState = container.appState;

    var createButton = FloatingActionButton(
      key: const ValueKey("FAB"),
      onPressed: () => _newPost(context),
      child: Icon(Icons.add),
    );

    var title = notesFolder.parent == null ? "Notes" : notesFolder.pathSpec();

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
                delegate: NoteSearchDelegate(notesFolder.notes),
              );
            },
          ),
        ],
      ),
      floatingActionButton: createButton,
      body: Center(
        child: Builder(
          builder: (context) => RefreshIndicator(
            child: Scrollbar(child: buildJournalList(notesFolder)),
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
        builder: (context) => NoteEditor.newNote(notesFolder));
    Navigator.of(context).push(route);
  }

  Widget buildJournalList(NotesFolder folder) {
    return Builder(
      builder: (context) {
        return JournalList(
          folder: SortedNotesFolder(folder),
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
}
