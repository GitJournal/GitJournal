import 'package:journal/utils/markdown.dart';
import 'package:test/test.dart';

void main() {
  group('Markdown To Text', () {
    test('Test Headers', () {
      var input = '# Hello\nHow are you?';
      expect(markdownToPlainText(input), 'Hello How are you?');
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
