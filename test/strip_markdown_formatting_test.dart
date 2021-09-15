/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:test/test.dart';

import 'package:gitjournal/utils/markdown.dart';

void main() {
  group('Markdown Remove Formatting', () {
    test('Test Headers', () {
      var input = '# Hello\nHow are you?';
      expect(stripMarkdownFormatting(input), 'Hello How are you?');
    });

    test('Test Header2', () {
      var input = """Test Header
----------

Hello
      """;

      expect(stripMarkdownFormatting(input), 'Test Header Hello');
    }, skip: true);

    test('Itemized LIsts', () {
      var input = """Itemized lists
look like:

  * this one
  * that one
      """;

      expect(stripMarkdownFormatting(input),
          'Itemized lists look like: • this one • that one');
    });

    test('Checklist', () {
      var input = """Itemized lists

- [ ] this one
- [x] that one
- [X] last
      """;

      expect(stripMarkdownFormatting(input),
          'Itemized lists ☐ this one ☑ that one ☑ last');
    });

    test('List', () {
      var input = """Itemized lists

* this one
  * that one
* four
""";

      expect(stripMarkdownFormatting(input),
          'Itemized lists • this one • that one • four');
    });

    test('Russian Sentence', () {
      var input = "Не́которые иностра́нцы ду́мают";

      expect(stripMarkdownFormatting(input), input);
    });

    test('Russian Word', () {
      var input = "Не́которые";
      expect(stripMarkdownFormatting(input), input);
    });
  });
}
