/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'dart:convert';

import 'dart:typed_data';

class SshFormat {
  static List<int> encodeString(String s) => encodeBytes(utf8.encode(s));

  static List<int> encodeBytes(List<int> b) {
    var bytes = Uint8List.fromList(b);

    var val = <int>[];
    val.addAll(encodeUInt32(bytes.length));
    val.addAll(bytes);
    return val;
  }

  static Uint8List encodeUInt32(int n) {
    var t = Uint8List(4);
    t[0] = n >> 24;
    t[1] = n >> 16;
    t[2] = n >> 8;
    t[3] = n;

    return t;
  }
}
