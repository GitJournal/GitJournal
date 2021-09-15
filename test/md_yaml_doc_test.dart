/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:collection';

import 'package:test/test.dart';

import 'package:gitjournal/core/md_yaml_doc.dart';

void main() {
  test('Equality', () {
    // ignore: prefer_collection_literals
    var aProps = LinkedHashMap<String, dynamic>();
    aProps['a'] = 1;
    aProps['title'] = "Foo";
    aProps['list'] = ["Foo", "Bar", 1];

    // ignore: prefer_collection_literals
    var bProps = LinkedHashMap<String, dynamic>();
    bProps['a'] = 1;
    bProps['title'] = "Foo";
    bProps['list'] = ["Foo", "Bar", 1];

    var a = MdYamlDoc(body: "a", props: aProps);
    var b = MdYamlDoc(body: "a", props: bProps);
    expect(a, b);
  });
}
