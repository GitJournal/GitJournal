/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

/*

import 'package:test/test.dart';

void main() {
  test('Extract word at start', () {
    var result = extractToken("[[Hel", 5, '[[', ']]');
    expect(result, "Hel");
  });

  test('Extract word at start - cursor not at end', () {
    var result = extractToken("[[Hel", 4, '[[', ']]');
    expect(result, "Hel");
  }, solo: true);

  test('Extract second word', () {
    var result = extractToken("Hi [[Hel", 8, '[[', ']]');
    expect(result, "Hel");
  });

  test('Extract second word after newline', () {
    var result = extractToken("Hi\n[[Hel", 8, '[[', ']]');
    expect(result, "Hel");
  });

  test('Extract second word with more words', () {
    var result = extractToken("Hi [[Hel ]] Flower.", 8, '[[', ']]');
    expect(result, "Hel ");
  });

  test('Extract second word with more words after newline', () {
    var result = extractToken("Hi\n[[Hel]]\nFlower ", 8, '[[', ']]');
    expect(result, "Hel");
  });

  test('Extract word when cursor in the middle', () {
    var result = extractToken("Hi\n[[Hello]]", 8, '[[', ']]');
    expect(result, "Hello");
  });

  test('Extract word with spaces', () {
    var result = extractToken("Hi\n[[Hello There]]", 8, '[[', ']]');
    expect(result, "Hello There");
  });
}

*/
