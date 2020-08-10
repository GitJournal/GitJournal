import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/utils/link_resolver.dart';

void main() {
  Directory tempDir;
  NotesFolderFS rootFolder;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('__link_resolver__');

    rootFolder = NotesFolderFS(null, tempDir.path);

    await generateNote(tempDir.path, "Hello.md");
    await generateNote(tempDir.path, "Fire.md");

    await rootFolder.loadRecursively();
  });

  tearDownAll(() async {
    tempDir.deleteSync(recursive: true);
  });

  test('Should process simple wiki links', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('[[Hello]]');
    expect(resolvedNote.filePath, p.join(tempDir.path, 'Hello.md'));
  });
}

Future<void> generateNote(String basePath, String path) async {
  var filePath = p.join(basePath, path);

  // Ensure directory exists
  var dirPath = p.basename(filePath);
  await Directory(dirPath).create(recursive: true);

  var content = """---
title:
modified: 2017-02-15T22:41:19+01:00
---

Hello""";

  return File(filePath).writeAsString(content, flush: true);
}
