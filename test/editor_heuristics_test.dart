import 'package:test/test.dart';
import 'package:gitjournal/editors/heuristics.dart';

void main() {
  group('Editor Heuristic Tests', () {
    test('Does not modify test on newline', () {
      var origText = "Hello";
      var newText = origText + '\n';

      var result = autoAddBulletList(origText, newText, newText.length);
      expect(result, null);
    });

    test('Adds a bullet point at the end', () {
      var origText = "Hello\n* One";
      var newText = origText + '\n';

      var result = autoAddBulletList(origText, newText, newText.length);
      expect(result.text, "Hello\n* One\n* ");
      expect(result.cursorPos, result.text.length);
    });

    test('Adds a bullet point in the middle', () {
      var origText = "Hello\n* One\n* Three";
      var newText = "Hello\n* One\n\n* Three";

      var result = autoAddBulletList(origText, newText, 12);
      expect(result.text, "Hello\n* One\n* \n* Three");
      expect(result.cursorPos, 14);
    });

    test('Adds a numbered list at the end', () {
      var origText = "Hello\n1. One";
      var newText = origText + '\n';

      var result = autoAddBulletList(origText, newText, newText.length);
      expect(result.text, "Hello\n1. One\n1. ");
      expect(result.cursorPos, result.text.length);
    });

    test('Pressing enter on an empty list removes it', () {
      var origText = "Hello\n* One\n* ";
      var newText = origText + '\n';

      var result = autoAddBulletList(origText, newText, newText.length);
      expect(result.text, "Hello\n* One\n");
      expect(result.cursorPos, result.text.length);
    });

    test('Pressing enter on an empty list removes it - in the middle', () {
      var origText = "Hello\n* One\n* Fire";
      var newText = "Hello\n* One\n* \nFire";

      var result = autoAddBulletList(origText, newText, 15);
      expect(result.text, "Hello\n* One\nFire");
      expect(result.cursorPos, 12);
    });

    test('Adds a bullet point without spaces', () {
      var origText = "*One";
      var newText = origText + '\n';

      var result = autoAddBulletList(origText, newText, newText.length);
      expect(result.text, "*One\n*");
      expect(result.cursorPos, result.text.length);
    });

    test('Adds a bullet point with many spaces', () {
      var origText = "*   One";
      var newText = origText + '\n';

      var result = autoAddBulletList(origText, newText, newText.length);
      expect(result.text, "*   One\n*   ");
      expect(result.cursorPos, result.text.length);
    });

    /*
    test('Adds a bullet point with many spaces - in the middle', () {
      var origText = "*   One\nFire";
      var newText = origText + '\n';

      var result = autoAddBulletList(origText, newText, 8);
      expect(result.text, "*   One\n*   \nFire");
      expect(result.cursorPos, 12);
    });
    */
  });
}
