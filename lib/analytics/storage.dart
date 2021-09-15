/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:typed_data';

import 'package:buffer/buffer.dart';
import 'package:collection/collection.dart';
import 'package:function_types/function_types.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:synchronized/synchronized.dart';
import 'package:universal_io/io.dart';

import 'package:gitjournal/logger/logger.dart';
import 'generated/analytics.pb.dart' as pb;

class AnalyticsStorage {
  final String folderPath;
  late String currentFile;

  final _lock = Lock();
  final _fetchAllLock = Lock();

  var numEventsThisSession = 0;

  AnalyticsStorage(this.folderPath) {
    _resetFile();
  }

  void _resetFile() {
    var nowUtc = DateTime.now().toUtc();
    var name = nowUtc.millisecondsSinceEpoch.toString();
    currentFile = p.join(folderPath, name);
  }

  Future<void> logEvent(pb.Event event) async {
    await _lock.synchronized(() {
      return appendEventToFile(event, currentFile);
    });
  }

  @visibleForTesting
  Future<void> appendEventToFile(pb.Event event, String filePath) async {
    var eventData = event.writeToBuffer();

    var intData = ByteData(4);
    intData.setInt32(0, eventData.length);

    var builder = BytesBuilder();
    builder.add(intData.buffer.asUint8List());
    builder.add(eventData);

    var _ = await File(filePath).writeAsBytes(
      builder.toBytes(),
      mode: FileMode.append,
    );
    numEventsThisSession++;
  }

  @visibleForTesting
  Future<List<pb.Event>> fetchFromFile(String filePath) async {
    var bytes = await File(filePath).readAsBytes();
    var events = <pb.Event>[];

    var reader = ByteDataReader(copy: false);
    reader.add(bytes);
    while (reader.remainingLength != 0) {
      var len = reader.readUint32();
      var bytes = reader.read(len);
      if (bytes.length != len) {
        var atEnd = reader.remainingLength == 0;
        Log.e("Analytics file $filePath corrupted. At End: $atEnd");
        continue;
      }

      try {
        var event = pb.Event.fromBuffer(bytes);
        events.add(event);
      } catch (ex, st) {
        Log.e("Failed to create Event from buffer", ex: ex, stacktrace: st);
      }
    }

    return events;
  }

  Future<List<String>> _availableFiles() async {
    var paths = <String>[];

    var dir = Directory(folderPath);
    await for (var entity in dir.list()) {
      if (entity is! File) {
        assert(false, "Analytics directory contains non Files");
        continue;
      }

      if (entity.path == currentFile) {
        continue;
      }

      paths.add(entity.path);
    }
    paths.sort();

    return paths;
  }

  // If the callback returns 'true' then the events are deleted
  // otherwise a subsequent call to fetchAll will return them!
  Future<void> fetchAll(Func1<List<pb.Event>, Future<bool>> callback) async {
    await _fetchAllLock.synchronized(() async {
      await _lock.synchronized(_resetFile);

      var allEvents = <pb.Event>[];
      var filePaths = await _availableFiles();
      for (var filePath in filePaths) {
        var events = await fetchFromFile(filePath);
        allEvents.addAll(events);
      }

      var shouldDelete = await callback(allEvents);
      if (shouldDelete) {
        for (var filePath in filePaths) {
          try {
            File(filePath).deleteSync();
          } catch (ex, st) {
            Log.e("Failed to delete analytics file", ex: ex, stacktrace: st);
          }
        }
      }
    });
  }

  Future<DateTime> oldestEvent() async {
    var fileNames = (await _availableFiles()).map(p.basename);
    var timestamps = fileNames.map(int.parse);
    var smallest = maxBy(timestamps, (i) => i);
    if (smallest == null) {
      return DateTime.now();
    }

    return DateTime.fromMillisecondsSinceEpoch(smallest, isUtc: true);
  }
}

// FIXME: Error handling?
