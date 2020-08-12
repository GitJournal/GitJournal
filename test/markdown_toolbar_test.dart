import 'package:flutter/material.dart';
import 'package:test/test.dart';

import 'package:gitjournal/widgets/markdown_toolbar.dart';

void main() {
  void _testH1({
    @required String before,
    @required int beforeOffset,
    @required String after,
    @required int afterOffset,
  }) {
    var val = TextEditingValue(
      text: before,
      selection: TextSelection.collapsed(offset: beforeOffset),
    );

    var expectedVal = TextEditingValue(
      text: after,
      selection: TextSelection.collapsed(offset: afterOffset),
    );

    expect(modifyCurrentLine(val, '# '), expectedVal);
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

  // Removes from first line
  // Removes from last line
  // Removes from middle line
  // Removes when cursor is in the middle of a word
  // Removes when cursor is at the start of the line
  // Removes when cursor is in between '#' and ' '

  // TODO: Simplify the tests, avoid all this code duplication
}
