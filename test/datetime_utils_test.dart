import 'package:gitjournal/datetime_utils.dart';
import 'package:test/test.dart';

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
  });
}
