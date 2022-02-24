import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dart_git/plumbing/git_hash.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/app.dart';
import 'package:gitjournal/editors/common_types.dart';
import 'package:gitjournal/editors/note_editor.dart';
import 'package:gitjournal/editors/note_title_editor.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:gitjournal/settings/app_config.dart';
import '../lib.dart';

void main() {
  final headHash = GitHash('c8a879a4a9c27abcc27a4d2ee2b2ba0aad5fc940');
  late GitJournalRepo repo;
  late RepositoryManager repoManager;
  late SharedPreferences pref;
  late String repoPath;

  setUpAll(gjSetupAllTests);

  Future<void> _setup({
    GitHash? head,
    Map<String, Object> sharedPrefValues = const {},
  }) async {
    var td = await TestData.load(
      headHash: head ?? headHash,
      sharedPrefValues: sharedPrefValues,
    );

    repo = td.repo;
    repoManager = td.repoManager;
    pref = td.pref;
    repoPath = td.repoPath;
  }

  setUp(() async {
    await _setup();
  });

  testWidgets('New Note Title as FileName', (tester) async {
    var rootFolder = repo.rootFolder;

    var widget = GitJournalChangeNotifiers(
      appConfig: AppConfig(),
      repoManager: repoManager,
      pref: pref,
      child: NoteEditor.newNote(
        rootFolder,
        rootFolder,
        EditorType.Markdown,
        existingText: "",
        existingImages: const [],
      ),
    );

    await tester.pumpWidget(MaterialApp(home: widget));
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
}
