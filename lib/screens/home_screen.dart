import 'package:flutter/material.dart';

import 'package:journal/state_container.dart';
import 'package:journal/widgets/app_drawer.dart';
import 'package:journal/widgets/journal_list.dart';
import 'package:journal/note_editor.dart';
import 'package:journal/note_viewer.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    final appState = container.appState;

    var createButton = new FloatingActionButton(
      onPressed: () => _newPost(context),
      child: new Icon(Icons.add),
    );

    var journalList = JournalList(
      notes: appState.notes,
      noteSelectedFunction: (noteIndex) {
        var route = new MaterialPageRoute(
          builder: (context) => new NoteBrowsingScreen(
                notes: appState.notes,
                noteIndex: noteIndex,
              ),
        );
        Navigator.of(context).push(route);
      },
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('GitJournal'),
      ),
      floatingActionButton: createButton,
      body: Center(
        child: RefreshIndicator(
          child: journalList,
          onRefresh: container.syncNotes,
        ),
      ),
      drawer: new AppDrawer(),
    );
  }

  void _newPost(BuildContext context) {
    var route = new MaterialPageRoute(builder: (context) => new NoteEditor());
    Navigator.of(context).push(route);
  }
}
