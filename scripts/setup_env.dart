#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

Future<int> main(List<String> args) async {
  var config = <String, String?>{};

  try {
    var contents = await File('secrets/env.json').readAsString();
    config = (json.decode(contents) as Map).map(
      (key, value) => MapEntry(key, value.toString()),
    );
  } catch (ex) {
    print(ex);
  }

  if (args.isNotEmpty) {
    config = config.map((key, value) => MapEntry(key, null));
  }

  print(config);
  print('');

  var contents = 'class Env {\n';
  config.forEach((key, value) {
    if (value == null) {
      contents += '  static final String $key = "";\n';
    } else {
      contents += '  static final String $key = "$value";\n';
    }
  });
  contents += '}\n';

  print(contents);

  final filename = 'lib/.env.dart';
  await File(filename).writeAsString(contents);

  return 0;
}
