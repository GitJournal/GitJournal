import 'package:flutter/material.dart';

import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/screens/note_editor.dart';
import 'package:gitjournal/state_container.dart';
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

    var allNotes = notesFolder.getNotes();
    allNotes.sort((a, b) => b.compareTo(a));

    Widget journalList = JournalList(
      notes: allNotes,
      noteSelectedFunction: (noteIndex) {
        var note = allNotes[noteIndex];
        var route = MaterialPageRoute(
          builder: (context) => NoteEditor.fromNote(note),
        );
        Navigator.of(context).push(route);
      },
      emptyText: "Let's add some notes?",
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
                delegate: NoteSearchDelegate(allNotes),
              );
            },
          ),
        ],
      ),
      floatingActionButton: createButton,
      body: Center(
        child: RefreshIndicator(
          child: Scrollbar(child: journalList),
          onRefresh: () async => _syncRepo(context),
        ),
      ),
      drawer: AppDrawer(),
    );
  }

  void _syncRepo(BuildContext context) async {
    final container = StateContainer.of(context);
    await container.syncNotes();
  }

  void _newPost(BuildContext context) {
    var route = MaterialPageRoute(
        builder: (context) => NoteEditor.newNote(notesFolder));
    Navigator.of(context).push(route);
  }
}
