#!/usr/bin/env dart
// SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<int> main(List<String> args) async {
  var contents = await File(args[0]).readAsString();
  var ds = json.decode(contents);
  process([], ds);
  print(json.encode(newMap));

  return 0;
}

Map<String, String> newMap = {};

void process(List<String> prefixes, Map<String, dynamic> map) {
  for (var entry in map.entries) {
    var p = [...prefixes, ...entry.key.split('_')];

    if (entry.value is String) {
      newMap[toCamel(p)] = entry.value;
      continue;
    }

    assert(entry.value is Map);
    process(p, entry.value);
  }
}

String toCamel(List<String> l) {
  var str = l[0].replaceRange(0, 1, l[0][0].toLowerCase());
  for (var i = 1; i < l.length; i++) {
    var s = l[i];
    s = s.replaceRange(0, 1, s[0].toUpperCase());
    // ignore: use_string_buffers
    str += s;
  }

  return str;
}
