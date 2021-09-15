/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

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

TextEditingController buildController({
  required String text,
  required String? highlightText,
  required ThemeData theme,
}) {
  if (highlightText != null) {
    return RichTextController(
      text: text,
      highlightText: highlightText,
      highlightColor: theme.textSelectionTheme.selectionColor!,
    );
  } else {
    return TextEditingController(text: text);
  }
}
