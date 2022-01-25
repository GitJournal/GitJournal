/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:sprintf/sprintf.dart';
import 'package:universal_io/io.dart';

class GitTransferProgress {
  int totalObjects = 0;
  int indexedObjects = 0;
  int receivedObjects = 0;
  int localObjects = 0;
  int totalDeltas = 0;
  int indexedDeltas = 0;
  int receivedBytes = 0;

  static Future<GitTransferProgress?> load(String statusFile) async {
    if (!File(statusFile).existsSync()) {
      return null;
    }
    var str = await File(statusFile).readAsString();
    return parse(str);
  }

  static GitTransferProgress? parse(String str) {
    var parts = str.split(' ');

    if (parts.length < 7) {
      return null;
    }

    var tp = GitTransferProgress();
    tp.totalObjects = int.parse(parts[0]);
    tp.indexedObjects = int.parse(parts[1]);
    tp.receivedObjects = int.parse(parts[2]);
    tp.localObjects = int.parse(parts[3]);
    tp.totalDeltas = int.parse(parts[4]);
    tp.indexedDeltas = int.parse(parts[5]);
    tp.receivedBytes = int.parse(parts[6]);
    return tp;
  }

  String get networkText {
    var fetchPercent = (100 * receivedObjects) / totalObjects;
    var kbytes = receivedBytes ~/ 1024;

    return sprintf("network %0.2f%% (%d kb, %d/%d)", [
      fetchPercent,
      kbytes,
      receivedObjects,
      totalObjects,
    ]);
  }

  String get indexText {
    var indexPercent = (100 * indexedObjects) / totalObjects;

    return sprintf('index %0.2f%% (%d/%d)', [
      indexPercent,
      indexedObjects,
      totalObjects,
    ]);
  }
}
