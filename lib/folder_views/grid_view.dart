import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';

typedef void NoteSelectedFunction(Note note);

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
    return _buildNote(context, note);
  }

  Widget _buildNote(BuildContext context, Note note) {
    var body = note.body.trimRight();

    body = body.replaceAll('[ ]', '☐');
    body = body.replaceAll('[x]', '☑');
    body = body.replaceAll('[X]', '☑');

    var textTheme = Theme.of(context).textTheme;
    var tileContent = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          if (note.title != null && note.title.isNotEmpty)
            Text(
              note.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.title,
            ),
          if (note.title != null && note.title.isNotEmpty)
            const SizedBox(height: 8.0),
          Flexible(
            flex: 1,
            child: Text(
              body,
              maxLines: 30,
              overflow: TextOverflow.ellipsis,
              style: textTheme.subhead,
            ),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
      ),
    );

    const borderRadius = BorderRadius.all(Radius.circular(8));
    var tile = Material(
      borderRadius: borderRadius,
      type: MaterialType.card,
      child: Padding(padding: const EdgeInsets.all(4.0), child: tileContent),
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
