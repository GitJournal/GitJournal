import 'dart:typed_data';

import 'package:buffer/buffer.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart';

import 'generated/analytics.pb.dart' as pb;

class AnalyticsStorage {
  final String folderPath;

  AnalyticsStorage(this.folderPath);

  Future<void> appendEvent(pb.Event event) async {
    var eventData = event.writeToBuffer();

    var filePath = p.join(folderPath, 'analytics');
    // print(filePath);

    var intData = ByteData(4);
    intData.setInt32(0, eventData.length);

    var builder = BytesBuilder();
    builder.add(intData.buffer.asUint8List());
    builder.add(eventData);

    await File(filePath).writeAsBytes(builder.toBytes(), mode: FileMode.append);
  }

  Future<List<pb.Event>> fetchAll() async {
    var file = File(p.join(folderPath, 'analytics'));
    var bytes = await file.readAsBytes();
    var events = <pb.Event>[];

    var reader = ByteDataReader(copy: false);
    reader.add(bytes);
    while (reader.remainingLength != 0) {
      var len = reader.readUint32();
      var bytes = reader.read(len);

      var event = pb.Event.fromBuffer(bytes);
      events.add(event);
    }
    return events;
  }
}
