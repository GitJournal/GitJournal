import 'package:flutter/material.dart';

class RichTextController extends TextEditingController {
  final String highlightText;
  final Color highlightColor;

  RichTextController({
    required String text,
    required this.highlightText,
    required this.highlightColor,
  }) : super(text: text);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    var regexp = RegExp(RegExp.escape(highlightText), caseSensitive: false);
    var children = <TextSpan>[];

    text.splitMapJoin(
      regexp,
      onMatch: (Match m) {
        children.add(TextSpan(
          text: m[0],
          style: style?.copyWith(color: highlightColor),
        ));
        return "";
      },
      onNonMatch: (String span) {
        children.add(TextSpan(text: span, style: style));
        return "";
      },
    );

    return TextSpan(style: style, children: children);
  }
}
