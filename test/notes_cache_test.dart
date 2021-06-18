import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:gitjournal/core/notes_cache.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/settings/settings.dart';

void main() {
  group('Notes Cache', () {
    late Directory tempDir;
    String cacheFilePath;
    var fileList = [
      '/base/file.md',
      '/base/d1/d2/file.md',
      '/base/d5/file.md',
      '/base/d1/file.md',
    ];
    late NotesCache cache;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('__notes_test__');
      cacheFilePath = p.join(tempDir.path, "cache.raw");
      cache = NotesCache(
        filePath: cacheFilePath,
        notesBasePath: '/base',
        settings: Settings(''),
      );
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
      var rootFolder = NotesFolderFS(null, '/base', Settings(''));
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
