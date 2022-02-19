/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

import 'package:gitjournal/core/file/file.dart';
import 'package:gitjournal/core/file/file_storage.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/markdown/md_yaml_doc.dart';
import 'package:gitjournal/core/markdown/md_yaml_note_serializer.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/settings/settings.dart';
import 'lib.dart';

void main() {
  setUpAll(gjSetupAllTests);

  group('Note Serializer Test', () {
    late String repoPath;
    late NotesFolderConfig config;
    late NotesFolderFS parent;
    late FileStorage fileStorage;

    final gitDt = DateTime.now();

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      config = NotesFolderConfig('', await SharedPreferences.getInstance());

      var tempDir = await Directory.systemTemp.createTemp('__link_resolver__');
      repoPath = tempDir.path + p.separator;

      fileStorage = await FileStorage.fake(repoPath);
      parent = NotesFolderFS.root(config, fileStorage);
    });

    test('Test emojis', () {
      var props = IMap<String, dynamic>(
          const <String, dynamic>{"title": "Why not :coffee:?"});
      var doc = MdYamlDoc(body: "I :heart: you", props: props);

      var serializer = NoteSerializer.raw();
      serializer.settings.emojify = true;
      serializer.settings.titleSettings = SettingsTitle.InYaml;

      var file = File.short("file-path-not-important", repoPath, gitDt);
      var note = serializer.decode(
        data: doc,
        parent: parent,
        file: file,
        fileFormat: NoteFileFormat.Markdown,
      );

      expect(note.body, "I ❤️ you");
      expect(note.title, "Why not ☕?");

      note = note.copyWith(body: "Why not ☕?", title: "I ❤️ you");

      doc = serializer.encode(note);
      expect(doc.body, "Why not :coffee:?");
      expect(doc.props['title'].toString(), "I :heart: you");
    });

    test('Test Title Serialization', () {
      var props = IMap<String, dynamic>(const {});
      var doc =
          MdYamlDoc(body: "# Why not coffee?\n\nI heart you", props: props);

      var serializer = NoteSerializer.raw();
      serializer.settings.titleSettings = SettingsTitle.InH1;

      var file = File.short("file-path-not-important", repoPath, gitDt);
      var note = serializer.decode(
        data: doc,
        parent: parent,
        file: file,
        fileFormat: NoteFileFormat.Markdown,
      );

      expect(note.body, "I heart you");
      expect(note.title, "Why not coffee?");

      note = note.copyWith(body: "Why not coffee?", title: "I heart you");

      doc = serializer.encode(note);
      expect(doc.body, "# I heart you\n\nWhy not coffee?");
      expect(doc.props.length, 0);
    });

    test('Test Title Reading with blank lines', () {
      var props = IMap<String, dynamic>(const {});
      var doc =
          MdYamlDoc(body: "\n# Why not coffee?\n\nI heart you", props: props);

      var serializer = NoteSerializer.raw();

      var file = File.short("file-path-not-important", repoPath, gitDt);
      var note = serializer.decode(
        data: doc,
        parent: parent,
        file: file,
        fileFormat: NoteFileFormat.Markdown,
      );

      expect(note.body, "I heart you");
      expect(note.title, "Why not coffee?");
    });

    test('Test Title Reading with blank lines and no body', () {
      var props = IMap<String, dynamic>(const {});
      var doc = MdYamlDoc(body: "\n# Why not coffee?", props: props);

      var serializer = NoteSerializer.raw();

      var file = File.short("file-path-not-important", repoPath, gitDt);
      var note = serializer.decode(
        data: doc,
        parent: parent,
        file: file,
        fileFormat: NoteFileFormat.Markdown,
      );

      expect(note.body.length, 0);
      expect(note.title, "Why not coffee?");
    });

    test('Test Old Title Serialization', () {
      var props = IMap<String, dynamic>(
          const <String, dynamic>{"title": "Why not coffee?"});
      var doc = MdYamlDoc(body: "I heart you", props: props);

      var serializer = NoteSerializer.raw();
      serializer.settings.titleSettings = SettingsTitle.InH1;

      var file = File.short("file-path-not-important", repoPath, gitDt);
      var note = serializer.decode(
        data: doc,
        parent: parent,
        file: file,
        fileFormat: NoteFileFormat.Markdown,
      );

      expect(note.body, "I heart you");
      expect(note.title, "Why not coffee?");

      doc = serializer.encode(note);
      expect(doc.body, "I heart you");
      expect(doc.props["title"], "Why not coffee?");
      expect(doc.props.length, 1);
    });

    test('Test Note ExtraProps', () {
      var props = IMap<String, dynamic>(const <String, dynamic>{
        "title": "Why not?",
        "draft": true,
      });
      var doc = MdYamlDoc(body: "body", props: props);

      var serializer = NoteSerializer.raw();
      serializer.settings.titleSettings = SettingsTitle.InYaml;

      var file = File.short("file-path-not-important", repoPath, gitDt);
      var note = serializer.decode(
        data: doc,
        parent: parent,
        file: file,
        fileFormat: NoteFileFormat.Markdown,
      );

      expect(note.body, "body");
      expect(note.title, "Why not?");
      expect(note.extraProps, <String, dynamic>{"draft": true});

      doc = serializer.encode(note);
      expect(doc.body, "body");
      expect(doc.props.length, 2);
      expect(doc.props['title'], 'Why not?');
      expect(doc.props['draft'], true);
    });

    test('Test string tag with #', () {
      var props = IMap<String, dynamic>(const <String, dynamic>{
        "title": "Why not?",
        "draft": true,
        "tags": "#foo #bar-do",
      });
      var doc = MdYamlDoc(body: "body", props: props);

      var serializer = NoteSerializer.raw();
      serializer.settings.titleSettings = SettingsTitle.InYaml;

      var file = File.short("file-path-not-important", repoPath, gitDt);
      var note = serializer.decode(
        data: doc,
        parent: parent,
        file: file,
        fileFormat: NoteFileFormat.Markdown,
      );

      expect(note.body, "body");
      expect(note.title, "Why not?");
      expect(note.extraProps, <String, dynamic>{"draft": true});
      expect(note.tags, <String>{"foo", "bar-do"});

      doc = serializer.encode(note);
      expect(doc.body, "body");
      expect(doc.props['title'], 'Why not?');
      expect(doc.props['draft'], true);
      expect(doc.props['tags'], "#foo #bar-do");
      expect(doc.props.length, 3);
    });
  });
}
