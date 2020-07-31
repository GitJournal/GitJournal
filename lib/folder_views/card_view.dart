import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/folder_views/note_tile.dart';

class CardView extends StatelessWidget {
  final NoteSelectedFunction noteTapped;
  final NoteSelectedFunction noteLongPressed;
  final NotesFolder folder;
  final String emptyText;
  final bool fixedHeight;

  CardView({
    @required this.folder,
    @required this.noteTapped,
    @required this.noteLongPressed,
    @required this.emptyText,
    this.fixedHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    if (folder.isEmpty) {
      return Center(
        child: Text(
          emptyText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.w300,
            color: Colors.grey[350],
          ),
        ),
      );
    }

    StaggeredTile stagTile;
    if (fixedHeight) {
      stagTile = const StaggeredTile.extent(1, 200.0);
    } else {
      stagTile = const StaggeredTile.fit(1);
    }

    var gridView = StaggeredGridView.extentBuilder(
      itemCount: folder.notes.length,
      itemBuilder: (BuildContext context, int index) {
        var note = folder.notes[index];
        return NoteTile(
          note: note,
          noteTapped: noteTapped,
          noteLongPressed: noteLongPressed,
        );
      },
      maxCrossAxisExtent: 200.0,
      staggeredTileBuilder: (int i) => stagTile,
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
      padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0),
    );

    return gridView;
  }
}
