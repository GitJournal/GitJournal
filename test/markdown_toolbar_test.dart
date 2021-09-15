/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:test/test.dart';

import 'package:gitjournal/editors/markdown_toolbar.dart';

void main() {
  void _testLine({
    required String before,
    required int beforeOffset,
    required String after,
    required int afterOffset,
    required String char,
  }) {
    var val = TextEditingValue(
      text: before,
      selection: TextSelection.collapsed(offset: beforeOffset),
    );

    var expectedVal = TextEditingValue(
      text: after,
      selection: TextSelection.collapsed(offset: afterOffset),
    );

    expect(modifyCurrentLine(val, char), expectedVal);
  }

  void _testH1({
    required String before,
    required int beforeOffset,
    required String after,
    required int afterOffset,
  }) {
    _testLine(
      before: before,
      beforeOffset: beforeOffset,
      after: after,
      afterOffset: afterOffset,
      char: '# ',
    );

    _testLine(
      before: after,
      beforeOffset: afterOffset,
      after: before,
      afterOffset: beforeOffset,
      char: '# ',
    );
  }

  test('Adds a header to the first line correctly', () {
    _testH1(
      before: 'Hello',
      beforeOffset: 5,
      after: '# Hello',
      afterOffset: 7,
    );
  });

  test('Adds a header to the last line correctly', () {
    _testH1(
      before: 'Hi\nHello',
      beforeOffset: 8,
      after: 'Hi\n# Hello',
      afterOffset: 10,
    );
  });

  test('Adds a header to a middle line correctly', () {
    _testH1(
      before: 'Hi\nHello\nFire',
      beforeOffset: 8,
      after: 'Hi\n# Hello\nFire',
      afterOffset: 10,
    );
  });

  test('Adds a header to a middle line middle word correctly', () {
    _testH1(
      before: 'Hi\nHello Darkness\nFire',
      beforeOffset: 8,
      after: 'Hi\n# Hello Darkness\nFire',
      afterOffset: 10,
    );
  });

  test('Removes header when cursor is at the start of the line', () {
    _testLine(
      before: 'Hi\n# Hello Darkness\nFire',
      beforeOffset: 3,
      after: 'Hi\nHello Darkness\nFire',
      afterOffset: 3,
      char: '# ',
    );
  });

  test("Removes header when cursor is in between '#' and ' '", () {
    _testLine(
      before: 'Hi\n# Hello Darkness\nFire',
      beforeOffset: 4,
      after: 'Hi\nHello Darkness\nFire',
      afterOffset: 3,
      char: '# ',
    );
  });

  test("Replaces h1 with h2", () {
    _testLine(
      before: 'Hi\n# Hello Darkness\nFire',
      beforeOffset: 4,
      after: 'Hi\n## Hello Darkness\nFire',
      afterOffset: 6,
      char: '## ',
    );
  });

  test("Replaces h2 with list", () {
    _testLine(
      before: 'Hi\n## Hello Darkness\nFire',
      beforeOffset: 5,
      after: 'Hi\n- Hello Darkness\nFire',
      afterOffset: 5,
      char: '- ',
    );
  });

  //
  // Word based
  //
  void _testWord({
    required String before,
    required int beforeOffset,
    required String after,
    required int afterOffset,
    required String char,
  }) {
    var val = TextEditingValue(
      text: before,
      selection: TextSelection.collapsed(offset: beforeOffset),
    );

    var expectedVal = TextEditingValue(
      text: after,
      selection: TextSelection.collapsed(offset: afterOffset),
    );

    expect(modifyCurrentWord(val, char), expectedVal);
  }

  test("Surrounds the first word", () {
    _testWord(
      before: 'Hello',
      beforeOffset: 3,
      after: '**Hello**',
      afterOffset: 7,
      char: '**',
    );
  });

  test("Removing from the first word", () {
    _testWord(
      before: '**Hello**',
      beforeOffset: 3,
      after: 'Hello',
      afterOffset: 5,
      char: '**',
    );
  });

  test("Surrounds the middle word", () {
    _testWord(
      before: 'Hello Hydra Person',
      beforeOffset: 8,
      after: 'Hello **Hydra** Person',
      afterOffset: 13,
      char: '**',
    );
  });

  test("Removes the middle word", () {
    _testWord(
      before: 'Hello **Hydra** Person',
      beforeOffset: 9,
      after: 'Hello Hydra Person',
      afterOffset: 11,
      char: '**',
    );
  });

  test("Surrounds the middle word with a newline", () {
    _testWord(
      before: 'Hello\nHydra Person',
      beforeOffset: 8,
      after: 'Hello\n**Hydra** Person',
      afterOffset: 13,
      char: '**',
    );
  });

  test("Word selection", () {
    var val = const TextEditingValue(
      text: 'Hello\nHydra Person',
      selection: TextSelection(baseOffset: 6, extentOffset: 11),
    );

    var newVal = modifyCurrentWord(val, '**');

    expect(newVal.text, 'Hello\n**Hydra** Person');
    expect(newVal.selection.baseOffset, 6);
    expect(newVal.selection.extentOffset, 15);

    var newVal2 = modifyCurrentWord(newVal, '**');
    expect(newVal2, val);
  });

  //
  // Navigation
  //
  void _testNextWord(String text, int offset, int expectedOffset) {
    var val = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );

    expect(nextWordPos(val), expectedOffset);
  }

  void _testPrevWord(String text, int offset, int expectedOffset) {
    var val = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );

    expect(prevWordPos(val), expectedOffset);
  }

  test('Navigation with only 1 word', () {
    const text = 'Hello';

    _testNextWord(text, 3, 5);
    _testNextWord(text, 5, 5);

    _testPrevWord(text, 3, 0);
    _testPrevWord(text, 5, 0);
  });

  test('Navigation with spaces', () {
    const text = ' Hello ';

    _testNextWord(text, 0, 1);
    _testNextWord(text, 3, 6);
    _testNextWord(text, 6, 7);
    _testNextWord(text, 7, 7);
    _testNextWord(text, 8, 7);

    _testPrevWord(text, 0, 0);
    _testPrevWord(text, 1, 0);
    _testPrevWord(text, 3, 1);
    _testPrevWord(text, 6, 1);
    _testPrevWord(text, 7, 6);
  });

  test('Navigation with multiple words', () {
    const text = 'Hello there Obiwan.';

    _testNextWord(text, 3, 5);
    _testNextWord(text, 5, 6);
    _testNextWord(text, 6, 11);
    _testNextWord(text, 11, 12);
    _testNextWord(text, 12, 18);
    _testNextWord(text, 18, 19);

    _testPrevWord(text, 19, 18);
    _testPrevWord(text, 18, 12);
    _testPrevWord(text, 12, 11);
    _testPrevWord(text, 11, 6);
    _testPrevWord(text, 6, 5);
    _testPrevWord(text, 5, 0);
  });

  test('Navigation with multiple lines', () {
    const text = 'Hello.\nHow are you?';

    _testNextWord(text, 0, 5);
    _testNextWord(text, 5, 6);
    _testNextWord(text, 6, 7);
    _testNextWord(text, 7, 10);
    _testNextWord(text, 10, 11);
    _testNextWord(text, 11, 14);
    _testNextWord(text, 14, 15);
    _testNextWord(text, 15, 18);
    _testNextWord(text, 18, 19);
    _testNextWord(text, 19, 19);

    _testPrevWord(text, 19, 18);
    _testPrevWord(text, 18, 15);
    _testPrevWord(text, 15, 14);
    _testPrevWord(text, 14, 11);
    _testPrevWord(text, 11, 10);
    _testPrevWord(text, 10, 7);
    _testPrevWord(text, 7, 6);
    _testPrevWord(text, 6, 5);
    _testPrevWord(text, 5, 0);
    _testPrevWord(text, 0, 0);
  });

  void _testTab({
    required String before,
    required int beforeOffset,
    required String after,
    required int afterOffset,
  }) {
    var val = TextEditingValue(
      text: before,
      selection: TextSelection.collapsed(offset: beforeOffset),
    );

    var expectedVal = TextEditingValue(
      text: after,
      selection: TextSelection.collapsed(offset: afterOffset),
    );

    expect(addTab(val), expectedVal);
  }

  void _testBackTab({
    required String before,
    required int beforeOffset,
    required String after,
    required int afterOffset,
  }) {
    var val = TextEditingValue(
      text: before,
      selection: TextSelection.collapsed(offset: beforeOffset),
    );

    var expectedVal = TextEditingValue(
      text: after,
      selection: TextSelection.collapsed(offset: afterOffset),
    );

    expect(addBackTab(val), expectedVal);
  }

  test('Tab', () {
    _testTab(
      before: 'Hello',
      beforeOffset: 0,
      after: '\tHello',
      afterOffset: 1,
    );

    _testTab(
      before: 'Hello',
      beforeOffset: 1,
      after: '\tHello',
      afterOffset: 2,
    );

    _testTab(
      before: 'Hi',
      beforeOffset: 2,
      after: '\tHi',
      afterOffset: 3,
    );

    _testTab(
      before: '- Hi',
      beforeOffset: 4,
      after: '\t- Hi',
      afterOffset: 5,
    );

    _testBackTab(
      before: '\tHello',
      beforeOffset: 1,
      after: 'Hello',
      afterOffset: 0,
    );

    _testBackTab(
      before: '\tHello',
      beforeOffset: 4,
      after: 'Hello',
      afterOffset: 3,
    );

    _testBackTab(
      before: 'Hi',
      beforeOffset: 0,
      after: 'Hi',
      afterOffset: 0,
    );

    _testBackTab(
      before: 'Hi',
      beforeOffset: 1,
      after: 'Hi',
      afterOffset: 1,
    );
  });
}
