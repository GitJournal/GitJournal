#!/usr/bin/env dart
// SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

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
    stderr.writeln(ex);
  }

  if (args.isNotEmpty) {
    config = config.map((key, value) => MapEntry(key, null));
  }

  stderr.writeln(config);
  stderr.writeln('');

  var contents = 'class Env {\n';
  config.forEach((key, value) {
    if (value == null) {
      contents += '  static final String $key = "";\n';
    } else {
      contents += '  static final String $key = "$value";\n';
    }
  });
  contents += '}\n';

  stderr.writeln(contents);

  const filename = 'lib/.env.dart';
  await File(filename).writeAsString(contents);

  return 0;
}
