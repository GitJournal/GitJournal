/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/folder_views/empty_text_sliver.dart';
import 'package:gitjournal/folder_views/note_tile.dart';

class CardView extends StatelessWidget {
  final NoteSelectedFunction noteTapped;
  final NoteSelectedFunction noteLongPressed;
  final NoteBoolPropertyFunction isNoteSelected;

  final NotesFolder folder;
  final String? emptyText;
  final bool fixedHeight;

  final String searchTerm;

  const CardView({
    required this.folder,
    required this.noteTapped,
    required this.noteLongPressed,
    required this.isNoteSelected,
    required this.emptyText,
    required this.searchTerm,
    this.fixedHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    if (folder.isEmpty) {
      if (emptyText != null) {
        return EmptyTextSliver(emptyText: emptyText!);
      } else {
        return const SliverToBoxAdapter(child: SizedBox());
      }
    }

    StaggeredTile stagTile;
    if (fixedHeight) {
      stagTile = const StaggeredTile.extent(1, 200.0);
    } else {
      stagTile = const StaggeredTile.fit(1);
    }

    var gridView = SliverStaggeredGrid.extentBuilder(
      itemCount: folder.notes.length,
      itemBuilder: (BuildContext context, int index) {
        var note = folder.notes[index];
        return NoteTile(
          note: note,
          noteTapped: noteTapped,
          noteLongPressed: noteLongPressed,
          selected: isNoteSelected(note),
          searchTerm: searchTerm,
        );
      },
      maxCrossAxisExtent: 200.0,
      staggeredTileBuilder: (int i) => stagTile,
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
    );

    return SliverPadding(
      sliver: gridView,
      padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0 + 48.0),
    );
  }
}
