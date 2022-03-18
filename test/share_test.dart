/*
 * SPDX-FileCopyrightText: 2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dart_git/plumbing/git_hash.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitjournal/app.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/repository.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/change_notifiers.dart';
import 'package:gitjournal/editors/note_title_editor.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'lib.dart';

void main() {
  late GitJournalRepo repo;
  late RepositoryManager repoManager;
  late SharedPreferences pref;
  late String repoPath;

  setUpAll(gjSetupAllTests);

  Future<void> _setup(
    String head, {
    Map<String, Object> sharedPrefValues = const {},
  }) async {
    var td = await TestData.load(
      headHash: GitHash(head),
      sharedPrefValues: sharedPrefValues,
    );

    repo = td.repo;
    repoManager = td.repoManager;
    pref = td.pref;
    repoPath = td.repoPath;
  }

  Widget _buildApp() {
    return GitJournalChangeNotifiers(
      appConfig: AppConfig(),
      repoManager: repoManager,
      pref: pref,
      child: JournalApp(repoManager: repoManager),
    );
  }

  testWidgets('Sharing text works', (tester) async {
    await tester.runAsync(
      () async => await _setup('7fc65b59170bdc91013eb56cdc65fa3307f2e7de'),
    );

    // Set the custom option!
    var folderConfig = NotesFolderConfig(repoManager.currentId, pref);
    folderConfig.load();
    folderConfig.yamlHeaderEnabled = false;
    await folderConfig.save();
    repo.rootFolder.config.load();

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    // Create a fake image
    var tempDir = Directory.systemTemp.createTempSync();
    var imagePath = p.join(tempDir.path, "test-image.png");
    File(imagePath).writeAsStringSync("");

    var appState = tester.state(find.byType(JournalApp)) as JournalAppState;
    await tester.runAsync(() async {
      appState.handleSharedText("foo");
      await Future.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    var titleFinder = find.byType(NoteTitleEditor);
    expect(titleFinder, findsOneWidget);

    await tester.enterText(titleFinder, "Fake-Title");
    await tester.pump();

    await tester.runAsync(() async {
      var saveButtonFinder = find.byKey(const ValueKey('NewEntry'));
      expect(saveButtonFinder, findsOneWidget);
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(milliseconds: 100));
    });

    var file = File(p.join(repoPath, 'Fake-Title.md'));
    expect(file.existsSync(), true);
    expect(file.readAsStringSync(), "foo\n");
  });
}
