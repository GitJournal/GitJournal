/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';

import 'package:dart_date/dart_date.dart';
import 'package:dart_git/dart_git.dart';
import 'package:dart_git/utils/date_time.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart' as io;

import 'package:gitjournal/core/file/file.dart';
import 'package:gitjournal/core/file/file_storage.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/markdown/md_yaml_doc.dart';
import 'package:gitjournal/core/markdown/md_yaml_note_serializer.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/note_storage.dart';
import 'package:gitjournal/utils/datetime.dart';

GitHash _compute(String s) => GitHash.compute(utf8.encode(s));

void main() {
  group('NoteStorage', () {
    var notes = <Note>[];
    late String n1Path;
    late String n2Path;
    late String repoPath;
    late io.Directory tempDir;
    late NotesFolderConfig config;
    late FileStorage fileStorage;

    final gitDt = Date.startOfToday;

    setUpAll(() async {
      tempDir = await io.Directory.systemTemp.createTemp('__storage_test__');
      repoPath = tempDir.path + p.separator;

      SharedPreferences.setMockInitialValues({});
      config = NotesFolderConfig('', await SharedPreferences.getInstance());

      fileStorage = await FileStorage.fake(repoPath);

      var dt = GDateTime.utc(2019, 12, 2, 5, 4, 2);
      var props = IMap<String, dynamic>({
        'created': toIso8601WithTimezone(dt),
      });

      n1Path = p.join(repoPath, "1.md");
      n2Path = p.join(repoPath, "2.md");

      var parent = NotesFolderFS.root(config, fileStorage);

      var n1 = Note.newNote(parent,
          fileName: "1.md", fileFormat: NoteFileFormat.Markdown);
      n1 = n1.copyWith(
        created: dt,
        body: "test\n",
        file: File.short(n1.filePath, repoPath, gitDt),
      );
      n1 = n1.copyWith(file: n1.file.copyFile(oid: _compute(n1.body)));

      var n2 = Note.newNote(parent,
          fileName: "2.md", fileFormat: NoteFileFormat.Markdown);
      n2 = n2.copyWith(file: File.short(n2.filePath, repoPath, gitDt));
      n2 = n2.copyWith(file: n2.file.copyFile(oid: _compute(n2.body)));
      n2 = NoteSerializer.decodeNote(
        data: MdYamlDoc(body: "test2\n", props: props),
        parent: n2.parent,
        file: n2.file,
        settings: n2.noteSerializer.settings,
        fileFormat: NoteFileFormat.Markdown,
      );

      notes = [n1, n2];

      var repo = GitRepository.load(tempDir.path).getOrThrow();
      repo
          .commit(
            message: "Prepare Test Env",
            author: GitAuthor(name: 'Name', email: "name@example.com"),
            addAll: true,
          )
          .throwOnError();

      await parent.fileStorage.reload().throwOnError();
    });

    tearDownAll(() async {
      tempDir.deleteSync(recursive: true);
    });

    test('Should persist and load Notes from disk', () async {
      for (var note in notes) {
        note = note.resetOid();
        await NoteStorage.save(note).throwOnError();
      }

      var fileList = tempDir
          .listSync(recursive: true)
          .where((e) => !e.path.contains('.git'))
          .toList();
      expect(fileList.length, 2);
      expect(io.File(n1Path).existsSync(), isTrue);
      expect(io.File(n2Path).existsSync(), isTrue);

      var loadedNotes = <Note>[];
      var parent = NotesFolderFS.root(config, fileStorage);

      for (var origNote in notes) {
        var note = await NoteStorage.load(origNote.file, parent).getOrThrow();
        loadedNotes.add(note);
      }

      sortFn(Note n1, Note n2) => n1.filePath.compareTo(n2.filePath);
      loadedNotes.sort(sortFn);
      notes.sort(sortFn);

      expect(loadedNotes[0].title, notes[0].title);
      expect(loadedNotes[0].body, notes[0].body);
      expect(loadedNotes[0].filePath, notes[0].filePath);
      expect(loadedNotes[0].parent.folderPath, notes[0].parent.folderPath);
      expect(loadedNotes[0].file, notes[0].file);
      expect(loadedNotes[0], notes[0]);

      expect(loadedNotes[1], notes[1]);
      expect(loadedNotes, notes);

      for (var note in notes) {
        await io.File(note.fullFilePath).delete();
      }
      fileList = tempDir
          .listSync(recursive: true)
          .where((e) => !e.path.contains('.git'))
          .toList();
      expect(fileList.length, 0);
      expect(io.File(n1Path).existsSync(), isFalse);
      expect(io.File(n2Path).existsSync(), isFalse);
    });
  });
}
