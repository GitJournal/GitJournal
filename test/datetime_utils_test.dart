import 'package:test/test.dart';
import 'package:journal/datetime_utils.dart';

main() {
  group('DateTime Utils', () {
    test('Test random date', () {
      var dateTime = DateTime.utc(2011, 12, 23, 10, 15, 30);
      var str = toIso8601WithTimezone(dateTime);

      expect(str, "2011-12-23T10:15:30+00:00");
    });
  });
}
