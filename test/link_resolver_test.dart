import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:gitjournal/core/link.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils/link_resolver.dart';

void main() {
  Directory tempDir;
  NotesFolderFS rootFolder;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('__link_resolver__');

    rootFolder = NotesFolderFS(null, tempDir.path, Settings());

    await generateNote(tempDir.path, "Hello.md");
    await generateNote(tempDir.path, "Fire.md");
    await generateNote(tempDir.path, "Kat.md");
    await generateNote(tempDir.path, "Folder/Water.md");
    await generateNote(tempDir.path, "Folder/Kat.md");
    await generateNote(tempDir.path, "Folder/Sodium.md");
    await generateNote(tempDir.path, "Folder/Boy.md");
    await generateNote(tempDir.path, "Folder2/Boy.md");
    await generateNote(tempDir.path, "Air Bender.md");
    await generateNote(tempDir.path, "zeplin.txt");
    await generateNote(tempDir.path, "Goat  Sim.md");

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

  test('[[Water]] resolves to `Folder/Water.md`', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('[[Water]]');
    expect(resolvedNote.filePath, p.join(tempDir.path, 'Folder/Water.md'));
  });

  test('[[Boy]] resolves to `Folder/Boy.md`', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    // Make sure if there are 2 Notes with the same name, the first one is resolved
    var resolvedNote = linkResolver.resolve('[[Boy]]');
    expect(resolvedNote.filePath, p.join(tempDir.path, 'Folder/Boy.md'));
  }, skip: true);

  test('[[Kat]] resolves to `Kat.md`', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    // Make sure if there are multiple Notes with the same name, the one is the
    // base directory is preffered
    var resolvedNote = linkResolver.resolve('[[Kat]]');
    expect(resolvedNote.filePath, p.join(tempDir.path, 'Kat.md'));
  }, skip: true);

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

  test('Non existing wiki link fails', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('[[Hello2]]');
    expect(resolvedNote, null);
  });

  test('WikiLinks with extra spaces in the middle resolves correctly', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('[[Goat  Sim]]');
    expect(resolvedNote.filePath, p.join(tempDir.path, 'Goat  Sim.md'));
  });

  test('Normal relative link', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('./Hello.md');
    expect(resolvedNote.filePath, p.join(tempDir.path, 'Hello.md'));
  });

  test('Normal relative link inside a subFolder', () {
    var note = rootFolder.getNoteWithSpec('Folder/Water.md');
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('./Sodium.md');
    expect(resolvedNote.filePath, p.join(tempDir.path, 'Folder/Sodium.md'));
  });

  test('Normal relative link without ./', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('Hello.md');
    expect(resolvedNote.filePath, p.join(tempDir.path, 'Hello.md'));
  });

  test('Non existing relative link fails', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('Hello2.md');
    expect(resolvedNote, null);
  });

  test('Complex relative link', () {
    var note = rootFolder.notes[0];
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('./Air Bender/../Goat  Sim.md');
    expect(resolvedNote.filePath, p.join(tempDir.path, 'Goat  Sim.md'));
  });

  test('Resolve Parent file', () {
    var note = rootFolder.getNoteWithSpec('Folder/Water.md');
    var linkResolver = LinkResolver(note);

    var resolvedNote = linkResolver.resolve('../Hello.md');
    expect(resolvedNote.filePath, p.join(tempDir.path, 'Hello.md'));
  });

  test('Should resolve Link object', () {
    var note = rootFolder.getNoteWithSpec('Folder/Water.md');
    var linkResolver = LinkResolver(note);

    var expectedNote = rootFolder.getNoteWithSpec('Fire.md');
    var link = Link(
      filePath: expectedNote.filePath,
      publicTerm: 'foo',
    );

    var resolvedNote = linkResolver.resolveLink(link);
    expect(resolvedNote.filePath, expectedNote.filePath);
  });

  test('Should resolve Link object without extension', () {
    var note = rootFolder.getNoteWithSpec('Folder/Water.md');
    var linkResolver = LinkResolver(note);

    var expectedNote = rootFolder.getNoteWithSpec('Fire.md');
    var filePath = expectedNote.filePath;
    filePath = filePath.substring(0, filePath.length - 3);
    var link = Link(filePath: filePath, publicTerm: 'foo');

    var resolvedNote = linkResolver.resolveLink(link);
    expect(resolvedNote.filePath, expectedNote.filePath);
  });

  test('Should resolve Wiki Link object', () {
    var note = rootFolder.getNoteWithSpec('Folder/Water.md');
    var linkResolver = LinkResolver(note);

    var link = Link.wiki("Fire");
    var resolvedNote = linkResolver.resolveLink(link);
    expect(resolvedNote.fileName, "Fire.md");
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
