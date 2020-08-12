import 'package:flutter/material.dart';
import 'package:test/test.dart';

import 'package:gitjournal/widgets/markdown_toolbar.dart';

void main() {
  test('Adds a header to the first line correctly', () {
    var val = const TextEditingValue(
      text: 'Hello',
      selection: TextSelection.collapsed(offset: 5),
    );

    var expectedVal = const TextEditingValue(
      text: '# Hello',
      selection: TextSelection.collapsed(offset: 7),
    );

    expect(modifyCurrentLine(val, '# '), expectedVal);
  });

  test('Adds a header to the last line correctly', () {
    var val = const TextEditingValue(
      text: 'Hi\nHello',
      selection: TextSelection.collapsed(offset: 8),
    );

    var expectedVal = const TextEditingValue(
      text: 'Hi\n# Hello',
      selection: TextSelection.collapsed(offset: 10),
    );

    expect(modifyCurrentLine(val, '# '), expectedVal);
  });

  test('Adds a header to a middle line correctly', () {
    var val = const TextEditingValue(
      text: 'Hi\nHello\nFire',
      selection: TextSelection.collapsed(offset: 8),
    );

    var expectedVal = const TextEditingValue(
      text: 'Hi\n# Hello\nFire',
      selection: TextSelection.collapsed(offset: 10),
    );

    expect(modifyCurrentLine(val, '# '), expectedVal);
  });

  test('Adds a header to a middle line middle word correctly', () {
    var val = const TextEditingValue(
      text: 'Hi\nHello Darkness\nFire',
      selection: TextSelection.collapsed(offset: 8),
    );

    var expectedVal = const TextEditingValue(
      text: 'Hi\n# Hello Darkness\nFire',
      selection: TextSelection.collapsed(offset: 10),
    );

    expect(modifyCurrentLine(val, '# '), expectedVal);
  });

  // Removes from first line
  // Removes from last line
  // Removes from middle line
  // Removes when cursor is in the middle of a word
  // Removes when cursor is at the start of the line
  // Removes when cursor is in between '#' and ' '

  // TODO: Simplify the tests, avoid all this code duplication
}
