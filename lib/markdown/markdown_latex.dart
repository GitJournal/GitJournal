/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:markdown/markdown.dart';

// Surrounded by $
class KatexInlineSyntax extends InlineSyntax {
  static const String _pattern = r'\$([^$\n]+)\$';

  KatexInlineSyntax() : super(_pattern);

  @override
  bool onMatch(InlineParser parser, Match match) {
    var text = match[1]!.trim();
    if (text.isEmpty) {
      return false;
    }

    var el = Element.text('span', text);
    el.attributes['type'] = 'katex';

    parser.addNode(el);
    return true;
  }
}

// https://pub.dev/packages/flutter_tex_js

final _pattern = RegExp(r'^\$\$([\S\s]*[^$][^$])\$\$$', multiLine: true);

/// Parses Surrounded by $$
class KatexBlockSyntax extends BlockSyntax {
  @override
  RegExp get pattern => _pattern;

  const KatexBlockSyntax();

  @override
  bool canParse(BlockParser parser) {
    // print('canParse ${parser.current}');
    final match = pattern.firstMatch(parser.current);
    // print('match $match');
    if (match == null) return false;

    print(match[0]);
    return false;
    // final codeFence = match.group(1)!;
    // final infoString = match.group(2);

    // From the CommonMark spec:
    //
    // > If the info string comes after a backtick fence, it may not contain
    // > any backtick characters.
    // return (codeFence.codeUnitAt(0) != $backquote ||
    // !infoString!.codeUnits.contains($backquote));
  }

  @override
  List<String> parseChildLines(BlockParser parser, [String? endBlock]) {
    endBlock ??= '';

    var childLines = <String>[];
    parser.advance();

    while (!parser.isDone) {
      var match = pattern.firstMatch(parser.current);
      if (match == null || !match[1]!.startsWith(endBlock)) {
        childLines.add(parser.current);
        parser.advance();
      } else {
        parser.advance();
        break;
      }
    }

    return childLines;
  }

  @override
  Node parse(BlockParser parser) {
    // Get the syntax identifier, if there is one.
    var match = pattern.firstMatch(parser.current)!;
    var endBlock = match.group(1);
    var infoString = match.group(2)!;

    var childLines = parseChildLines(parser, endBlock);

    // The Markdown tests expect a trailing newline.
    childLines.add('');

    var text = childLines.join('\n');
    if (parser.document.encodeHtml) {
      // text = escapeHtml(text);
    }
    var code = Element.text('code', text);

    // the info-string should be trimmed
    // http://spec.commonmark.org/0.22/#example-100
    infoString = infoString.trim();
    if (infoString.isNotEmpty) {
      // only use the first word in the syntax
      // http://spec.commonmark.org/0.22/#example-100
      var firstSpace = infoString.indexOf(' ');
      if (firstSpace >= 0) {
        infoString = infoString.substring(0, firstSpace);
      }
      if (parser.document.encodeHtml) {
        // infoString = escapeHtmlAttribute(infoString);
      }
      code.attributes['class'] = 'language-$infoString';
    }

    var element = Element('pre', [code]);

    return element;
  }
}
