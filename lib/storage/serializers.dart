import 'dart:collection';

import 'package:fimber/fimber.dart';
import 'package:yaml/yaml.dart';

class NoteData {
  String body = "";
  LinkedHashMap<String, dynamic> props = LinkedHashMap<String, dynamic>();

  NoteData([this.body, this.props]) {
    body = body ?? "";
    // ignore: prefer_collection_literals
    props = props ?? LinkedHashMap<String, dynamic>();
  }

  @override
  int get hashCode => body.hashCode ^ props.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteData &&
          runtimeType == other.runtimeType &&
          body == other.body &&
          _equalMaps(props, other.props);

  static bool _equalMaps(Map a, Map b) {
    if (a.length != b.length) return false;
    return a.keys
        .every((dynamic key) => b.containsKey(key) && a[key] == b[key]);
  }

  @override
  String toString() {
    return 'NoteData{bodt: $body, props: $props}';
  }
}

abstract class NoteSerializer {
  String encode(NoteData note);
  NoteData decode(String str);
}

class MarkdownYAMLSerializer implements NoteSerializer {
  @override
  NoteData decode(String str) {
    if (str.startsWith("---\n")) {
      var parts = str.split("---\n");
      var map = <String, dynamic>{};
      var yamlText = parts[1].trim();

      try {
        if (yamlText.isNotEmpty) {
          var yamlMap = loadYaml(parts[1]);
          yamlMap.forEach((key, value) {
            map[key] = value;
          });
        }
      } catch (err) {
        Fimber.d(
            'MarkdownYAMLSerializer::decode("$yamlText") -> ${err.toString()}');
      }
      var body = parts[2].trimLeft();

      return NoteData(body, map);
    }

    return NoteData(str, LinkedHashMap<String, dynamic>());
  }

  @override
  String encode(NoteData note) {
    const serparator = '---\n';
    var str = "";
    str += serparator;

    str += toYAML(note.props);
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
