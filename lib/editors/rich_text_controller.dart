/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

class RichTextController extends TextEditingController {
  final String highlightText;
  final int currentPos;
  final Color highlightBackgroundColor;
  final Color highlightCurrentBackgroundColor;

  RichTextController({
    required String text,
    required this.highlightText,
    required this.currentPos,
    required this.highlightBackgroundColor,
    required this.highlightCurrentBackgroundColor,
  }) : super(text: text);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
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

    return TextSpan(style: style, children: children);
  }
}

TextEditingController buildController({
  required String text,
  required String? highlightText,
  required ThemeData theme,
  int currentPos = -1,
}) {
  if (highlightText != null) {
    var color = theme.textSelectionTheme.selectionColor!;
    var currentColor = theme.brightness != Brightness.light
        ? color.lighten(0.2)
        : color.darken(0.2);

    return RichTextController(
      text: text,
      highlightText: highlightText,
      currentPos: currentPos,
      highlightBackgroundColor: color,
      highlightCurrentBackgroundColor: currentColor,
    );
  } else {
    return TextEditingController(text: text);
  }
}

extension ColorBrightness on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
