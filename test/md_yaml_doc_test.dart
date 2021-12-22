/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:collection';

import 'package:dart_git/utils/date_time.dart';
import 'package:test/test.dart';

import 'package:gitjournal/core/markdown/md_yaml_doc.dart';

void main() {
  test('Equality', () {
    var now = GDateTime(const Duration(hours: 1), 2010, 1, 2, 3, 4, 5);

    // ignore: prefer_collection_literals
    var aProps = LinkedHashMap<String, dynamic>();
    aProps['a'] = 1;
    aProps['title'] = "Foo";
    aProps['list'] = ["Foo", "Bar", 1];
    aProps['map'] = <String, dynamic>{'a': 5};
    aProps['date'] = now;

    // ignore: prefer_collection_literals
    var bProps = LinkedHashMap<String, dynamic>();
    bProps['a'] = 1;
    bProps['title'] = "Foo";
    bProps['list'] = ["Foo", "Bar", 1];
    bProps['map'] = <String, dynamic>{'a': 5};
    bProps['date'] = now;

    var a = MdYamlDoc(body: "a", props: aProps);
    var b = MdYamlDoc(body: "a", props: bProps);
    expect(a, b);

    expect(a, MdYamlDoc.fromProtoBuf(a.toProtoBuf()));
  });
}
