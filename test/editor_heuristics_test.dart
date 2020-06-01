import 'package:test/test.dart';
import 'package:gitjournal/editors/heuristics.dart';

void main() {
  group('Editor Heuristic Tests', () {
    test('Does not modify test on newline', () {
      var origText = "Hello";
      var newText = "Hello\n";

      var result = autoAddBulletList(origText, newText, newText.length);
      expect(result, null);
    });

    test('Adds a bullet item', () {
      var origText = "Hello\n* One";
      var newText = "Hello\n* One\n";

      var result = autoAddBulletList(origText, newText, newText.length);
      expect(result.text, "Hello\n* One\n* ");
      expect(result.cursorPos, result.text.length);
    });
  });
}
