import 'package:flutter/material.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/folder_views/card_view.dart';
import 'package:gitjournal/folder_views/grid_view.dart';
import 'package:gitjournal/folder_views/journal_view.dart';
import 'package:gitjournal/screens/note_editor.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/utils/logger.dart';
import 'package:provider/provider.dart';

import 'standard_view.dart';

enum FolderViewType {
  Standard,
  Journal,
  Card,
  Grid,
}

Widget buildFolderView(
  BuildContext context,
  FolderViewType viewType,
  NotesFolder folder,
  String emptyText,
  StandardViewHeader header,
  bool showSummary,
) {
  var noteSelectionFn = (Note note) => openNoteEditor(context, note);

  switch (viewType) {
    case FolderViewType.Standard:
      return StandardView(
        folder: folder,
        noteSelectedFunction: noteSelectionFn,
        emptyText: emptyText,
        headerType: header,
        showSummary: showSummary,
      );
    case FolderViewType.Journal:
      return JournalView(
        folder: folder,
        noteSelectedFunction: noteSelectionFn,
        emptyText: emptyText,
      );
    case FolderViewType.Card:
      return CardView(
        folder: folder,
        noteSelectedFunction: noteSelectionFn,
        emptyText: emptyText,
      );
    case FolderViewType.Grid:
      return GridFolderView(
        folder: folder,
        noteSelectedFunction: noteSelectionFn,
        emptyText: emptyText,
      );
  }

  assert(false, "Code path should never be executed");
  return Container();
}

void openNoteEditor(BuildContext context, Note note) async {
  var route = MaterialPageRoute(
    builder: (context) => NoteEditor.fromNote(note),
    settings: const RouteSettings(name: '/note/'),
  );
  var showUndoSnackBar = await Navigator.of(context).push(route);
  if (showUndoSnackBar != null) {
    Log.d("Showing an undo snackbar");

    var stateContainer = Provider.of<StateContainer>(context, listen: false);
    var snackBar = buildUndoDeleteSnackbar(stateContainer, note);
    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
