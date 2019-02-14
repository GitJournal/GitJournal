import 'package:journal/note.dart';
import 'package:journal/storage/serializers.dart';
import 'package:test/test.dart';

DateTime nowWithoutMicro() {
  var dt = DateTime.now();
  return DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
}

void main() {
  group('Serializers', () {
    var note = Note(
        filePath: "2", body: "This is the body", created: nowWithoutMicro());

    test('JSON Serializer', () {
      var serializer = JsonNoteSerializer();
      var str = serializer.encode(note);
      var note2 = serializer.decode(str);

      expect(note2, note);
    });

    test('Markdown Serializer', () {
      var serializer = MarkdownYAMLSerializer();
      var str = serializer.encode(note);
      var note2 = serializer.decode(str);

      // The YAML seriazlier loses the fileName by design
      note2.filePath = note.filePath;

      expect(note2, note);
    });

    /*
    test('Markdown Serializer YAML Order', () {
      var str = """---
type: Journal
created: 2017-02-15T22:41:19+01:00
foo: bar
---

Alright.""";

      var serializer = MarkdownYAMLSerializer();
      var note = serializer.decode(str);
      var actualStr = serializer.encode(note);

      expect(actualStr, str);
    });
    */
  });
}
