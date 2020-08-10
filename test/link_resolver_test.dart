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
    await generateNote(tempDir.path, "Folder/Water.md");
    await generateNote(tempDir.path, "Air Bender.md");
    await generateNote(tempDir.path, "zeplin.txt");

    await rootFolder.loadRecursively();
  });

  tearDownAll(() async {
    tempDir.deleteSync(recursive: true);
  });

  test('[[Fire]] resolves to base folder `Fire.md`', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('[[Fire]]');
    expect(resolvedNote.filePath, p.join(tempDir.path, 'Fire.md'));
  });

  test('[[Fire.md]] resolves to base folder `Fire.md`', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('[[Fire.md]]');
    expect(resolvedNote.filePath, p.join(tempDir.path, 'Fire.md'));
  });

  test('[[Folder/Water]] resolves to `Folder/Water.md`', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('[[Folder/Water]]');
    expect(resolvedNote.filePath, p.join(tempDir.path, 'Folder/Water.md'));
  });

  test('WikiLinks with spaces resolves correctly', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('[[Air Bender]]');
    expect(resolvedNote.filePath, p.join(tempDir.path, 'Air Bender.md'));
  });

  test('WikiLinks with extra spaces resolves correctly', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('[[Hello ]]');
    expect(resolvedNote.filePath, p.join(tempDir.path, 'Hello.md'));
  });

  test('Resolves to txt files as well', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('[[zeplin]]');
    expect(resolvedNote.filePath, p.join(tempDir.path, 'zeplin.txt'));
  });

  test('Non base path [[Fire]] should resolve to [[Fire.md]]', () {
    var note = rootFolder.getNoteWithSpec('Folder/Water.md');
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('[[Fire]]');
    expect(resolvedNote.filePath, p.join(tempDir.path, 'Fire.md'));
  });
}

Future<void> generateNote(String basePath, String path) async {
  var filePath = p.join(basePath, path);

  // Ensure directory exists
  var dirPath = p.dirname(filePath);
  await Directory(dirPath).create(recursive: true);

  var content = """---
title:
modified: 2017-02-15T22:41:19+01:00
---

Hello""";

  return File(filePath).writeAsString(content, flush: true);
}

// Test to write
// 8. Non base path [[Fire]] should resolve to [[Fire.md]]

// Normal Links
// 4. ./Fire.md -> resovles
// 5. Fire.md -> resolves
// 6. Fire2.md -> fails to resolve
// 7. Complex path ../../Foo/../bar/d.md
