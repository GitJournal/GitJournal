import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:journal/apis/git.dart';
import 'package:journal/note_editor.dart';
import 'package:journal/note_viewer.dart';
import 'package:journal/state_container.dart';
import 'package:journal/widgets/app_drawer.dart';
import 'package:journal/widgets/journal_list.dart';

class HomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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

    var appBarMenuButton = BadgeIconButton(
      icon: const Icon(Icons.menu),
      itemCount: appState.remoteGitRepoConfigured ? 0 : 1,
      onPressed: () {
        _scaffoldKey.currentState.openDrawer();
      },
    );

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('GitJournal'),
        leading: appBarMenuButton,
      ),
      floatingActionButton: createButton,
      body: Center(
        child: RefreshIndicator(
            child: journalList,
            onRefresh: () async {
              try {
                await container.syncNotes();
              } on GitException catch (exp) {
                _scaffoldKey.currentState
                  ..removeCurrentSnackBar()
                  ..showSnackBar(new SnackBar(content: new Text(exp.cause)));
              }
            }),
      ),
      drawer: new AppDrawer(),
    );
  }

  void _newPost(BuildContext context) {
    var route = new MaterialPageRoute(builder: (context) => new NoteEditor());
    Navigator.of(context).push(route);
  }
}
