/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

class HighlightingTextController {
  final String highlightText;
  final int currentPos;
  final Color highlightBackgroundColor;
  final Color highlightCurrentBackgroundColor;

  HighlightingTextController({
    required this.highlightText,
    required this.currentPos,
    required this.highlightBackgroundColor,
    required this.highlightCurrentBackgroundColor,
  });

  TextSpan highlight({
    required TextSpan input,
    // required BuildContext context,
    required TextStyle? style,
    required bool withComposing,
  }) {
    if (input.text != null) {
      var text = input.text!;

      var regexp = RegExp(RegExp.escape(highlightText), caseSensitive: false);
      var children = <TextSpan>[];

      var index = 0;
      var _ = text.splitMapJoin(
        regexp,
        onMatch: (Match m) {
          var backgroundColor = index != currentPos
              ? highlightBackgroundColor
              : highlightCurrentBackgroundColor;

          children.add(TextSpan(
            text: m[0],
            style: style?.copyWith(backgroundColor: backgroundColor),
          ));
          index++;
          return "";
        },
        onNonMatch: (String span) {
          children.add(TextSpan(text: span, style: style));
          return "";
        },
      );

      if (children.length == 1) {
        return children[0];
      }

      return TextSpan(children: children);
    }

    return input;
  }
}
