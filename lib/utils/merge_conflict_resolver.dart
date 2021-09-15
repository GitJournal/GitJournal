/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';

String resolveMergeConflict(String fileContents) {
  var lines = const LineSplitter().convert(fileContents);
  var newLines = <String>[];

  var inMergeConflict = false;
  var seenStartMarker = false;
  var seenMiddleMarker = false;

  lines.forEach((line) {
    if (line.startsWith("<<<<<<<") && !inMergeConflict) {
      inMergeConflict = true;
      seenStartMarker = true;
      return;
    }
    if (line == "=======" && inMergeConflict && seenStartMarker) {
      seenMiddleMarker = true;
      return;
    }
    if (line.startsWith(">>>>>>>") && inMergeConflict && seenMiddleMarker) {
      inMergeConflict = false;
      seenStartMarker = false;
      seenMiddleMarker = false;
      return;
    }

    if (inMergeConflict && seenMiddleMarker) {
      return;
    }

    newLines.add(line);
  });

  return newLines.join('\n');
}
