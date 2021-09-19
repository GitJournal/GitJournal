/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:test/test.dart';

import 'package:gitjournal/markdown/markdown_codec.dart';

void main() {
  test('Should encode and decode', () {
    var lines = File('test/testdata/example.md').readAsLinesSync();

    final doc = md.Document(encodeHtml: false);
    var nodes = doc.parseLines(lines);

    var output = MarkdownCodec.encode(nodes);
    var input = MarkdownCodec.decode(output);
    expect(md.renderToHtml(input), md.renderToHtml(nodes));

    var output2 = MarkdownCodec.encode(input);
    var eq = const ListEquality().equals;

    expect(eq(output, output2), true);
  }, skip: true);
}
