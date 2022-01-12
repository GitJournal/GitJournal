/*
 * SPDX-FileCopyrightText: 2019-2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:markdown/markdown.dart';

// Surrounded by $
class KatexInlineSyntax extends InlineSyntax {
  static const String _pattern = r'\$([^$\s][^$\n]*[^$\s])\$';

  KatexInlineSyntax() : super(_pattern);

  @override
  bool onMatch(InlineParser parser, Match match) {
    var text = match[1]!.trim();
    if (text.isEmpty) {
      return false;
    }

    var el = Element.text('katex', text);
    parser.addNode(el);
    return true;
  }
}

/// Parses Surrounded by $$
class KatexBlockSyntax extends BlockSyntax {
  @override
  RegExp get pattern => RegExp('');

  const KatexBlockSyntax();

  @override
  bool canParse(BlockParser parser) {
    var hasStartTag = parser.current.startsWith(r'$$');
    if (!hasStartTag) return false;

    var ahead = 1;
    while (true) {
      var line = parser.peek(ahead);
      if (line == null) return false;
      if (line.endsWith(r'$$')) return true;

      ahead++;
    }
  }

  @override
  Node? parse(BlockParser parser) {
    var lines = <String>[];
    if (parser.current.startsWith(r'$$')) {
      if (parser.current.length > 2) {
        lines.add(parser.current.substring(2));
      }
      parser.advance();

      while (!parser.isDone) {
        var line = parser.current;
        if (line.endsWith(r'$$')) {
          if (line.length > 2) {
            line = line.substring(0, line.length - 2);
          }

          lines.add(line);
          parser.advance();

          break;
        }

        lines.add(parser.current);
        parser.advance();
      }
    } else {
      return null;
    }

    var element = Element.text('katex', lines.join('\n'));
    return element;
  }

  @override
  bool canEndBlock(BlockParser parser) {
    return parser.current.endsWith(r'$$');
  }
}
