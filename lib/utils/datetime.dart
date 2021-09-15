/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:core';

import 'package:intl/intl.dart';

import 'package:gitjournal/logger/logger.dart';

final _dateOnlyFormat = DateFormat("yyyy-MM-dd");
final _simpleDateFormat = DateFormat("yyyy-MM-dd-HH-mm-ss");
final _iso8601DateFormat = DateFormat("yyyy-MM-ddTHH:mm:ss");
final _zettleDateFormat = DateFormat("yyyyMMddHHmmss");

String toDateString(DateTime dt) {
  return _dateOnlyFormat.format(dt);
}

String toSimpleDateTime(DateTime dt) {
  return _simpleDateFormat.format(dt);
}

String toIso8601(DateTime dt) {
  return _iso8601DateFormat.format(dt);
}

String toZettleDateTime(DateTime dt) {
  return _zettleDateFormat.format(dt);
}

String toIso8601WithTimezone(DateTime dt, [Duration? offset]) {
  var result = _iso8601DateFormat.format(dt);

  offset = offset ?? dt.timeZoneOffset;
  int minutes = (offset.inMinutes % 60);
  int hours = offset.inHours.toInt();

  String sign = '+';
  if (hours < 0) {
    hours = hours < 0 ? hours * -1 : hours;
    minutes = minutes < 0 ? minutes * -1 : minutes;
    sign = '-';
  }

  String hourStr;
  if (hours < 10) {
    hourStr = '0' + hours.toString();
  } else {
    hourStr = hours.toString();
  }

  String minutesStr;
  if (minutes < 10) {
    minutesStr = '0' + minutes.toString();
  } else {
    minutesStr = minutes.toString();
  }

  return result + sign + hourStr + ':' + minutesStr;
}

DateTime? parseDateTime(String str) {
  DateTime? dt;
  try {
    dt = DateTime.parse(str).toLocal();
  } catch (ex) {
    // Ignore it
  }

  if (dt == null) {
    var regex = RegExp(
        r"(\d{4})-(\d{2})-(\d{2})T(\d{2})\:(\d{2})\:(\d{2})\+(\d{2})\:(\d{2})");
    if (regex.hasMatch(str)) {
      // FIXME: Handle the timezone!
      str = str.substring(0, 19);
      try {
        dt = DateTime.parse(str);
      } catch (ex) {
        Log.d("Note Date Parsing Failed: $ex");
      }
    }
  }

  return dt;
}

DateTime parseUnixTimeStamp(int val) {
  return DateTime.fromMillisecondsSinceEpoch(val * 1000, isUtc: true);
}

int toUnixTimeStamp(DateTime dt) {
  return dt.toUtc().millisecondsSinceEpoch ~/ 1000;
}
