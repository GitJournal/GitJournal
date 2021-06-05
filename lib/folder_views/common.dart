import 'package:flutter/material.dart';

import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/folder_views/card_view.dart';
import 'package:gitjournal/folder_views/grid_view.dart';
import 'package:gitjournal/folder_views/journal_view.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/screens/note_editor.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/utils/logger.dart';
import 'package:gitjournal/utils/utils.dart';
import 'common_types.dart';
import 'standard_view.dart';

export 'common_types.dart';

Widget buildFolderView({
  required FolderViewType viewType,
  required NotesFolder folder,
  required String emptyText,
  required StandardViewHeader header,
  required bool showSummary,
  required NoteSelectedFunction noteTapped,
  required NoteSelectedFunction noteLongPressed,
  required NoteBoolPropertyFunction isNoteSelected,
  required String searchTerm,
}) {
  switch (viewType) {
    case FolderViewType.Standard:
      return StandardView(
        folder: folder,
        noteTapped: noteTapped,
        noteLongPressed: noteLongPressed,
        emptyText: emptyText,
        headerType: header,
        showSummary: showSummary,
        isNoteSelected: isNoteSelected,
        searchTerm: searchTerm,
      );
    case FolderViewType.Journal:
      return JournalView(
        folder: folder,
        noteTapped: noteTapped,
        noteLongPressed: noteLongPressed,
        emptyText: emptyText,
        isNoteSelected: isNoteSelected,
        searchTerm: searchTerm,
      );
    case FolderViewType.Card:
      return CardView(
        folder: folder,
        noteTapped: noteTapped,
        noteLongPressed: noteLongPressed,
        emptyText: emptyText,
        isNoteSelected: isNoteSelected,
        searchTerm: searchTerm,
      );
    case FolderViewType.Grid:
      return GridFolderView(
        folder: folder,
        noteTapped: noteTapped,
        noteLongPressed: noteLongPressed,
        emptyText: emptyText,
        isNoteSelected: isNoteSelected,
        searchTerm: searchTerm,
      );
  }
}

void openNoteEditor(
  BuildContext context,
  Note note,
  NotesFolder parentFolder, {
  bool editMode = false,
}) async {
  var route = MaterialPageRoute(
    builder: (context) =>
        NoteEditor.fromNote(note, parentFolder, editMode: editMode),
    settings: const RouteSettings(name: '/note/'),
  );
  var showUndoSnackBar = await Navigator.of(context).push(route);
  if (showUndoSnackBar != null) {
    Log.d("Showing an undo snackbar");

    var stateContainer = context.read<GitJournalRepo>();
    var snackBar = buildUndoDeleteSnackbar(stateContainer, note);
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

bool openNewNoteEditor(BuildContext context, String term) {
  var rootFolder = Provider.of<NotesFolderFS>(context, listen: false);
  var parentFolder = rootFolder;
  var settings = Provider.of<Settings>(context, listen: false);
  var defaultEditor = settings.defaultEditor.toEditorType();

  var fileName = term;
  if (fileName.contains(p.separator)) {
    var pFolder = rootFolder.getFolderWithSpec(p.dirname(fileName));
    if (pFolder == null) {
      return false;
    }
    parentFolder = pFolder;
    Log.i("New Note Parent Folder: ${parentFolder.folderPath}");

    fileName = p.basename(term);
  }

  var route = MaterialPageRoute(
    builder: (context) => NoteEditor.newNote(
      parentFolder,
      parentFolder,
      defaultEditor,
      newNoteFileName: fileName,
      existingText: "",
      existingImages: [],
    ),
    settings: const RouteSettings(name: '/newNote/'),
  );
  Navigator.of(context).push(route);
  return true;
}
