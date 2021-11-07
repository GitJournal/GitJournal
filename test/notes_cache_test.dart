/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart' as io;

import 'package:gitjournal/core/file/file.dart';
import 'package:gitjournal/core/file/file_storage.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/notes_cache.dart';

void main() {
  group('Notes Cache', () {
    late io.Directory tempDir;
    var fileList = <File>[];
    late NotesCache cache;
    late NotesFolderConfig config;
    late String repoPath;
    late FileStorage fileStorage;

    setUp(() async {
      tempDir = await io.Directory.systemTemp.createTemp('__notes_test__');
      repoPath = tempDir.path + p.separator;

      SharedPreferences.setMockInitialValues({});
      config = NotesFolderConfig('', await SharedPreferences.getInstance());

      fileStorage = await FileStorage.fake(tempDir.path);

      var d1 = "d1";
      var d2 = p.join("d1", 'd2');
      var d5 = "d5";

      cache = NotesCache(
        folderPath: tempDir.path,
        repoPath: repoPath,
        fileStorage: fileStorage,
      );

      await io.Directory(p.join(repoPath, d1)).create(recursive: true);
      await io.Directory(p.join(repoPath, d2)).create(recursive: true);
      await io.Directory(p.join(repoPath, d5)).create(recursive: true);

      fileList = [
        File.short("file.md", repoPath),
        File.short(p.join(d2, "file.md"), repoPath),
        File.short(p.join(d5, "file.md"), repoPath),
        File.short(p.join(d1, "file.md"), repoPath),
      ];

      for (var file in fileList) {
        await io.File(file.fullFilePath).writeAsString("foo");
      }
    });

    tearDown(() async {
      tempDir.deleteSync(recursive: true);
    });

    test('Should load list correctly', () async {
      var loadedList = await cache.loadFromDisk();
      expect(loadedList.length, 0);

      await cache.saveToDisk(fileList);

      loadedList = await cache.loadFromDisk();
      expect(loadedList, fileList);
    });

    test('Should create directory structure accurately', () async {
      await cache.saveToDisk(fileList);
      var rootFolder = NotesFolderFS.root(config, fileStorage);
      await cache.load(rootFolder);

      expect(rootFolder.subFolders.length, 2);
      expect(rootFolder.notes.length, 1);

      // d1
      var folder = rootFolder.subFolders[0];
      expect(folder.subFolders.length, 1);
      expect(folder.notes.length, 1);

      // d1/d2
      folder = rootFolder.subFolders[0].subFolders[0];
      expect(folder.subFolders.length, 0);
      expect(folder.notes.length, 1);

      // d6
      folder = rootFolder.subFolders[1];
      expect(folder.subFolders.length, 0);
      expect(folder.notes.length, 1);
    });
  });
}
