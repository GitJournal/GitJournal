import 'package:test/test.dart';

import 'package:gitjournal/autocompletion/widget.dart';

void main() {
  var c = TagsAutoCompleter();

  test('Extract second word', () {
    var p = c.textChanged(EditorState("Hi #Hel", 7));
    expect(p, "Hel");
  });

  test('Extract second word - cursor not at end', () {
    var p = c.textChanged(EditorState("Hi #Hell", 7));
    expect(p, "Hell");
  });

  test("Second word with dot", () {
    var p = c.textChanged(EditorState("Hi.#Hel", 6));
    expect(p, "Hel");
  });
}
