/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/folder_views/card_view.dart';

class GridFolderView extends StatelessWidget {
  final NoteSelectedFunction noteTapped;
  final NoteSelectedFunction noteLongPressed;
  final NoteBoolPropertyFunction isNoteSelected;

  final NotesFolder folder;
  final String? emptyText;

  final String searchTerm;

  const GridFolderView({
    required this.folder,
    required this.noteTapped,
    required this.noteLongPressed,
    required this.isNoteSelected,
    required this.emptyText,
    required this.searchTerm,
  });

  @override
  Widget build(BuildContext context) {
    return CardView(
      folder: folder,
      noteTapped: noteTapped,
      noteLongPressed: noteLongPressed,
      emptyText: emptyText,
      fixedHeight: true,
      isNoteSelected: isNoteSelected,
      searchTerm: searchTerm,
    );
  }
}
