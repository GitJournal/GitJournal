/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:gitjournal/editors/controllers/highlighting_text_controller.dart';

void main() {
  test('Simple', () {
    var con = HighlightingTextController(
      highlightText: "wor",
      currentPos: 0,
      highlightBackgroundColor: Colors.green,
      highlightCurrentBackgroundColor: Colors.green,
    );

    var ret = con.highlight(
      input: const TextSpan(text: "Hello world"),
      style: const TextStyle(),
      withComposing: true,
    );

    expect(ret.text, null);
    expect(ret.children!.length, 3);

    var c = ret.children!;
    expect(c[0] is TextSpan, true);
    expect(c[1] is TextSpan, true);
    expect(c[2] is TextSpan, true);

    expect((c[0] as TextSpan).text, "Hello ");
    expect((c[1] as TextSpan).text, "wor");
    expect((c[2] as TextSpan).text, "ld");

    expect((c[1] as TextSpan).style!.backgroundColor, Colors.green);
  });
}

// Add test about non-matching
// Add test across adjacent TextSpans
// Add test for case
