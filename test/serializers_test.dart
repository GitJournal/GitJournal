import 'package:journal/note.dart';
import 'package:journal/storage/serializers.dart';

import 'package:test/test.dart';

main() {
  group('Serializers', () {
    var note =
        Note(id: "2", body: "This is the body", created: new DateTime.now());

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
