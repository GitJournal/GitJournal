/*
 * SPDX-FileCopyrightText: 2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/widgets.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tex_js/flutter_tex_js.dart';
import 'package:markdown/markdown.dart' as md;

import '../parsers/katex.dart';

class KatexBuilder extends MarkdownElementBuilder {
  static const tag = 'katex';
  static late final inlineParser = KatexInlineSyntax();
  static const blockParser = KatexBlockSyntax();

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? style) {
    var text = element.textContent;
    return TexImage(text, color: style?.color, fontSize: style?.fontSize);
  }
}
