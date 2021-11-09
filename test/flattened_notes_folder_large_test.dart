/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:math';

import 'package:dart_git/dart_git.dart';
import 'package:dart_git/utils/result.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart' as io;

import 'package:gitjournal/core/file/file_storage.dart';
import 'package:gitjournal/core/folder/flattened_notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/note_storage.dart';

void main() {
  group('Flattened Notes Folder Large Test', () {
    late io.Directory tempDir;
    late String repoPath;
    late NotesFolderFS rootFolder;
    late NotesFolderConfig config;
    late FileStorage fileStorage;

    setUp(() async {
      tempDir = await io.Directory.systemTemp.createTemp('__folder_large__');
      repoPath = tempDir.path + p.separator;

      SharedPreferences.setMockInitialValues({});
      config = NotesFolderConfig('', await SharedPreferences.getInstance());
      fileStorage = await FileStorage.fake(repoPath);

      var random = Random();
      for (var i = 0; i < 300; i++) {
        // print("Building Note $i");
        await _writeRandomNote(random, repoPath, config, fileStorage);
      }

      var repo = await GitRepository.load(repoPath).getOrThrow();
      await repo
          .commit(
            message: "Prepare Test Env",
            author: GitAuthor(name: 'Name', email: "name@example.com"),
            addAll: true,
          )
          .throwOnError();

      await fileStorage.reload().throwOnError();

      rootFolder = NotesFolderFS.root(config, fileStorage);
      await rootFolder.loadRecursively();
    });

    tearDown(() async {
      // print("Cleaning Up TempDir: ${repoPath}");
      tempDir.deleteSync(recursive: true);
    });

    test('Should load all the notes flattened', () async {
      var f = FlattenedNotesFolder(rootFolder, title: "");
      expect(f.notes.length, 300);

      var tempDir = await io.Directory.systemTemp.createTemp('_test_');
      var newRepoPath = tempDir.path + p.separator;

      var newFileStorage = await FileStorage.fake(newRepoPath);
      await _writeRandomNote(Random(), newRepoPath, config, newFileStorage);

      var repo = await GitRepository.load(newRepoPath).getOrThrow();
      await repo
          .commit(
            message: "Prepare Test Env",
            author: GitAuthor(name: 'Name', email: "name@example.com"),
            addAll: true,
          )
          .throwOnError();

      await newFileStorage.reload().throwOnError();

      rootFolder.reset(newFileStorage);

      await rootFolder.loadRecursively();
      expect(rootFolder.notes.length, 1);
      expect(f.notes.length, 1);
    });
  });
}

Future<void> _writeRandomNote(Random random, String dirPath,
    NotesFolderConfig config, FileStorage fileStorage) async {
  String path;
  while (true) {
    path = p.join(dirPath, "${random.nextInt(10000)}.md");
    if (!io.File(path).existsSync()) {
      break;
    }
  }

  var parent = NotesFolderFS.root(config, fileStorage);
  var note = Note.newNote(parent,
      fileName: p.basename(path), fileFormat: NoteFileFormat.Markdown);
  note.apply(
    modified: DateTime(2014, 1, 1 + (random.nextInt(2000))),
    body: "p1",
  );
  await NoteStorage().save(note).throwOnError();
}
