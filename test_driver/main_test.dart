import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Test', () {
    final loadedFinder = find.text('Why not add your first\n Journal Entry?');

    FlutterDriver driver;
    int screenshotNum = 0;

    // Connect to the Flutter driver before running any tests
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    Future _takeScreenshot() async {
      var filePath = screenshotNum.toString() + ".png";
      final file = await File(filePath).create(recursive: true);
      final pixels = await driver.screenshot();
      await file.writeAsBytes(pixels);
    }

    test('Anonymous GitClone works', () async {
      await driver.waitFor(loadedFinder, timeout: Duration(seconds: 5));
      await _takeScreenshot();
    });
  });
}
