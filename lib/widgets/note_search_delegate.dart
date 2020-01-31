import 'package:flutter/material.dart';
import 'package:fimber/fimber.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/screens/note_editor.dart';
import 'package:gitjournal/themes.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/widgets/journal_list.dart';

class NoteSearchDelegate extends SearchDelegate<Note> {
  final List<Note> notes;

  NoteSearchDelegate(this.notes);

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
      icon: const Icon(Icons.arrow_back),
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
      noteSelectedFunction: (noteIndex) async {
        var note = filteredNotes[noteIndex];
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
      emptyText: "No Search Results Found",
    );
    return journalList;
  }
}
