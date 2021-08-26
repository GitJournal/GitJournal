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

  final filename = 'lib/.env.dart';
  await File(filename)
      .writeAsString('final environment = ${json.encode(config)};');

  return 0;
}

// FIXME: Make the .env.dart file type safe
