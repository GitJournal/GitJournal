import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/folder_views/card_view.dart';

class GridFolderView extends StatelessWidget {
  final NoteSelectedFunction noteTapped;
  final NoteSelectedFunction noteLongPressed;
  final NoteBoolPropertyFunction isNoteSelected;

  final NotesFolder folder;
  final String emptyText;

  final String searchTerm;

  GridFolderView({
    @required this.folder,
    @required this.noteTapped,
    @required this.noteLongPressed,
    @required this.isNoteSelected,
    @required this.emptyText,
    @required this.searchTerm,
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
