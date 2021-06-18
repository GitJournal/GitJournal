/*
  MIT License

  Copyright (c) 2020  Vishesh Handa <me@vhanda.in>

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
*/

import 'package:markdown/markdown.dart' as md;
import 'package:test/test.dart';

/// Parse [[term]]
class _WikiLinkSyntax extends md.InlineSyntax {
  static final String _pattern = r'\[\[([^\[\]]+)\]\]';

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
  static final String _pattern = r'^ *\[([ xX])\] +';

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
