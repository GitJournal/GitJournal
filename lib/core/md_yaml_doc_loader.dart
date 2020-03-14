import 'dart:io';

import 'package:gitjournal/core/md_yaml_doc.dart';
import 'package:gitjournal/core/md_yaml_doc_codec.dart';

class MdYamlDocLoader {
  static final _serializer = MarkdownYAMLCodec();

  Future<MdYamlDoc> loadDoc(String filePath) async {
    // FIXME: What about parse errors?

    final file = File(filePath);
    if (!file.existsSync()) {
      throw MdYamlDocNotFoundException(filePath);
    }

    final fileData = await file.readAsString();
    var doc = _serializer.decode(fileData);
    return doc;
  }
}

class MdYamlDocNotFoundException implements Exception {
  final String filePath;
  MdYamlDocNotFoundException(this.filePath);

  @override
  String toString() => "MdYamlDocNotFoundException: $filePath";
}
