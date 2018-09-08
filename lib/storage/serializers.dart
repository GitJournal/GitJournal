import 'dart:convert';

import 'package:yaml/yaml.dart';
import 'package:journal/note.dart';

abstract class NoteSerializer {
  String encode(Note note);
  Note decode(String str);
}

class JsonNoteSerializer implements NoteSerializer {
  @override
  Note decode(String str) {
    final json = JsonDecoder().convert(str);
    return new Note.fromJson(json);
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

      var yamlMap = loadYaml(parts[1]);
      Map<String, dynamic> map = new Map<String, dynamic>();
      yamlMap.forEach((key, value) {
        map[key] = value;
      });
      map['body'] = parts[2].trimLeft();

      return new Note.fromJson(map);
    }

    return new Note(body: str);
  }

  @override
  String encode(Note note) {
    const serparator = '---\n';
    var str = "";
    str += serparator;

    var metadata = note.toJson();
    metadata.remove('body');
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
