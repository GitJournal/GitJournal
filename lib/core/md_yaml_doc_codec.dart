/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:collection';

import 'package:yaml/yaml.dart';
import 'package:yaml_serializer/yaml_serializer.dart';

import 'package:gitjournal/logger/logger.dart';
import 'md_yaml_doc.dart';

class MarkdownYAMLCodec {
  MdYamlDoc decode(String str) {
    const startYamlStr = "---\n";
    const endYamlStr = "\n---\n";
    const emptyYamlHeaderStr = "---\n---";

    if (str == emptyYamlHeaderStr) {
      return MdYamlDoc();
    }
    if (str.startsWith(emptyYamlHeaderStr + "\n")) {
      var bodyBeginingPos = emptyYamlHeaderStr.length + 1;
      if (str[bodyBeginingPos] == '\n') {
        bodyBeginingPos += 1;
      }
      var body = str.substring(bodyBeginingPos);
      return MdYamlDoc(body: body);
    }

    if (str.startsWith(startYamlStr)) {
      var endYamlPos = str.indexOf(endYamlStr, startYamlStr.length);
      if (endYamlPos == -1) {
        // Try without the \n in the endYamlStr
        const endYamlStrWithoutLineEding = "\n---";
        if (str.endsWith(endYamlStrWithoutLineEding)) {
          var yamlText =
              str.substring(4, str.length - endYamlStrWithoutLineEding.length);
          var map = parseYamlText(yamlText);
          return MdYamlDoc(props: map);
        }

        return MdYamlDoc(body: str);
      }

      var yamlText = str.substring(4, endYamlPos);
      var map = parseYamlText(yamlText);

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

      return MdYamlDoc(body: body, props: map);
    }

    return MdYamlDoc(body: str);
  }

  static LinkedHashMap<String, dynamic> parseYamlText(String yamlText) {
    LinkedHashMap<String, dynamic> map = LinkedHashMap<String, dynamic>();
    if (yamlText.isEmpty) {
      return map;
    }

    try {
      var yamlMap = loadYaml(yamlText);
      if (yamlMap is! Map) {
        return map;
      }
      map = _convertMap(yamlMap as YamlMap);
    } catch (err) {
      Log.d('MarkdownYAMLSerializer::decode("$yamlText") -> ${err.toString()}');
    }

    return map;
  }

  String encode(MdYamlDoc note) {
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

LinkedHashMap<String, dynamic> _convertMap(YamlMap yamlMap) {
  LinkedHashMap<String, dynamic> map = LinkedHashMap<String, dynamic>();

  yamlMap.forEach((key, value) {
    if (value is YamlMap) {
      value = _convertMap(value);
    }
    map[key] = value;
  });

  return map;
}
