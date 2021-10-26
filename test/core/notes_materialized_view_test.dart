/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:io' as io;
import 'dart:math';

import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import 'package:gitjournal/core/file/file.dart';
import 'package:gitjournal/core/file/file_storage.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/note_storage.dart';
import 'package:gitjournal/core/transformers/base.dart';
import 'package:gitjournal/core/views/notes_materialized_view.dart';

void main() {
  group('ViewTest', () {
    late String repoPath;
    late io.Directory tempDir;
    late NotesFolderConfig config;
    late FileStorage fileStorage;

    setUpAll(() async {
      tempDir = await io.Directory.systemTemp.createTemp('__notes_test__');
      repoPath = tempDir.path + p.separator;

      SharedPreferences.setMockInitialValues({});
      config = NotesFolderConfig('', await SharedPreferences.getInstance());

      var cacheDir = await io.Directory.systemTemp.createTemp('cache');
      Hive.init(cacheDir.path);

      fileStorage = await FileStorage.fake(repoPath);
    });

    Future<Note> _createExampleNote() async {
      var content = """---
bar: Foo
updated: 1626257689
created: 1626257689
---

Hello
""";

      var notePath = p.join(tempDir.path, "note.md");
      await io.File(notePath).writeAsString(content);

      var parentFolder = NotesFolderFS.root(config, fileStorage);
      var noteStorage = NoteStorage();
      var file = File.short("note.md", repoPath);
      var noteR = await noteStorage.load(file, parentFolder);
      return noteR.getOrThrow();
    }

    test('Test', () async {
      var random = Random().nextInt(10000).toString();
      Future<String> compute(Note note) async {
        return random;
      }

      var view = NotesMaterializedView<String>(
        name: '_test_box',
        computeFn: compute,
        repoPath: tempDir.path,
      );
      var note = await _createExampleNote();

      expect(await view.fetch(note), random);
    });
  });
}
