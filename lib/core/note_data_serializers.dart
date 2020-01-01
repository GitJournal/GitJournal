import 'dart:collection';

import 'package:fimber/fimber.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_serializer/yaml_serializer.dart';

import 'note_data.dart';

abstract class NoteDataSerializer {
  String encode(NoteData note);
  NoteData decode(String str);
}

class MarkdownYAMLSerializer implements NoteDataSerializer {
  @override
  NoteData decode(String str) {
    const startYamlStr = "---\n";
    const endYamlStr = "\n---\n";
    const emptyYamlHeaderStr = "---\n---";

    if (str == emptyYamlHeaderStr) {
      return NoteData();
    }
    if (str.startsWith(emptyYamlHeaderStr + "\n")) {
      var bodyBeginingPos = emptyYamlHeaderStr.length + 1;
      if (str[bodyBeginingPos] == '\n') {
        bodyBeginingPos += 1;
      }
      var body = str.substring(bodyBeginingPos);
      return NoteData(body);
    }

    if (str.startsWith(startYamlStr)) {
      var endYamlPos = str.indexOf(endYamlStr, startYamlStr.length);
      if (endYamlPos == -1) {
        // Try without the \n in the endYamlStr
        const endYamlStrWithoutLineEding = "\n---";
        if (str.endsWith(endYamlStrWithoutLineEding)) {
          var yamlText =
              str.substring(4, str.length - endYamlStrWithoutLineEding.length);
          var map = _parseYamlText(yamlText);
          return NoteData("", map);
        }

        return NoteData(str);
      }

      var yamlText = str.substring(4, endYamlPos);
      var map = _parseYamlText(yamlText);

      var body = "";
      var bodyBeginingPos = endYamlPos + endYamlStr.length;
      if (bodyBeginingPos < str.length) {
        if (str[bodyBeginingPos] == '\n') {
          bodyBeginingPos += 1;
        }
        if (bodyBeginingPos < str.length) {
          body = str.substring(bodyBeginingPos);
        }
      }

      return NoteData(body, map);
    }

    return NoteData(str, LinkedHashMap<String, dynamic>());
  }

  LinkedHashMap<String, dynamic> _parseYamlText(String yamlText) {
    LinkedHashMap<String, dynamic> map = LinkedHashMap<String, dynamic>();
    if (yamlText.isEmpty) {
      return map;
    }

    try {
      var yamlMap = loadYaml(yamlText);
      yamlMap.forEach((key, value) {
        map[key] = value;
      });
    } catch (err) {
      Fimber.d(
          'MarkdownYAMLSerializer::decode("$yamlText") -> ${err.toString()}');
    }

    return map;
  }

  @override
  String encode(NoteData note) {
    if (note.props.isEmpty) {
      return note.body;
    }

    var str = toYamlHeader(note.props);
    str += '\n';
    str += note.body;

    return str;
  }

  static String toYamlHeader(Map<String, dynamic> data) {
    var yaml = toYAML(data);
    return "---\n" + yaml + "---\n";
  }
}
