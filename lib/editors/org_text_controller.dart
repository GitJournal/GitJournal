/*
 * SPDX-FileCopyrightText: 22021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';

import 'package:flutter/material.dart';

class OrgTextController extends TextEditingController {
  final String? highlightText;
  final int currentPos;
  final Color highlightBackgroundColor;
  final Color highlightCurrentBackgroundColor;

  OrgTextController({
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
    if (highlightText != null) {
      var regexp = RegExp(RegExp.escape(highlightText!), caseSensitive: false);
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
          children.addAll(_parseOrgStyle(span, style!));
          return "";
        },
      );

      return TextSpan(style: style, children: children);
    }

    return TextSpan(style: style, children: _parseOrgStyle(text, style!));
  }

  final _boldRegExp = RegExp(r'(.*)(\*[^*\n]+\*)(.*)');

  List<TextSpan> _parseOrgStyle(String text, TextStyle style) {
    var lines = LineSplitter.split(text);
    var children = <TextSpan>[];

    bool firstLine = true;
    for (var line in lines) {
      var match = _boldRegExp.firstMatch(line);
      if (match != null) {
        var pre = match[1];
        var m = match[2];
        var post = match[3];

        // print('pre $pre');
        // print('m $m');
        // print('post $post');

        if (!firstLine) {
          pre = '\n$pre';
        } else {
          firstLine = false;
        }

        children.add(TextSpan(text: pre, style: style));
        children.add(
          TextSpan(
            text: m,
            style: style.copyWith(fontWeight: FontWeight.bold),
          ),
        );
        children.add(TextSpan(text: post, style: style));
      } else {
        if (!firstLine) {
          line = '\n$line';
        } else {
          firstLine = false;
        }
        children.add(TextSpan(text: line, style: style));
      }
    }

    return children;
  }
}

TextEditingController buildOrgTextController({
  required String text,
  required String? highlightText,
  required ThemeData theme,
  int currentPos = -1,
}) {
  var color = theme.textSelectionTheme.selectionColor!;
  var currentColor = theme.brightness != Brightness.light
      ? color.lighten(0.2)
      : color.darken(0.2);

  return OrgTextController(
    text: text,
    highlightText: highlightText,
    currentPos: currentPos,
    highlightBackgroundColor: color,
    highlightCurrentBackgroundColor: currentColor,
  );
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
