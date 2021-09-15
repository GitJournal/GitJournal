/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

import 'package:gitjournal/analytics/generated/analytics.pb.dart' as pb;
import 'package:gitjournal/analytics/storage.dart';

void main() {
  test('Read and write', () async {
    var ev1 = _randomEvent(1);
    var ev2 = _randomEvent(2);

    var dir = await Directory.systemTemp.createTemp('_analytics_');
    var af = p.join(dir.path, "analytics");

    var storage = AnalyticsStorage(dir.path);
    await storage.appendEventToFile(ev1, af);
    await storage.appendEventToFile(ev2, af);

    var events = await storage.fetchFromFile(af);
    expect(events.length, 2);
    expect(events[0].toDebugString(), ev1.toDebugString());
    expect(events[1].toDebugString(), ev2.toDebugString());
    // expect(events[0], ev);
  });

  test('Fetch All', () async {
    var ev1 = _randomEvent(1);
    var ev2 = _randomEvent(2);
    var ev3 = _randomEvent(3);

    var dir = await Directory.systemTemp.createTemp('_analytics_');
    var storage = AnalyticsStorage(dir.path);

    await storage.logEvent(ev1);
    await storage.logEvent(ev2);

    await storage.fetchAll((events) async {
      expect(events.length, 2);
      expect(events[0].toDebugString(), ev1.toDebugString());
      expect(events[1].toDebugString(), ev2.toDebugString());
      return false;
    });

    await storage.logEvent(ev3);
    await storage.fetchAll((events) async {
      expect(events.length, 3);
      expect(events[0].toDebugString(), ev1.toDebugString());
      expect(events[1].toDebugString(), ev2.toDebugString());
      expect(events[2].toDebugString(), ev3.toDebugString());
      return true;
    });

    await storage.fetchAll((events) async {
      expect(events.length, 0);
      return true;
    });

    await storage.fetchAll((events) async {
      expect(events.length, 0);
      return false;
    });
  });
}

pb.Event _randomEvent(int num) {
  var random = Random();
  var dt = DateTime.now().add(Duration(days: random.nextInt(5000) * -1));
  var ev = pb.Event(
    name: 'test-$num',
    date: Int64(dt.millisecondsSinceEpoch ~/ 1000),
    params: {'a': 'hello'},
    pseudoId: 'id',
    userProperties: {'b': 'c'},
    sessionID: 123,
  );
  return ev;
}
