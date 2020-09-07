import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  final String text;
  final String highlightText;
  final String highlightTextLowerCase;

  final TextStyle style;
  final TextOverflow overflow;
  final int maxLines;

  HighlightedText({
    @required this.text,
    @required this.highlightText,
    @required this.highlightTextLowerCase,
    @required this.style,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    if (highlightText.isEmpty) {
      return Text(text, maxLines: maxLines, overflow: overflow, style: style);
    }

    var i = text.toLowerCase().indexOf(highlightTextLowerCase);
    if (i == -1) {
      return Text(text, maxLines: maxLines, overflow: overflow, style: style);
    }

    var highlightStyle = style.copyWith(
      backgroundColor: Theme.of(context).highlightColor,
    );

    var before = text.substring(0, i);
    var term = text.substring(i, i + highlightText.length);
    var after = text.substring(i + highlightText.length);

    return RichText(
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
