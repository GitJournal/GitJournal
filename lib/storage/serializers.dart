import 'dart:convert';

import 'package:journal/note.dart';
import 'package:yaml/yaml.dart';

abstract class NoteSerializer {
  String encode(Note note);
  Note decode(String str);
}

class JsonNoteSerializer implements NoteSerializer {
  @override
  Note decode(String str) {
    final json = JsonDecoder().convert(str);
    return Note.fromJson(json);
  }

  @override
  String encode(Note note) {
    return JsonEncoder().convert(note.toJson());
  }
}

class MarkdownYAMLSerializer implements NoteSerializer {
  @override
  Note decode(String str) {
    if (str.startsWith("---\n")) {
      var parts = str.split("---\n");
      var map = <String, dynamic>{};

      try {
        var yamlMap = loadYaml(parts[1]);
        yamlMap.forEach((key, value) {
          map[key] = value;
        });
      } catch (err, stack) {
        print(
            'MarkdownYAMLSerializer::decode (${parts[1]}) -> ${err.toString()}');
        print(stack.toString());
      }
      map['body'] = parts[2].trimLeft();

      return Note.fromJson(map);
    }

    var map = <String, dynamic>{};
    map['body'] = str;
    return Note.fromJson(map);
  }

  @override
  String encode(Note note) {
    const serparator = '---\n';
    var str = "";
    str += serparator;

    var metadata = note.toJson();
    metadata.remove('body');
    metadata.remove('filePath');

    str += toYAML(metadata);
    str += serparator;
    str += '\n';
    str += note.body;

    return str;
  }

  static String toYAML(Map<String, dynamic> map) {
    var str = "";

    map.forEach((key, value) {
      str += key + ": " + value + "\n";
    });
    return str;
  }
}
