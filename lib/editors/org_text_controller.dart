/*
 * SPDX-FileCopyrightText: 22021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:org_flutter/org_flutter.dart';

import 'package:gitjournal/features.dart';
import 'controllers/rich_text_controller.dart';

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

  List<TextSpan> _parseOrgStyle(String text, TextStyle style) {
    var lines = LineSplitter.split(text);
    var children = <TextSpan>[];

    bool firstLine = true;
    for (var line in lines) {
      if (line.isEmpty) {
        children.add(TextSpan(text: '\n', style: style));
        continue;
      }

      final parser = org;
      var parsed = parser.parse(line);
      var document = parsed.value as OrgDocument;
      if (document.content == null) {
        if (!firstLine) {
          line = '\n$line';
        } else {
          firstLine = false;
        }
        children.add(TextSpan(text: line, style: style));
        continue;
      }

      if (!firstLine) {
        children.add(TextSpan(text: '\n', style: style));
      } else {
        firstLine = false;
      }

      var _ = document.visit((p) {
        if (p is OrgMarkup) {
          var newStyle = style;
          if (p.style == OrgStyle.bold) {
            newStyle = style.copyWith(fontWeight: FontWeight.bold);
            children.add(TextSpan(text: '*${p.content}*', style: newStyle));
            return true;
          } else if (p.style == OrgStyle.italic) {
            newStyle = style.copyWith(fontStyle: FontStyle.italic);
            children.add(TextSpan(text: '/${p.content}/', style: newStyle));
            return true;
          } else if (p.style == OrgStyle.strikeThrough) {
            newStyle = style.copyWith(decoration: TextDecoration.lineThrough);
            children.add(TextSpan(text: '+${p.content}+', style: newStyle));
            return true;
          } else if (p.style == OrgStyle.underline) {
            newStyle = style.copyWith(decoration: TextDecoration.underline);
            children.add(TextSpan(text: '_${p.content}_', style: newStyle));
            return true;
          }

          children.add(TextSpan(text: p.content, style: style));
          return true;
        }
        if (p is OrgPlainText) {
          children.add(TextSpan(text: p.content, style: style));
          return true;
        }

        return true;
      });
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
  if (!Features.fancyOrgEditor) {
    return buildController(
      text: text,
      highlightText: highlightText,
      theme: theme,
    );
  }
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
