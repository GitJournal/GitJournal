import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/utils/markdown.dart';

typedef void NoteSelectedFunction(Note note);

class NoteTile extends StatelessWidget {
  final Note note;
  final NoteSelectedFunction noteTapped;
  final NoteSelectedFunction noteLongPressed;

  NoteTile({
    @required this.note,
    @required this.noteTapped,
    @required this.noteLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    var buffer = StringBuffer();
    var i = 0;
    for (var line in LineSplitter.split(note.body)) {
      line = replaceMarkdownChars(line);
      buffer.writeln(line);

      i += 1;
      if (i == 12) {
        break;
      }
    }
    var body = buffer.toString().trimRight();

    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    var borderColor = theme.highlightColor.withAlpha(100);
    if (theme.brightness == Brightness.dark) {
      borderColor = theme.highlightColor.withAlpha(30);
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
              style: textTheme.headline6
                  .copyWith(fontSize: textTheme.headline6.fontSize * 0.80),
            ),
          if (note.title != null && note.title.isNotEmpty)
            const SizedBox(height: 8.0),
          Flexible(
            flex: 1,
            child: Text(
              body,
              maxLines: 11,
              overflow: TextOverflow.ellipsis,
              style: textTheme.subtitle1
                  .copyWith(fontSize: textTheme.subtitle1.fontSize * 0.90),
            ),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
      ),
    );

    const borderRadius = BorderRadius.all(Radius.circular(8));
    return Material(
      borderRadius: borderRadius,
      type: MaterialType.card,
      child: InkWell(
        child: tileContent,
        borderRadius: borderRadius,
        onTap: () => noteTapped(note),
        onLongPress: () => noteLongPressed(note),
      ),
    );
  }
}
