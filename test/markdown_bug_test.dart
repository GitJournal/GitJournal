/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: MIT
 */

import 'package:markdown/markdown.dart' as md;
import 'package:test/test.dart';

/// Parse [[term]]
class _WikiLinkSyntax extends md.InlineSyntax {
  static const String _pattern = r'\[\[([^\[\]]+)\]\]';

  _WikiLinkSyntax() : super(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var term = match[1]!.trim();
    var displayText = term;
    if (term.contains('|')) {
      var s = term.split('|');
      term = s[0].trimRight();
      displayText = s[1].trimLeft();
    }

    var el = md.Element('a', [md.Text(displayText)]);
    el.attributes['type'] = 'wiki';
    el.attributes['href'] = '[[$term]]';
    el.attributes['term'] = term;

    parser.addNode(el);
    return true;
  }
}

/// Parse [task list items](https://github.github.com/gfm/#task-list-items-extension-).
class _TaskListSyntax extends md.InlineSyntax {
  // FIXME: Waiting for dart-lang/markdown#269 to land
  static const String _pattern = r'^ *\[([ xX])\] +';

  _TaskListSyntax() : super(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    md.Element el = md.Element.withTag('input');
    el.attributes['type'] = 'checkbox';
    el.attributes['disabled'] = 'true';
    el.attributes['checked'] = '${match[1]!.trim().isNotEmpty}';
    parser.addNode(el);
    return true;
  }
}

void main() {
  //
  // https://github.com/dart-lang/markdown/issues/293
  //
  test('Should parse both', () async {
    var body = "[[GitJournal]] should match.\n- [ ] task item";
    var lines = body.split('\n');

    var doc = md.Document(
      encodeHtml: false,
      extensionSet: md.ExtensionSet.gitHubFlavored,
      inlineSyntaxes: [_WikiLinkSyntax(), _TaskListSyntax()],
    );
    var nodes = doc.parseLines(lines);
    var html = md.renderToHtml(nodes);

    var expectedHtml =
        """<p><a type="wiki" href="[[GitJournal]]" term="GitJournal">GitJournal</a> should match.</p>
<ul>
<li><input type="checkbox" disabled="true" checked="false"></input>task item</li>
</ul>""";

    expect(html, expectedHtml);
  });
}
