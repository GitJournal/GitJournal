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
}
