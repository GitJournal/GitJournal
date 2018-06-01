import 'dart:io';

import 'package:journal/note.dart';
import 'package:journal/serializers.dart';

import 'package:test/test.dart';

main() {
  group('Serializers', () {
    var note =
        Note(id: "2", body: "This is the body", created: new DateTime.now());

    test('JSON Serializer', () {
      var jsonSerializer = new JsonNoteSerializer();
      var str = jsonSerializer.encode(note);
      var note2 = jsonSerializer.decode(str);

      expect(note2, note);
    });

    test('Markdown Serializer', () {
      var jsonSerializer = new MarkdownYAMLSerializer();
      var str = jsonSerializer.encode(note);
      var note2 = jsonSerializer.decode(str);

      expect(note2, note);
    });
  });
}
