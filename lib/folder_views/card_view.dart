import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gitjournal/core/note.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gitjournal/core/notes_folder.dart';

typedef void NoteSelectedFunction(Note note);

class CardView extends StatelessWidget {
  final NoteSelectedFunction noteSelectedFunction;
  final NotesFolderReadOnly folder;
  final String emptyText;

  CardView({
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

    var gridView = StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      itemCount: folder.notes.length,
      itemBuilder: (BuildContext context, int index) {
        var note = folder.notes[index];
        return _buildNoteCard(context, note);
      },
      staggeredTileBuilder: (int i) => const StaggeredTile.fit(2),
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: gridView,
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note) {
    var body = note.body;

    var textTheme = Theme.of(context).textTheme;
    var tileContent = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          if (note.title != null && note.title.isNotEmpty)
            Text(
              note.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.title,
            ),
          if (note.title != null && note.title.isNotEmpty)
            const SizedBox(height: 8.0),
          Text(
            body,
            maxLines: 30,
            overflow: TextOverflow.ellipsis,
            style: textTheme.body1,
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );

    const borderRadius = BorderRadius.all(Radius.circular(8));
    var tile = Material(
      borderRadius: borderRadius,
      type: MaterialType.card,
      child: tileContent,
    );

    /*var tile = Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]),
          color: Colors.white,
          borderRadius: borderRadius,
      child: tileContent,
    );*/

    return InkWell(
      child: tile,
      borderRadius: borderRadius,
      onTap: () => noteSelectedFunction(note),
    );
  }
}
