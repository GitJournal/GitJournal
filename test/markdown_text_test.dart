import 'package:journal/utils/markdown.dart';
import 'package:test/test.dart';

void main() {
  group('Markdown To Text', () {
    test('Test Headers', () {
      var input = '# Hello\nHow are you?';
      expect(markdownToPlainText(input), 'Hello How are you?');
    });

    test('Test Header2', () {
      var input = """Test Header
----------

Hello
      """;

      expect(markdownToPlainText(input), 'Test Header Hello');
    });

    test('Itemized LIsts', () {
      var input = """Itemized lists
look like:

  * this one
  * that one
      """;

      expect(markdownToPlainText(input),
          'Itemized lists look like: this one that one');
    });
  });
}
