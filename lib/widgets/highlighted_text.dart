/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  final String text;
  final String highlightText;
  final String highlightTextLowerCase;

  final TextStyle style;
  final TextStyle? highlightStyle;
  final TextOverflow? overflow;
  final int? maxLines;

  const HighlightedText({
    Key? key,
    required this.text,
    required this.highlightText,
    required this.highlightTextLowerCase,
    required this.style,
    this.highlightStyle,
    this.overflow,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (highlightText.isEmpty) {
      return Text(text, maxLines: maxLines, overflow: overflow, style: style);
    }

    var i = text.toLowerCase().indexOf(highlightTextLowerCase);
    if (i == -1) {
      return Text(text, maxLines: maxLines, overflow: overflow, style: style);
    }

    var highlightStyle = this.highlightStyle ??
        style.copyWith(
          backgroundColor: Theme.of(context).textSelectionTheme.selectionColor,
        );

    var before = text.substring(0, i);
    var term = text.substring(i, i + highlightText.length);
    var after = text.substring(i + highlightText.length);

    return RichText(
      maxLines: maxLines,
      text: TextSpan(
        children: [
          TextSpan(text: before, style: style),
          TextSpan(text: term, style: highlightStyle),
          TextSpan(text: after, style: style),
        ],
      ),
    );
  }
}

class HighlightTextSpan {
  final String text;
  final String highlightText;
  final String highlightTextLowerCase;

  final TextStyle style;
  TextStyle? highlightStyle;

  HighlightTextSpan({
    required this.text,
    required this.highlightText,
    required this.highlightTextLowerCase,
    required this.style,
    required this.highlightStyle,
  });

  List<InlineSpan> build(BuildContext context) {
    var i = text.toLowerCase().indexOf(highlightTextLowerCase);
    if (i == -1) {
      return [];
    }

    var highlightStyle = this.highlightStyle ??
        style.copyWith(
          backgroundColor: Theme.of(context).highlightColor,
        );

    var before = text.substring(0, i);
    var term = text.substring(i, i + highlightText.length);
    var after = text.substring(i + highlightText.length);

    return [
      TextSpan(text: before, style: style),
      TextSpan(text: term, style: highlightStyle),
      TextSpan(text: after, style: style),
    ];
  }
}
