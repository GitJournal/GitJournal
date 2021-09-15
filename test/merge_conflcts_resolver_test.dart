/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:test/test.dart';

import 'package:gitjournal/utils/merge_conflict_resolver.dart';

void main() {
  test("Body only conflict", () {
    String input = '''---
title: Foo
---

<<<<<<< HEAD
This is the body in GitJournal
=======
This is the body from the remote/origin
>>>>>>> remote/origin

Some more text.''';

    String expectedOutput = '''---
title: Foo
---

This is the body in GitJournal

Some more text.''';

    expect(resolveMergeConflict(input), equals(expectedOutput));
  });

  /*
  test("YAML Conflict", () {});
  test("YAML Conflict from 1st line", () {});
  test("YAML Conflict different modified", () {});
  test("YAML and body conflict", () {});
  */
}
