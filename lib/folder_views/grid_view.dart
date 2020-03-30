import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gitjournal/core/notes_folder.dart';
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

    var gridView = GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200.0,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 1 / 1.2,
      ),
      itemBuilder: _buildItem,
      itemCount: folder.notes.length,
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: gridView,
    );
  }

  Widget _buildItem(BuildContext context, int i) {
    // vHanda FIXME: Why does this method get called with i >= length ?
    if (i >= folder.notes.length) {
      return Container();
    }

    var note = folder.notes[i];
    return NoteTile(note, noteSelectedFunction);
  }
}
