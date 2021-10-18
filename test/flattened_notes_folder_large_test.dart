/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:math';

import 'package:dart_git/utils/result.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart' as io;

import 'package:gitjournal/core/folder/flattened_notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/note_storage.dart';

void main() {
  group('Flattened Notes Folder Large Test', () {
    late io.Directory tempDir;
    late NotesFolderFS rootFolder;
    late NotesFolderConfig config;

    setUp(() async {
      tempDir =
          await io.Directory.systemTemp.createTemp('__flat_folder_test__');
      SharedPreferences.setMockInitialValues({});
      config = NotesFolderConfig('', await SharedPreferences.getInstance());

      var random = Random();
      for (var i = 0; i < 300; i++) {
        // print("Building Note $i");
        await _writeRandomNote(random, tempDir.path, config);
      }

      rootFolder = NotesFolderFS(null, tempDir.path, config);
      await rootFolder.loadRecursively();
    });

    tearDown(() async {
      // print("Cleaning Up TempDir: ${tempDir.path}");
      tempDir.deleteSync(recursive: true);
    });

    test('Should load all the notes flattened', () async {
      var f = FlattenedNotesFolder(rootFolder, title: "");
      expect(f.notes.length, 300);

      var tempDir = await io.Directory.systemTemp.createTemp('_test_');
      await _writeRandomNote(Random(), tempDir.path, config);

      rootFolder.reset(tempDir.path);
      await rootFolder.loadRecursively();
      expect(rootFolder.notes.length, 1);
      expect(f.notes.length, 1);
    });
  });
}

Future<void> _writeRandomNote(
    Random random, String dirPath, NotesFolderConfig config) async {
  String path;
  while (true) {
    path = p.join(dirPath, "${random.nextInt(10000)}.md");
    if (!io.File(path).existsSync()) {
      break;
    }
  }

  var parent = NotesFolderFS(null, dirPath, config);
  var note = Note.newNote(parent, fileName: p.basename(path));
  note.apply(
    modified: DateTime(2014, 1, 1 + (random.nextInt(2000))),
    body: "p1",
  );
  await NoteStorage().save(note).throwOnError();
}
