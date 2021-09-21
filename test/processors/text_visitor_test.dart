/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';

import 'package:function_types/function_types.dart' as fn;
import 'package:markdown/markdown.dart' as md;
import 'package:test/test.dart';

import 'package:gitjournal/core/processors/text_visitor.dart';

void main() {
  void _visit(String body, fn.Func1<String, void> textCallback) {
    final doc = md.Document(
      encodeHtml: false,
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );

    var lines = LineSplitter.split(body).toList();
    var nodes = doc.parseLines(lines);

    TextVisitor(textCallback).visit(nodes);
  }

  test('Simple Test', () {
    var body = "Hello *Hi* **How**";

    var result = "";
    void callback(String content) {
      result += content + "-";
    }

    _visit(body, callback);
    expect(result, "Hello -Hi- -How-");
  });

  test('Inline code block', () {
    var body = "Hello`foo`";

    var result = "";
    void callback(String content) {
      result += content + "-";
    }

    _visit(body, callback);
    expect(result, "Hello-");
  });

  test('Big code block', () {
    var body = """Hi
```
foo
```
Done
""";

    var result = "";
    void callback(String content) {
      result += content + "-";
    }

    _visit(body, callback);
    expect(result, "Hi-Done-");
  });
}
