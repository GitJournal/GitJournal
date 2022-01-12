/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:markdown/markdown.dart' as md;
import 'package:test/test.dart';

import 'package:gitjournal/markdown/parsers/katex.dart';

void main() {
  test('Inline', () async {
    var body = r"""# Hi
$\\sqrt{3x-1}+(1+x)^2$""";

    var expectedHtml = r"""<h1>Hi</h1>
<p><katex>\\sqrt{3x-1}+(1+x)^2</katex></p>""";

    expect(_convert(body), expectedHtml);
  });

  test('Inline Empty', () async {
    var body = r"""# Hi
$$""";

    var expectedHtml = r"""<h1>Hi</h1>
<p>$$</p>""";

    expect(_convert(body), expectedHtml);
  });

  test('Inline Edge case', () async {
    var body = r"Hi 200$ is not the same as 400$";
    var expectedHtml = r"<p>Hi 200$ is not the same as 400$</p>";

    expect(_convert(body), expectedHtml);
  });

  test('Block', () async {
    var body = r"""# Hi
$$\begin{array}{c}

\end{array}$$""";

    var expectedHtml = r"""<h1>Hi</h1><katex>\begin{array}{c}

\end{array}</katex>""";

    expect(_convert(body), expectedHtml);
  });
}

String _convert(String body) {
  var lines = body.split('\n');

  var doc = md.Document(
    encodeHtml: false,
    extensionSet: md.ExtensionSet(
      List<md.BlockSyntax>.unmodifiable(<md.BlockSyntax>[
        const KatexBlockSyntax(),
      ]),
      List<md.InlineSyntax>.unmodifiable(<md.InlineSyntax>[]),
    ),
    inlineSyntaxes: [KatexInlineSyntax()],
  );
  var nodes = doc.parseLines(lines);
  return md.renderToHtml(nodes);
}
