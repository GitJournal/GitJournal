import 'package:flutter/material.dart';
import 'package:gitjournal/core/note.dart';

typedef void NoteSelectedFunction(Note note);

class NoteTile extends StatelessWidget {
  final Note note;
  final NoteSelectedFunction noteSelectedFunction;

  NoteTile(this.note, this.noteSelectedFunction);

  @override
  Widget build(BuildContext context) {
    var body = note.body.trimRight();

    body = body.replaceAll('[ ]', '☐');
    body = body.replaceAll('[x]', '☑');
    body = body.replaceAll('[X]', '☑');

    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    var borderColor = theme.highlightColor.withAlpha(80);
    if (theme.brightness == Brightness.dark) {
      borderColor = theme.highlightColor.withAlpha(100);
    }

    var tileContent = Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          if (note.title != null && note.title.isNotEmpty)
            Text(
              note.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.title
                  .copyWith(fontSize: textTheme.title.fontSize * 0.80),
            ),
          if (note.title != null && note.title.isNotEmpty)
            const SizedBox(height: 8.0),
          Flexible(
            flex: 1,
            child: Text(
              body,
              maxLines: 30,
              overflow: TextOverflow.ellipsis,
              style: textTheme.subhead
                  .copyWith(fontSize: textTheme.subhead.fontSize * 0.90),
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
