import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Test', () {
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
      screenshotNum += 1;

      print("Taking screenshot $filePath");
      final file = await File(filePath).create(recursive: true);
      final pixels = await driver.screenshot();
      await file.writeAsBytes(pixels);
    }

    test('Anonymous GitClone works', () async {
      // OnBoarding
      var nextButton = find.text("Next");
      await driver.waitFor(nextButton, timeout: const Duration(seconds: 5));
      await _takeScreenshot();
      await driver.tap(nextButton);

      // Page 2
      await _takeScreenshot();
      await driver.tap(nextButton);

      // Page 3
      await _takeScreenshot();
      await driver.tap(find.byValueKey("GetStarted"));

      // Main Screen
      final loadedFinder = find.text('Why not add your first\n Journal Entry?');
      await driver.waitFor(loadedFinder, timeout: const Duration(seconds: 5));
      await _takeScreenshot();

      // Create a new note
      var fab = find.byValueKey("FAB");
      await driver.waitFor(fab, timeout: const Duration(seconds: 2));
      await driver.tap(fab);
      await driver.waitFor(find.text('Write here'),
          timeout: const Duration(seconds: 2));
      await _takeScreenshot();

      await driver.enterText(
          "Your notes will be saved in Markdown with a YAML header for the metadata.\n\nThe writing experience is clean and distraction free");
      await _takeScreenshot();
      await driver.tap(find.byValueKey("NewEntry"));

      // Create another note
      await driver.waitFor(fab, timeout: const Duration(seconds: 2));
      await driver.tap(fab);
      await driver.waitFor(find.text('Write here'),
          timeout: const Duration(seconds: 2));

      await driver.enterText(
          "Journaling is a great way to clear your mind and get all your throughts down into paper. Well, not literal paper, as this is an app, but I think you get the point.");
      await _takeScreenshot();
      await driver.tap(find.byValueKey("NewEntry"));

      await Future.delayed(const Duration(milliseconds: 500));
      await _takeScreenshot();

      // Open the Drawer
      final drawerButtonFinder = find.byValueKey("DrawerButton");
      await driver.tap(drawerButtonFinder);
      await Future.delayed(const Duration(milliseconds: 500));
      await _takeScreenshot();

      // The Git Host setup screen
      await driver.tap(find.text("Setup Git Host"));
      await driver.waitFor(find.text("GitHub"),
          timeout: const Duration(seconds: 2));
      await _takeScreenshot();
      // FIXME: This doesn't seem to work!
      // await driver.tap(find.pageBack());

      // Close the drawer
      // var app = find.byValueKey("App");
      // await driver.scroll(app, -300.0, 0.0, const Duration(milliseconds: 300));
    });
  });
}
