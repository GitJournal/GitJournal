/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:gitjournal/markdown/markdown_renderer.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:test/test.dart';

import '../lib.dart';

void main() {
  setUpAll(gjSetupAllTests);

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
<ul class="contains-task-list">
<li class="task-list-item"><input type="checkbox"></input>task item</li>
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
