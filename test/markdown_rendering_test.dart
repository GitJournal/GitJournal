/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:markdown/markdown.dart' as md;
import 'package:test/test.dart';

import 'package:gitjournal/widgets/markdown_renderer.dart';

void main() {
  test('Parses Wiki Lnks and task items', () {
    var body = "[[GitJournal]] should match.\n- [ ] task item";
    var lines = body.split('\n');

    var doc = md.Document(
      encodeHtml: false,
      extensionSet: MarkdownRenderer.markdownExtensions(),
      inlineSyntaxes: MarkdownRenderer.markdownExtensions().inlineSyntaxes,
    );
    var nodes = doc.parseLines(lines);

    var expected =
        """<p><a type="wiki" href="[[GitJournal]]" term="GitJournal">GitJournal</a> should match.</p>
<ul>
<li><input type="checkbox" disabled="true" checked="false"></input>task item</li>
</ul>""";

    expect(md.renderToHtml(nodes), expected);
  });

  test('Parses Piped Wiki Lnks', () {
    var body = "[[GitJournal | fire]] should match.";
    var lines = body.split('\n');

    var doc = md.Document(
      encodeHtml: false,
      extensionSet: MarkdownRenderer.markdownExtensions(),
      inlineSyntaxes: MarkdownRenderer.markdownExtensions().inlineSyntaxes,
    );
    var nodes = doc.parseLines(lines);

    var expected =
        '<p><a type="wiki" href="[[GitJournal]]" term="GitJournal">fire</a> should match.</p>';

    expect(md.renderToHtml(nodes), expected);
  });
}
