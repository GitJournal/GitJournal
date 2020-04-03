import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:screenshots/screenshots.dart';

void main() {
  group('Test', () {
    FlutterDriver driver;
    int screenshotNum = 0;
    final config = Config();

    // Connect to the Flutter driver before running any tests
    setUpAll(() async {
      driver = await FlutterDriver.connect();
      await Future.delayed(const Duration(seconds: 5));
    });

    // Close the connection to the driver after the tests have completed
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    Future _takeScreenshot() async {
      screenshotNum += 1;
      /*
      var filePath = screenshotNum.toString() + ".png";

      print("Taking screenshot $filePath");
      final file = await File(filePath).create(recursive: true);
      final pixels = await driver.screenshot();
      await file.writeAsBytes(pixels);
      */

      // Fancy Screenshot package
      await screenshot(driver, config, screenshotNum.toString());
    }

    test('Normal Flow', () async {
      // OnBoarding
      var nextButton = find.text("Next");
      await driver.waitFor(nextButton, timeout: const Duration(seconds: 5));
      await _takeScreenshot();
      await driver.tap(nextButton);

      // Page 2
      await _takeScreenshot();
      await driver.tap(nextButton);

      // Page 3
      // await _takeScreenshot();
      await driver.tap(find.byValueKey("GetStarted"));

      // Main Screen
      final loadedFinder = find.text("Let's add some notes?");
      await driver.waitFor(loadedFinder, timeout: const Duration(seconds: 5));
      // await _takeScreenshot();

      // Create a new note
      var fab = find.byValueKey("FAB");
      await driver.waitFor(fab, timeout: const Duration(seconds: 2));
      await driver.tap(fab);
      await driver.waitFor(find.text('Write here'),
          timeout: const Duration(seconds: 5));
      await _takeScreenshot();

      await driver.enterText(
          "Your notes will be saved in Markdown with a YAML header for the metadata.\n\nThe writing experience is clean and distraction free");
      await _takeScreenshot();

      // Editor Selector
      var editorSelector = find.byValueKey("EditorSelector");
      await driver.tap(editorSelector);
      await Future.delayed(const Duration(milliseconds: 100));
      await _takeScreenshot();

      // Raw Edtitor
      var rawEditor = find.text("Raw Editor");
      await driver.waitFor(rawEditor, timeout: const Duration(seconds: 2));
      await driver.tap(rawEditor);
      await Future.delayed(const Duration(milliseconds: 100));
      await _takeScreenshot();

      // Journal Editor
      await driver.tap(editorSelector);
      var journalEditor = find.text("Journal Editor");
      await driver.waitFor(journalEditor, timeout: const Duration(seconds: 2));
      await driver.tap(journalEditor);
      await Future.delayed(const Duration(milliseconds: 100));
      await _takeScreenshot();

      // Go Back to home screen
      await driver.tap(find.byValueKey("NewEntry"));

      // Create another note
      await driver.waitFor(fab, timeout: const Duration(seconds: 2));
      await driver.tap(fab);
      await driver.waitFor(find.text('Write here'),
          timeout: const Duration(seconds: 5));

      await driver.enterText(
          "Taking Notes is a great way to clear your mind and get all your throughts down into paper. Well, not literal paper, as this is an app, but I think you get the point.");
      await _takeScreenshot();
      await driver.tap(find.byValueKey("NewEntry"));

      await Future.delayed(const Duration(milliseconds: 100));
      await _takeScreenshot();

      // Folder View Selector
      print("Taking Screenshots of FolderViewSelector");
      var folderViewSelector = find.byValueKey("FolderViewSelector");
      await driver.tap(folderViewSelector);
      await Future.delayed(const Duration(milliseconds: 100));
      await _takeScreenshot();

      // Select Card View
      var cardView = find.text("Card View (Experimental)");
      await driver.waitFor(cardView, timeout: const Duration(seconds: 2));
      await driver.tap(cardView);
      await Future.delayed(const Duration(milliseconds: 100));
      await _takeScreenshot();

      // Select Journal View
      await driver.tap(folderViewSelector);
      var journalView = find.text("Journal View");
      await driver.waitFor(journalView, timeout: const Duration(seconds: 2));
      await driver.tap(journalView);
      await Future.delayed(const Duration(milliseconds: 100));
      await _takeScreenshot();

      // Select Grid View
      await driver.tap(folderViewSelector);
      var gridView = find.text("Grid View");
      await driver.waitFor(gridView, timeout: const Duration(seconds: 2));
      await driver.tap(gridView);
      await Future.delayed(const Duration(milliseconds: 100));
      await _takeScreenshot();

      // Open the Drawer
      final drawerButtonFinder = find.byValueKey("DrawerButton");
      await driver.tap(drawerButtonFinder);
      await Future.delayed(const Duration(milliseconds: 100));
      await _takeScreenshot();

      // The Git Host setup screen
      await driver.tap(find.text("Setup Git Host"));
      await driver.waitFor(find.text("GitHub"),
          timeout: const Duration(seconds: 5));
      await _takeScreenshot();
      // FIXME: This doesn't seem to work!
      // await driver.tap(find.pageBack());

      // Close the drawer
      // var app = find.byValueKey("App");
      // await driver.scroll(app, -300.0, 0.0, const Duration(milliseconds: 300));
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}
