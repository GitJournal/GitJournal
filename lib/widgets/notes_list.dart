import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/utils/markdown.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

typedef void NoteSelectedFunction(int noteIndex);

class NotesList extends StatelessWidget {
  final NoteSelectedFunction noteSelectedFunction;
  final List<Note> notes;
  final String emptyText;

  NotesList({
    @required this.notes,
    @required this.noteSelectedFunction,
    @required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
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
      itemCount: notes.length,
      itemBuilder: (BuildContext context, int index) {
        var note = notes[index];
        return _buildNoteCard(context, note, index);
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

  Widget _buildNoteCard(BuildContext context, Note journal, int noteIndex) {
    var body = stripMarkdownFormatting(journal.body);

    var textTheme = Theme.of(context).textTheme;
    var tileContent = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        body,
        maxLines: 30,
        overflow: TextOverflow.ellipsis,
        style: textTheme.body1,
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
      //onTap: () => noteSelectedFunction(noteIndex),
    );
  }
}
