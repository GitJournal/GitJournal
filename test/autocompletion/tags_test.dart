/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:test/test.dart';

import 'package:gitjournal/editors/autocompletion_widget.dart';
import 'package:gitjournal/editors/common.dart';

void main() {
  var c = TagsAutoCompleter();

  test('Extract first word', () {
    var es = TextEditorState("#Hel", 3);
    var r = c.textChanged(es);
    expect(es.text.substring(r.start, r.end), "Hel");
  });

  test('Extract second word', () {
    var es = TextEditorState("Hi #Hel", 7);
    var r = c.textChanged(es);
    expect(es.text.substring(r.start, r.end), "Hel");
  });

  test('Extract second word - cursor not at end', () {
    var es = TextEditorState("Hi #Hell", 7);
    var r = c.textChanged(es);
    expect(es.text.substring(r.start, r.end), "Hell");
  });

  test("Second word with dot", () {
    var es = TextEditorState("Hi.#Hel", 6);
    var r = c.textChanged(es);
    expect(es.text.substring(r.start, r.end), "Hel");
  });

  test("Second word with newline", () {
    var es = TextEditorState("Hi\n#H", 5);
    var r = c.textChanged(es);
    expect(es.text.substring(r.start, r.end), "H");
  });

  test('Nothing to extract', () {
    var es = TextEditorState("#Hel hi ", 8);
    var r = c.textChanged(es);
    expect(r.isEmpty, true);
  });
}
