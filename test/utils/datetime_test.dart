/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:test/test.dart';
import 'package:time/time.dart';

import 'package:gitjournal/utils/datetime.dart';

void main() {
  group('DateTime Utils', () {
    test('Test random date', () {
      var dateTime = DateTime.utc(2011, 12, 23, 10, 15, 30);
      var str = toIso8601WithTimezone(dateTime);

      expect(str, "2011-12-23T10:15:30+00:00");
    });

    test('Test with small date', () {
      var dateTime = DateTime.utc(2011, 6, 6, 5, 5, 3);
      var str = toIso8601WithTimezone(dateTime);

      expect(str, "2011-06-06T05:05:03+00:00");
    });

    test('Test with positive offset', () {
      var dateTime = DateTime.utc(2011, 6, 6, 5, 5, 3);
      var str = toIso8601WithTimezone(dateTime, 2.hours);

      expect(str, "2011-06-06T05:05:03+02:00");
    });

    test('Test with positive offset and minutes', () {
      var dateTime = DateTime.utc(2011, 6, 6, 5, 5, 3);
      var str = toIso8601WithTimezone(dateTime, 10.hours);

      expect(str, "2011-06-06T05:05:03+10:00");
    });

    test('Test with negative offset', () {
      var dateTime = DateTime.utc(2011, 6, 6, 5, 5, 3);
      var str = toIso8601WithTimezone(dateTime, -5.hours);

      expect(str, "2011-06-06T05:05:03-05:00");
    });

    test('Test with negative offset and minutes', () {
      var dateTime = DateTime.utc(2011, 6, 6, 5, 5, 3);
      var str = toIso8601WithTimezone(dateTime, -11.hours - 30.minutes);

      expect(str, "2011-06-06T05:05:03-11:30");
    });

    test('Test ZettleDateTime', () {
      var dateTime = DateTime.utc(2011, 6, 6, 5, 5, 3);
      var str = toZettleDateTime(dateTime);
      expect(str, "20110606050503");
    });
  });
}
