/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:test/test.dart';

import 'package:gitjournal/core/worker_queue.dart';

void main() {
  group('WorkerQueue', () {
    test('Simple', () async {
      int func(int input) => input + 5;
      var worker = WorkerQueue(func);

      expect(await worker.call(2), 7);
      expect(await worker.call(3), 8);
    }, skip: true);

    test('Simple2', () async {
      var worker = WorkerQueue(func2);

      expect(await worker.call(2), 7);
      expect(await worker.call(3), 8);
    }, skip: true);

    test('Simple3', () async {
      var worker = WorkerQueue(func3);

      expect(await worker.call(2), 7);
      expect(await worker.call(3), 8);
    });
  });
}

int func2(int a) => a + 5;
dynamic func3(dynamic a) => (a as int) + 5;
