import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/utils/markdown.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  final NoteSelectedFunction noteTapped;
  final NoteSelectedFunction noteLongPressed;
  final bool selected;
  final String searchTerm;
  final String searchTermLowerCase;

  NoteTile({
    @required this.note,
    @required this.noteTapped,
    @required this.noteLongPressed,
    @required this.selected,
    @required this.searchTerm,
  }) : searchTermLowerCase = searchTerm.toLowerCase();

  @override
  Widget build(BuildContext context) {
    var body = _displayText();

    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    var borderColor = theme.highlightColor.withAlpha(100);
    if (theme.brightness == Brightness.dark) {
      borderColor = theme.highlightColor.withAlpha(30);
    }

    if (selected) {
      borderColor = theme.accentColor;
    }

    var tileContent = Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: borderColor, width: selected ? 2.0 : 1.0),
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
            child: _buildBody(context, body),
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

  static const _maxLines = 12;

  String _displayText() {
    var foundSearchTerm = searchTerm.isEmpty ? true : false;
    var buffer = <String>[];
    var i = 0;

    for (var line in LineSplitter.split(note.body)) {
      line = replaceMarkdownChars(line);
      buffer.add(line);

      if (line.toLowerCase().contains(searchTermLowerCase)) {
        foundSearchTerm = true;
      }

      i += 1;
      if (i == _maxLines && foundSearchTerm) {
        break;
      }
    }

    if (buffer.length > _maxLines) {
      buffer = buffer.sublist(buffer.length - _maxLines);
    }

    return buffer.join("\n").trimRight();
  }

  Widget _buildBody(BuildContext context, String text) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    var style = textTheme.subtitle1
        .copyWith(fontSize: textTheme.subtitle1.fontSize * 0.90);

    if (searchTerm.isEmpty) {
      return Text(
        text,
        maxLines: _maxLines - 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    var i = text.toLowerCase().indexOf(searchTermLowerCase);
    if (i == -1) {
      return Text(
        text,
        maxLines: _maxLines - 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    var highlightStyle = textTheme.subtitle1.copyWith(
      fontSize: textTheme.subtitle1.fontSize * 0.90,
      backgroundColor: theme.highlightColor,
    );

    var before = text.substring(0, i);
    var after = text.substring(i + searchTerm.length);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: before, style: style),
          TextSpan(
            text: searchTerm,
            style: highlightStyle,
          ),
          TextSpan(text: after, style: style),
        ],
      ),
    );
  }
}
