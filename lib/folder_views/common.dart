/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/app_router.dart';
import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes/note.dart';
import 'package:gitjournal/editors/note_editor.dart';
import 'package:gitjournal/folder_views/card_view.dart';
import 'package:gitjournal/folder_views/grid_view.dart';
import 'package:gitjournal/folder_views/journal_view.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/utils/utils.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import 'common_types.dart';
import 'standard_view.dart';

export 'common_types.dart';

Widget buildFolderView({
  required FolderViewType viewType,
  required NotesFolder folder,
  required String? emptyText,
  required StandardViewHeader header,
  required bool showSummary,
  required NoteSelectedFunction noteTapped,
  required NoteSelectedFunction noteLongPressed,
  required NoteBoolPropertyFunction isNoteSelected,
  String searchTerm = "",
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

Future<void> openNoteEditor(
  BuildContext context,
  Note note,
  NotesFolder parentFolder, {
  bool editMode = false,
  String? highlightString,
}) async {
  var route = MaterialPageRoute(
    builder: (context) => NoteEditor.fromNote(
      note,
      parentFolder,
      editMode: editMode,
      highlightString: highlightString,
    ),
    settings: const RouteSettings(name: '/note/'),
  );
  var showUndoSnackBar = await Navigator.of(context).push(route);
  if (showUndoSnackBar != null) {
    Log.d("Showing an undo snackbar");

    var repo = context.read<GitJournalRepo>();
    var snackBar = buildUndoDeleteSnackbar(context, repo, note);
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

bool openNewNoteEditor(BuildContext context, String noteSpec) {
  var rootFolder = context.read<NotesFolderFS>();
  var parentFolder = rootFolder;
  var folderConfig = context.read<NotesFolderConfig>();
  var defaultEditor = folderConfig.defaultEditor.toEditorType();

  var fileName = noteSpec;
  if (fileName.contains(p.separator)) {
    var pFolder = rootFolder.getFolderWithSpec(p.dirname(fileName));
    if (pFolder == null) {
      return false;
    }
    parentFolder = pFolder;
    Log.i("New Note Parent Folder: ${parentFolder.folderPath}");

    fileName = p.basename(noteSpec);
  }

  var route = newNoteRoute(
    NoteEditor.newNote(
      parentFolder,
      parentFolder,
      defaultEditor,
      newNoteFileName: fileName,
      existingText: "",
      existingImages: const [],
    ),
    AppRoute.NewNotePrefix + folderConfig.defaultEditor.toInternalString(),
  );

  Navigator.push(context, route);
  return true;
}

PageRouteBuilder newNoteRoute(NoteEditor editor, String name) {
  return PageRouteBuilder(
    pageBuilder: (context, _, __) => editor,
    settings: RouteSettings(name: name),
    transitionsBuilder: (_, anim, __, child) {
      return FadeTransition(opacity: anim, child: child);
    },
  );
}
