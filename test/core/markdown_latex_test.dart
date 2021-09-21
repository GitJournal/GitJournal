/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:markdown/markdown.dart' as md;
import 'package:test/test.dart';

import 'package:gitjournal/markdown/markdown_latex.dart';

void main() {
  test('Should parse both', () async {
    var body = """# Hi
\\[ x = {-b pm sqrt{b^2-4ac} over 2a} \\]""";

    var lines = body.split('\n');

    var doc = md.Document(
      encodeHtml: false,
      extensionSet: md.ExtensionSet.gitHubFlavored,
      inlineSyntaxes: [MathJaxInlineSyntax()],
    );
    var nodes = doc.parseLines(lines);
    var html = md.renderToHtml(nodes);

    var expectedHtml =
        """<p><a type="wiki" href="[[GitJournal]]" term="GitJournal">GitJournal</a> should match.</p>
<ul>
<li><input type="checkbox" disabled="true" checked="false"></input>task item</li>
</ul>""";

    expect(html, expectedHtml);
  }, skip: true);
}
