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
    return 'NoteData{body: $body, props: $props}';
  }
}

abstract class NoteSerializer {
  String encode(NoteData note);
  NoteData decode(String str);
}

class MarkdownYAMLSerializer implements NoteSerializer {
  @override
  NoteData decode(String str) {
    const startYamlStr = "---\n";
    const endYamlStr = "\n---\n";
    const emptyYamlHeaderStr = "---\n---\n";

    if (str.startsWith(emptyYamlHeaderStr)) {
      var bodyBeginingPos = emptyYamlHeaderStr.length;
      if (str[bodyBeginingPos] == '\n') {
        bodyBeginingPos += 1;
      }
      var body = str.substring(bodyBeginingPos);
      return NoteData(body, LinkedHashMap<String, dynamic>());
    }

    if (str.startsWith(startYamlStr)) {
      var endYamlPos = str.indexOf(endYamlStr, startYamlStr.length);
      if (endYamlPos == -1) {
        return NoteData(str, LinkedHashMap<String, dynamic>());
      }

      var yamlText = str.substring(4, endYamlPos);
      var map = <String, dynamic>{};

      try {
        if (yamlText.isNotEmpty) {
          var yamlMap = loadYaml(yamlText);
          yamlMap.forEach((key, value) {
            map[key] = value;
          });
        }
      } catch (err) {
        Fimber.d(
            'MarkdownYAMLSerializer::decode("$yamlText") -> ${err.toString()}');
      }

      var bodyBeginingPos = endYamlPos + endYamlStr.length;
      if (str[bodyBeginingPos] == '\n') {
        bodyBeginingPos += 1;
      }
      var body = str.substring(bodyBeginingPos);

      return NoteData(body, map);
    }

    return NoteData(str, LinkedHashMap<String, dynamic>());
  }

  @override
  String encode(NoteData note) {
    if (note.props.isEmpty) {
      return note.body;
    }

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
      String val = value.toString();
      str += key + ": " + val + "\n";
    });
    return str;
  }
}
