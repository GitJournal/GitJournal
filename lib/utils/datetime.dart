/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'dart:core';

import 'package:dart_git/utils/date_time.dart';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:gitjournal/core/markdown/md_yaml_note_serializer.dart';
import 'package:intl/intl.dart';

import 'package:gitjournal/generated/core.pb.dart' as pb;
import 'package:gitjournal/logger/logger.dart';

final _dateOnlyFormat = DateFormat("yyyy-MM-dd");
final _simpleDateFormat = DateFormat("yyyy-MM-dd-HH-mm-ss");
final _iso8601DateFormat = DateFormat("yyyy-MM-ddTHH:mm:ss");
final _zettleDateFormat = DateFormat("yyyyMMddHHmmss");

String _intlLocale([String? locale]) {
  final value = (locale == null || locale.isEmpty)
      ? Intl.getCurrentLocale()
      : locale.replaceAll('-', '_');
  return Intl.canonicalizedLocale(value);
}

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

String formatJournalHeaderMonthYear(DateTime dt, {String? locale}) {
  return DateFormat.yMMMM(_intlLocale(locale)).format(dt);
}

String formatJournalWeekdayTime(DateTime dt, {String? locale}) {
  final intlLocale = _intlLocale(locale);
  final weekday = DateFormat.EEEE(intlLocale).format(dt);
  final time = DateFormat.Hm(intlLocale).format(dt);
  return '$weekday $time';
}

String formatJournalListDate(DateTime dt, {String? locale}) {
  return DateFormat.yMMMd(_intlLocale(locale)).format(dt);
}

String formatJournalTime(DateTime dt, {String? locale}) {
  return DateFormat.Hm(_intlLocale(locale)).format(dt);
}

String formatJournalGeneratedTitle(DateTime dt, {String? locale}) {
  final intlLocale = _intlLocale(locale);
  final date = DateFormat.yMMMMEEEEd(intlLocale).format(dt);
  final time = formatJournalTime(dt, locale: intlLocale);
  return '$date $time';
}

String toIso8601WithTimezone(DateTime dt) {
  var result = _iso8601DateFormat.format(dt);

  int minutes = (dt.timeZoneOffset.inMinutes % 60);
  int hours = dt.timeZoneOffset.inHours.toInt();

  String sign = '+';
  if (hours < 0) {
    hours = hours < 0 ? hours * -1 : hours;
    minutes = minutes < 0 ? minutes * -1 : minutes;
    sign = '-';
  }

  String hourStr;
  if (hours < 10) {
    hourStr = '0$hours';
  } else {
    hourStr = hours.toString();
  }

  String minutesStr;
  if (minutes < 10) {
    minutesStr = '0$minutes';
  } else {
    minutesStr = minutes.toString();
  }

  return '$result$sign$hourStr:$minutesStr';
}

DateTime? parseDateTime(String str) {
  try {
    return GDateTime.parse(str);
  } catch (ex) {
    Log.e("parseDateTime - '$str'", ex: ex);
  }

  return null;
}

DateTime parseUnixTimeStamp(
    int val, NoteSerializationUnixTimestampMagnitude magnitude) {
  if (magnitude == NoteSerializationUnixTimestampMagnitude.Seconds) {
    val *= 1000;
  }
  return DateTime.fromMillisecondsSinceEpoch(val, isUtc: true);
}

int toUnixTimeStamp(
    DateTime dt, NoteSerializationUnixTimestampMagnitude magnitude) {
  var timestamp = dt.toUtc();
  switch (magnitude) {
    case NoteSerializationUnixTimestampMagnitude.Milliseconds:
      return timestamp.millisecondsSinceEpoch;
    case NoteSerializationUnixTimestampMagnitude.Seconds:
    default:
      return timestamp.millisecondsSinceEpoch ~/ 1000;
  }
}

extension ProtoBuf on DateTime {
  pb.DateTimeAnyTz toProtoBuf() {
    return pb.DateTimeAnyTz(
      timestamp: fixnum.Int64(millisecondsSinceEpoch ~/ 1000),
      offset: timeZoneOffset.inSeconds,
    );
  }
}

extension ProtoBufParse on pb.DateTimeAnyTz {
  DateTime toDateTime() {
    return GDateTime.fromTimeStamp(
      Duration(seconds: offset),
      timestamp.toInt(),
    );
  }
}
