/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/utils/markdown.dart';
import 'package:gitjournal/widgets/highlighted_text.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  final NoteSelectedFunction noteTapped;
  final NoteSelectedFunction noteLongPressed;
  final bool selected;
  final String searchTerm;
  final String searchTermLowerCase;

  NoteTile({
    required this.note,
    required this.noteTapped,
    required this.noteLongPressed,
    required this.selected,
    required this.searchTerm,
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
      borderColor = theme.colorScheme.secondary;
    }

    var tileContent = Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: borderColor, width: selected ? 2.0 : 1.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          if (note.title.isNotEmpty)
            HighlightedText(
              text: note.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.headline6!
                  .copyWith(fontSize: textTheme.headline6!.fontSize! * 0.80),
              highlightText: searchTerm,
              highlightTextLowerCase: searchTermLowerCase,
            ),
          if (note.title.isNotEmpty) const SizedBox(height: 8.0),
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
        child: Hero(
          tag: note.filePath,
          child: tileContent,
          flightShuttleBuilder: (BuildContext flightContext,
                  Animation<double> animation,
                  HeroFlightDirection flightDirection,
                  BuildContext fromHeroContext,
                  BuildContext toHeroContext) =>
              Material(child: toHeroContext.widget),
        ),
        borderRadius: borderRadius,
        onTap: () => noteTapped(note),
        onLongPress: () => noteLongPressed(note),
      ),
    );
  }

  static const _maxLines = 12;

  // FIXME: vHanda: This doesn't need to be computed again and again!
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
    var textTheme = Theme.of(context).textTheme;

    return HighlightedText(
      text: text,
      highlightText: searchTerm,
      highlightTextLowerCase: searchTermLowerCase,
      style: textTheme.subtitle1!
          .copyWith(fontSize: textTheme.subtitle1!.fontSize! * 0.90),
      overflow: TextOverflow.ellipsis,
      maxLines: _maxLines - 1,
    );
  }
}
