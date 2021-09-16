// SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

/*

import 'package:test/test.dart';
import 'package:time/time.dart';

void main() {
  group('Test', () {
    FlutterDriver driver;

    int screenshotNum = 0;
    final config = Config();

    // Connect to the Flutter driver before running any tests
    setUpAll(() async {
      driver = await FlutterDriver.connect();

      await Future.delayed(15.seconds);
    });

    Future _takeScreenshot() async {
      screenshotNum += 1;
      await screenshot(driver, config, screenshotNum.toString());
    }

    Future<void> waitFor(SerializableFinder finder) async {
      try {
        await driver.waitFor(finder, timeout: 15.seconds);
      } catch (e, st) {
        print(e);
        print(st);
        await screenshot(driver, config, "error");

        assert(false, "failed to find $finder");
      }
    }
    // FIXME: make waiting for common and comptuer a screenshot on exception

    test('Normal Flow', () async {
      var delay = 100.milliseconds;

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
      await Future.delayed(delay);
      await _takeScreenshot();

      // Raw Edtitor
      var rawEditor = find.text("Raw Editor");
      await waitFor(rawEditor);
      await driver.tap(rawEditor);
      await Future.delayed(delay);
      await _takeScreenshot();

      // Journal Editor
      await driver.tap(editorSelector);
      var journalEditor = find.text("Journal Editor");
      await waitFor(journalEditor);
      await driver.tap(journalEditor);
      await Future.delayed(delay);
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

      await Future.delayed(delay);
      await _takeScreenshot();

      // Create yet another note
      await waitFor(fab);
      await driver.tap(fab);
      await waitFor(find.text('Write here'));

      await driver.enterText("Is this real life?");
      await _takeScreenshot();
      await driver.tap(find.byValueKey("NewEntry"));

      await Future.delayed(delay);
      await _takeScreenshot();

      // Capture Standard View's Sorting Options
      var popUpMenu = find.byValueKey("PopupMenu");
      await waitFor(popUpMenu);
      await driver.tap(popUpMenu);

      var sortingOptions = find.byValueKey("SortingOptions");
      await waitFor(sortingOptions);
      await _takeScreenshot();
      await driver.tap(sortingOptions);

      var sortingOptionsCancel = find.byValueKey("Cancel");
      await waitFor(sortingOptionsCancel);

      await _takeScreenshot();
      await driver.tap(sortingOptionsCancel);

      // StandardView's View Settings
      await waitFor(popUpMenu);
      await driver.tap(popUpMenu);

      var viewOptions = find.byValueKey("ViewOptions");
      await waitFor(viewOptions);
      await driver.tap(viewOptions);

      var viewOptionsDialog = find.byValueKey("ViewOptionsDialog");
      await waitFor(viewOptionsDialog);
      await _takeScreenshot();

      var showSummary = find.byValueKey("SummaryToggle");
      await waitFor(showSummary);
      await driver.tap(showSummary);

      var fileNameSel = find.byValueKey("ShowFileNameOnly");
      await waitFor(fileNameSel);
      await _takeScreenshot();
      await driver.tap(fileNameSel);

      // Remove the Dialog
      var barrier = find.byValueKey('Hack_Back');
      await waitFor(barrier);
      await driver.tap(barrier);

      // Folder View Selector
      print("Taking Screenshots of FolderViewSelector");
      var folderViewSelector = find.byValueKey("FolderViewSelector");
      await waitFor(folderViewSelector);
      await _takeScreenshot();

      await driver.tap(folderViewSelector);
      await Future.delayed(delay);
      await _takeScreenshot();

      // Select Card View
      var cardView = find.text("Card View");
      await waitFor(cardView);
      await driver.tap(cardView);
      await Future.delayed(delay);
      await _takeScreenshot();

      // Select Journal View
      await driver.tap(folderViewSelector);
      var journalView = find.text("Journal View");
      await waitFor(journalView);
      await driver.tap(journalView);
      await Future.delayed(delay);
      await _takeScreenshot();

      // Select Grid View
      await driver.tap(folderViewSelector);
      var gridView = find.text("Grid View");
      await waitFor(gridView);
      await driver.tap(gridView);
      await Future.delayed(delay);
      await _takeScreenshot();

      // Select the Checklist
      var checklist = find.text("Shopping List");
      await waitFor(checklist);
      await driver.tap(checklist);
      await Future.delayed(delay);
      await _takeScreenshot();
      await driver.tap(find.byValueKey("NewEntry"));

      // Open the Drawer
      final drawerButtonFinder = find.byValueKey("DrawerButton");
      await driver.tap(drawerButtonFinder);
      await Future.delayed(delay);
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
      await Future.delayed(delay);
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
    }, timeout: Timeout(20.minutes));
  });
}
*/
