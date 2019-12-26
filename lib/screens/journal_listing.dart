import 'package:flutter/material.dart';
import 'package:git_bindings/git_bindings.dart';
import 'package:gitjournal/appstate.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/screens/journal_editor.dart';
import 'package:gitjournal/screens/journal_browsing.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:gitjournal/widgets/app_bar_menu_button.dart';
import 'package:gitjournal/widgets/journal_list.dart';
import 'package:gitjournal/themes.dart';

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
        var route = MaterialPageRoute(
          builder: (context) => JournalBrowsingScreen(
            notes: allNotes,
            noteIndex: noteIndex,
          ),
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
                delegate: NoteSearch(allNotes),
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
    try {
      await container.syncNotes();
    } on GitException catch (exp) {
      showSnackbar(context, exp.cause);
    }
  }

  void _newPost(BuildContext context) {
    var route = MaterialPageRoute(
        builder: (context) => JournalEditor.newNote(notesFolder));
    Navigator.of(context).push(route);
  }
}

class NoteSearch extends SearchDelegate<Note> {
  final List<Note> notes;

  NoteSearch(this.notes);

  // Workaround because of https://github.com/flutter/flutter/issues/32180
  @override
  ThemeData appBarTheme(BuildContext context) {
    var theme = Theme.of(context);
    if (theme.brightness == Brightness.light) {
      return theme;
    }

    return theme.copyWith(
      primaryColor: Themes.dark.primaryColor,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildJournalList(context, query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildJournalList(context, query);
  }

  JournalList buildJournalList(BuildContext context, String query) {
    // TODO: This should be made far more efficient
    var q = query.toLowerCase();
    var filteredNotes = notes.where((note) {
      return note.body.toLowerCase().contains(q);
    }).toList();

    Widget journalList = JournalList(
      notes: filteredNotes,
      noteSelectedFunction: (noteIndex) {
        var route = MaterialPageRoute(
          builder: (context) => JournalBrowsingScreen(
            notes: filteredNotes,
            noteIndex: noteIndex,
          ),
        );
        Navigator.of(context).push(route);
      },
      emptyText: "No Search Results Found",
    );
    return journalList;
  }
}

class SyncButton extends StatefulWidget {
  @override
  _SyncButtonState createState() => _SyncButtonState();
}

class _SyncButtonState extends State<SyncButton> {
  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    final appState = container.appState;

    if (appState.syncStatus == SyncStatus.Loading) {
      return RotatingIcon();
    }
    return IconButton(
      icon: Icon(_syncStatusIcon()),
      onPressed: () async {
        _syncRepo();
      },
    );
  }

  void _syncRepo() async {
    final container = StateContainer.of(context);
    try {
      await container.syncNotes();
    } on GitException catch (exp) {
      showSnackbar(context, exp.cause);
    }
  }

  IconData _syncStatusIcon() {
    final container = StateContainer.of(context);
    final appState = container.appState;
    switch (appState.syncStatus) {
      case SyncStatus.Error:
        return Icons.cloud_off;

      case SyncStatus.Unknown:
      case SyncStatus.Done:
      default:
        return Icons.cloud_done;
    }
  }
}

class RotatingIcon extends StatefulWidget {
  @override
  _RotatingIconState createState() => _RotatingIconState();
}

class _RotatingIconState extends State<RotatingIcon>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var button = IconButton(
      icon: const Icon(Icons.loop),
      onPressed: () {},
    );

    return RotationTransition(
      child: button,
      turns: _animation,
    );
  }
}
