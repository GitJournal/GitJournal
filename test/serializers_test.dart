import 'package:journal/note.dart';
import 'package:journal/storage/serializers.dart';

import 'package:test/test.dart';

DateTime nowWithoutMicro() {
  var dt = DateTime.now();
  return DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
}

main() {
  group('Serializers', () {
    var note =
        Note(id: "2", body: "This is the body", created: nowWithoutMicro());

    test('JSON Serializer', () {
      var serializer = new JsonNoteSerializer();
      var str = serializer.encode(note);
      var note2 = serializer.decode(str);

      expect(note2, note);
    });

    test('Markdown Serializer', () {
      var serializer = new MarkdownYAMLSerializer();
      var str = serializer.encode(note);
      var note2 = serializer.decode(str);

      expect(note2, note);
    });
  });
}
