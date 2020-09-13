import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:screenshots/screenshots.dart';

import 'isolates_workaround.dart';

void main() {
  group('Test', () {
    FlutterDriver driver;
    IsolatesWorkaround workaround;

    int screenshotNum = 0;
    final config = Config();

    // Connect to the Flutter driver before running any tests
    setUpAll(() async {
      driver = await FlutterDriver.connect();
      workaround = IsolatesWorkaround(driver);
      await workaround.resumeIsolates();

      await Future.delayed(const Duration(seconds: 15));
    });

    // Close the connection to the driver after the tests have completed
    tearDownAll(() async {
      if (driver != null) {
        await driver.close();
        await workaround.tearDown();
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

    Future<void> waitFor(SerializableFinder finder) async {
      try {
        await driver.waitFor(finder, timeout: const Duration(seconds: 15));
      } catch (e, st) {
        print(e);
        print(st);
        await screenshot(driver, config, "error");

        assert(false, "failed to find $finder");
      }
    }
    // FIXME: make waiting for common and comptuer a screenshot on exception

    test('Normal Flow', () async {
      // OnBoarding
      var nextButton = find.text("Next");
      await waitFor(nextButton);
      await _takeScreenshot();
      await driver.tap(nextButton);

      // Page 2
      await _takeScreenshot();
      await driver.tap(nextButton);

      // Page 3
      // await _takeScreenshot();
      await driver.tap(find.byValueKey("GetStarted"));

      // Main Screen
      //final loadedFinder = find.text("Let's add some notes?");
      // await driver.waitFor(loadedFinder, timeout: const Duration(seconds: 15));
      // await _takeScreenshot();

      // Create a new note
      var fab = find.byValueKey("FAB");
      await waitFor(fab);
      await driver.tap(fab);
      await waitFor(find.text('Write here'));
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
      await waitFor(rawEditor);
      await driver.tap(rawEditor);
      await Future.delayed(const Duration(milliseconds: 100));
      await _takeScreenshot();

      // Journal Editor
      await driver.tap(editorSelector);
      var journalEditor = find.text("Journal Editor");
      await waitFor(journalEditor);
      await driver.tap(journalEditor);
      await Future.delayed(const Duration(milliseconds: 100));
      await _takeScreenshot();

      // Go Back to home screen
      await driver.tap(find.byValueKey("NewEntry"));

      // Create another note
      await waitFor(fab);
      await driver.tap(fab);
      await waitFor(find.text('Write here'));

      await driver.enterText(
          "Taking Notes is a great way to clear your mind and get all your throughts down into paper. Well, not literal paper, as this is an app, but I think you get the point.");
      await _takeScreenshot();
      await driver.tap(find.byValueKey("NewEntry"));

      await Future.delayed(const Duration(milliseconds: 100));
      await _takeScreenshot();

      // Create yet another note
      await waitFor(fab);
      await driver.tap(fab);
      await waitFor(find.text('Write here'));

      await driver.enterText("Is this real life?");
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
      var cardView = find.text("Card View");
      await waitFor(cardView);
      await driver.tap(cardView);
      await Future.delayed(const Duration(milliseconds: 100));
      await _takeScreenshot();

      // Select Journal View
      await driver.tap(folderViewSelector);
      var journalView = find.text("Journal View");
      await waitFor(journalView);
      await driver.tap(journalView);
      await Future.delayed(const Duration(milliseconds: 100));
      await _takeScreenshot();

      // Select Grid View
      await driver.tap(folderViewSelector);
      var gridView = find.text("Grid View");
      await waitFor(gridView);
      await driver.tap(gridView);
      await Future.delayed(const Duration(milliseconds: 100));
      await _takeScreenshot();

      // Select the Checklist
      var checklist = find.text("Shopping List");
      await waitFor(checklist);
      await driver.tap(checklist);
      await Future.delayed(const Duration(milliseconds: 100));
      await _takeScreenshot();
      await driver.tap(find.byValueKey("NewEntry"));

      // Open the Drawer
      final drawerButtonFinder = find.byValueKey("DrawerButton");
      await driver.tap(drawerButtonFinder);
      await Future.delayed(const Duration(milliseconds: 100));
      await _takeScreenshot();

      // Folders View
      var foldersButon = find.text("Folders");
      await waitFor(foldersButon);
      await driver.tap(foldersButon);

      var rootFolder = find.text("Root Folder");
      await waitFor(rootFolder);
      await _takeScreenshot();

      // Open the Drawer
      await driver.tap(drawerButtonFinder);
      await Future.delayed(const Duration(milliseconds: 100));
      await _takeScreenshot();

      // The Git Host setup screen
      await driver.tap(find.text("Setup Git Host"));
      await waitFor(find.text("GitHub"));
      await _takeScreenshot();
      // FIXME: This doesn't seem to work!
      // await driver.tap(find.pageBack());

      // Close the drawer
      // var app = find.byValueKey("App");
      // await driver.scroll(app, -300.0, 0.0, const Duration(milliseconds: 300));
    }, timeout: const Timeout(Duration(minutes: 20)));
  });
}
