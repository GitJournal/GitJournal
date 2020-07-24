import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/folder_views/card_view.dart';
import 'package:gitjournal/folder_views/note_tile.dart';

class GridFolderView extends StatelessWidget {
  final NoteSelectedFunction noteSelectedFunction;
  final NotesFolder folder;
  final String emptyText;

  GridFolderView({
    @required this.folder,
    @required this.noteSelectedFunction,
    @required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    return CardView(
      folder: folder,
      noteSelectedFunction: noteSelectedFunction,
      emptyText: emptyText,
      fixedHeight: true,
    );
  }
}
