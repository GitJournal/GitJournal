import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

import 'package:gitjournal/analytics/generated/analytics.pb.dart' as pb;
import 'package:gitjournal/analytics/storage.dart';

void main() {
  test('Read and write', () async {
    var dt = DateTime.now().add(const Duration(days: -1));
    var ev = pb.Event(
      name: 'test',
      date: Int64(dt.millisecondsSinceEpoch ~/ 1000),
      params: {'a': 'hello'},
      pseudoId: 'id',
      userProperties: {'b': 'c'},
      sessionID: 'session',
    );

    var dir = await Directory.systemTemp.createTemp('_analytics_');
    var storage = AnalyticsStorage(dir.path);
    await storage.appendEvent(ev);
    await storage.appendEvent(ev);

    var events = await storage.fetchAll();
    expect(events.length, 2);
    expect(events[0].toDebugString(), ev.toDebugString());
    expect(events[1].toDebugString(), ev.toDebugString());
    // expect(events[0], ev);
  });
}
