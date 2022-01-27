/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:dart_git/utils/date_time.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:test/test.dart';

import 'package:gitjournal/core/markdown/md_yaml_doc.dart';

void main() {
  test('Equality', () {
    var now = GDateTime(const Duration(hours: 1), 2010, 1, 2, 3, 4, 5);

    var aProps = ListMap<String, dynamic>.of({
      'a': 1,
      'title': 'Foo',
      'list': ["Foo", "Bar", 1],
      'map': <String, dynamic>{'a': 5},
      'date': now,
    });

    var bProps = ListMap<String, dynamic>.of({
      'a': 1,
      'title': 'Foo',
      'list': ["Foo", "Bar", 1],
      'map': <String, dynamic>{'a': 5},
      'date': now,
    });

    var a = MdYamlDoc(body: "a", props: aProps);
    var b = MdYamlDoc(body: "a", props: bProps);
    expect(a, b);

    expect(a, MdYamlDoc.fromProtoBuf(a.toProtoBuf()));
  });
}
