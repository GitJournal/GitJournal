/*
 * SPDX-FileCopyrightText: 2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dart_git/git.dart';
import 'package:dart_git/plumbing/git_hash.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/change_notifiers.dart';
import 'package:gitjournal/editors/common_types.dart';
import 'package:gitjournal/editors/note_body_editor.dart';
import 'package:gitjournal/editors/note_editor.dart';
import 'package:gitjournal/editors/note_title_editor.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:gitjournal/settings/app_config.dart';
import '../lib.dart';

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

  Widget _buildApp(Widget widget) {
    EasyLocalization.logger.enableLevels = [];

    return GitJournalChangeNotifiers(
      appConfig: AppConfig(),
      repoManager: repoManager,
      pref: pref,
      child: MaterialApp(
        home: widget,
      ),
    );
  }

  testWidgets('New Note Title as FileName', (tester) async {
    await tester.runAsync(
      () async => await _setup('7fc65b59170bdc91013eb56cdc65fa3307f2e7de'),
    );

    var widget = NoteEditor.newNote(
      repo.rootFolder,
      repo.rootFolder,
      EditorType.Markdown,
      existingText: "",
      existingImages: const [],
    );

    await tester.pumpWidget(_buildApp(widget));
    await tester.pumpAndSettle();

    var titleFinder = find.byType(NoteTitleEditor);
    expect(titleFinder, findsOneWidget);

    await tester.enterText(titleFinder, "Fake-Title");
    await tester.pump();

    var saveButtonFinder = find.byKey(const ValueKey('NewEntry'));
    expect(saveButtonFinder, findsOneWidget);

    await tester.tap(saveButtonFinder);
    await tester.pumpAndSettle();
    await tester.pumpAndSettle(const Duration(seconds: 1));

    var file = File(p.join(repoPath, 'Fake-Title.md'));
    expect(file.existsSync(), true);
  });

  testWidgets('Existing Note Rename and Exit', (tester) async {
    await tester.runAsync(
      () async => await _setup('7fc65b59170bdc91013eb56cdc65fa3307f2e7de'),
    );

    // FIXME: Use a proper size of a mobile, also set the DPI
    tester.binding.window.physicalSizeTestValue = const Size(10800, 23400);
    await tester.pumpAndSettle();

    var note = repo.rootFolder.getNoteWithSpec('doc.md')!;
    var widget = NoteEditor.fromNote(note, repo.rootFolder);

    await tester.pumpWidget(_buildApp(widget));
    await tester.pumpAndSettle();

    // Rename the note
    var menuButton = find.byIcon(Icons.more_vert);
    expect(menuButton, findsOneWidget);
    await tester.tap(menuButton);
    await tester.pumpAndSettle();

    var editFileNameButton = find.byKey(const ValueKey('EditFileNameButton'));
    expect(editFileNameButton, findsOneWidget);
    await tester.tap(editFileNameButton);
    await tester.pumpAndSettle();

    var dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);

    await tester.showKeyboard(dialog);
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(text: 'bugs.md'),
    );

    var renameButton = find.byKey(const ValueKey('RenameYes'));
    expect(renameButton, findsOneWidget);
    await tester.tap(renameButton);
    await tester.pumpAndSettle();

    // Exit the editor
    await tester.runAsync(() async {
      var saveButtonFinder = find.byKey(const ValueKey('NewEntry'));
      expect(saveButtonFinder, findsOneWidget);
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(milliseconds: 100));
    });

    // Check the FileSystem
    expect(File(p.join(repoPath, 'doc.md')).existsSync(), false);
    expect(File(p.join(repoPath, 'bugs.md')).existsSync(), true);

    // Check the rootFolder
    expect(repo.rootFolder.getNoteWithSpec('doc.md'), null);
    expect(repo.rootFolder.getNoteWithSpec('bugs.md'), isNotNull);
    expect(repo.rootFolder.getAllNotes().length, 5);

    // Check the view
    var saveButtonFinder = find.byKey(const ValueKey('NewEntry'));
    expect(saveButtonFinder, findsNothing);
  });

  testWidgets('Existing Note not modified', (tester) async {
    var headHash = '7fc65b59170bdc91013eb56cdc65fa3307f2e7de';
    await tester.runAsync(
      () async => await _setup(headHash),
    );

    // FIXME: Use a proper size of a mobile, also set the DPI
    tester.binding.window.physicalSizeTestValue = const Size(10800, 23400);
    await tester.pumpAndSettle();

    var note = repo.rootFolder.getNoteWithSpec('doc.md')!;
    var widget = NoteEditor.fromNote(note, repo.rootFolder);

    await tester.pumpWidget(_buildApp(widget));
    await tester.pumpAndSettle();

    // Change the text
    var bodyEditor = find.byType(NoteBodyEditor);
    expect(bodyEditor, findsOneWidget);

    await tester.showKeyboard(bodyEditor);
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(text: '200 mgs of x\n'),
    );
    await tester.pumpAndSettle();

    // expect(find.byIcon(Icons.close), findsOneWidget);
    // expect(find.byIcon(Icons.check), findsNothing);

    late Finder saveButtonFinder;
    saveButtonFinder = find.byKey(const ValueKey('NewEntry'));
    expect(saveButtonFinder, findsOneWidget);

    // Exit the editor
    await tester.runAsync(() async {
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(milliseconds: 1000));
    });
    await tester.pumpAndSettle();

    // Check the view
    saveButtonFinder = find.byKey(const ValueKey('NewEntry'));
    expect(saveButtonFinder, findsNothing);

    // Ensure nothing has changed
    var gitRepo = GitRepository.load(repo.repoPath).getOrThrow();
    expect(gitRepo.headHash().getOrThrow(), GitHash(headHash));
  });

  testWidgets('Editing a Note body with a heading', (tester) async {
    await tester.runAsync(
      () async => await _setup('fef4ef7341751cb583d768dc9a6b13deca552954'),
    );

    // FIXME: Use a proper size of a mobile, also set the DPI
    tester.binding.window.physicalSizeTestValue = const Size(10800, 23400);
    await tester.pumpAndSettle();

    // Open the note
    var note = repo.rootFolder.getNoteWithSpec('heading.md')!;
    var noteHash = GitHash('737943ab9672d967afa91641207a9a3592a522bf');
    var widget = NoteEditor.fromNote(note, repo.rootFolder);
    expect(note.oid, noteHash);

    await tester.pumpWidget(_buildApp(widget));
    await tester.pumpAndSettle();

    // Make a modification to the body
    var dialog = find.byType(NoteBodyEditor);

    await tester.showKeyboard(dialog);
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(text: '# dbg2e\n#dbg3'),
    );

    await tester.runAsync(() async {
      // Save the Note
      var saveButtonFinder = find.byKey(const ValueKey('NewEntry'));
      expect(saveButtonFinder, findsOneWidget);
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      // FIXME: Can this be avoided?
      await Future.delayed(const Duration(milliseconds: 100));
    });

    note = repo.rootFolder.getNoteWithSpec('heading.md')!;

    expect(note.oid, isNot(noteHash));
    expect(note.title, "dbg1");
    expect(note.body, '# dbg2e\n#dbg3');
  });
}
