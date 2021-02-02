import 'package:test/test.dart';

import 'package:gitjournal/editors/autocompletion_widget.dart';

void main() {
  var c = TagsAutoCompleter();

  test('Extract first word', () {
    var es = EditorState("#Hel", 3);
    var r = c.textChanged(es);
    expect(es.text.substring(r.start, r.end), "Hel");
  });

  test('Extract second word', () {
    var es = EditorState("Hi #Hel", 7);
    var r = c.textChanged(es);
    expect(es.text.substring(r.start, r.end), "Hel");
  });

  test('Extract second word - cursor not at end', () {
    var es = EditorState("Hi #Hell", 7);
    var r = c.textChanged(es);
    expect(es.text.substring(r.start, r.end), "Hell");
  });

  test("Second word with dot", () {
    var es = EditorState("Hi.#Hel", 6);
    var r = c.textChanged(es);
    expect(es.text.substring(r.start, r.end), "Hel");
  });

  test("Second word with newline", () {
    var es = EditorState("Hi\n#H", 5);
    var r = c.textChanged(es);
    expect(es.text.substring(r.start, r.end), "H");
  });

  test('Nothing to extract', () {
    var es = EditorState("#Hel hi ", 8);
    var r = c.textChanged(es);
    expect(r.isEmpty, true);
  });
}
