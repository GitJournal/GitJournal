/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:collection';

import 'package:dart_git/utils/result.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart' as io;

import 'package:gitjournal/core/file/file.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/md_yaml_doc.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/note_serializer.dart';
import 'package:gitjournal/core/note_storage.dart';
import 'package:gitjournal/utils/datetime.dart';

void main() {
  group('NoteStorage', () {
    var notes = <Note>[];
    late String n1Path;
    late String n2Path;
    late io.Directory tempDir;
    late NotesFolderConfig config;

    setUpAll(() async {
      tempDir = await io.Directory.systemTemp.createTemp('__storage_test__');
      SharedPreferences.setMockInitialValues({});
      config = NotesFolderConfig('', await SharedPreferences.getInstance());

      var dt = DateTime(2019, 12, 2, 5, 4, 2);
      // ignore: prefer_collection_literals
      var props = LinkedHashMap<String, dynamic>();
      props['created'] = toIso8601WithTimezone(dt);

      n1Path = p.join(tempDir.path, "1.md");
      n2Path = p.join(tempDir.path, "2.md");

      var parent = NotesFolderFS(null, tempDir.path, config);
      var n1 = Note.newNote(parent, fileName: "1.md");
      n1.apply(created: dt, body: "test\n");

      var n2 = Note.newNote(parent, fileName: "2.md");
      n2 = NoteSerializer.decodeNote(
        data: MdYamlDoc(body: "test2\n", props: props),
        parent: n2.parent,
        file: n2.file,
        settings: n2.noteSerializer.settings,
      );

      notes = [n1, n2];
    });

    tearDownAll(() async {
      tempDir.deleteSync(recursive: true);
    });

    test('Should persist and load Notes from disk', () async {
      for (var note in notes) {
        await NoteStorage().save(note).throwOnError();
      }
      expect(tempDir.listSync(recursive: true).length, 2);
      expect(io.File(n1Path).existsSync(), isTrue);
      expect(io.File(n2Path).existsSync(), isTrue);

      var loadedNotes = <Note>[];
      var parent = NotesFolderFS(null, tempDir.path, config);
      var storage = NoteStorage();

      for (var origNote in notes) {
        var file = File.short(origNote.filePath);
        var note = await storage.load(file, parent).getOrThrow();

        loadedNotes.add(note);
      }

      sortFn(Note n1, Note n2) => n1.filePath.compareTo(n2.filePath);
      loadedNotes.sort(sortFn);
      notes.sort(sortFn);

      expect(loadedNotes, notes);

      for (var note in notes) {
        await io.File(note.filePath).delete();
      }
      expect(tempDir.listSync(recursive: true).length, 0);
      expect(io.File(n1Path).existsSync(), isFalse);
      expect(io.File(n2Path).existsSync(), isFalse);
    });
  });
}
