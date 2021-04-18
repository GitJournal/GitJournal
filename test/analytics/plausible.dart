import 'package:test/test.dart';

import 'package:gitjournal/analytics/plausible.dart';

final Matcher throwsAssertionError = throwsA(isA<AssertionError>());

void main() {
  test('Serialization', () {
    var e = PlausibleEvent();
    e.props = {
      'a': 1,
      'b': 5.5,
      'c': false,
      'd': 'Hello',
    };

    expect(e.toJson(), isNotEmpty);
  });

  test('Invalid Serialization', () {
    var fn = () {
      var e = PlausibleEvent();
      e.props = {
        'a': [1],
      };
      e.toJson();
    };

    expect(fn, throwsAssertionError);
  });
}
