import 'dart:collection';

import 'package:test/test.dart';

import 'package:gitjournal/core/md_yaml_doc.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/note_serializer.dart';
import 'package:gitjournal/core/notes_folder_config.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/settings/settings.dart';

void main() {
  group('Note Serializer Test', () {
    var parent = NotesFolderFS(null, '/tmp', NotesFolderConfig(''));

    test('Test emojis', () {
      var props = LinkedHashMap<String, dynamic>.from(
          <String, dynamic>{"title": "Why not :coffee:?"});
      var doc = MdYamlDoc(body: "I :heart: you", props: props);

      var serializer = NoteSerializer.raw();
      serializer.settings.titleSettings = SettingsTitle.InYaml;

      var note = Note(parent, "file-path-not-important");
      serializer.decode(doc, note);

      expect(note.body, "I ❤️ you");
      expect(note.title, "Why not ☕?");

      note.body = "Why not ☕?";
      note.title = "I ❤️ you";

      serializer.encode(note, doc);
      expect(doc.body, "Why not :coffee:?");
      expect(doc.props['title'].toString(), "I :heart: you");
    });

    test('Test Title Serialization', () {
      var props = LinkedHashMap<String, dynamic>.from({});
      var doc =
          MdYamlDoc(body: "# Why not :coffee:?\n\nI :heart: you", props: props);

      var serializer = NoteSerializer.raw();
      serializer.settings.titleSettings = SettingsTitle.InH1;

      var note = Note(parent, "file-path-not-important");
      serializer.decode(doc, note);

      expect(note.body, "I ❤️ you");
      expect(note.title, "Why not ☕?");

      note.body = "Why not ☕?";
      note.title = "I ❤️ you";

      serializer.encode(note, doc);
      expect(doc.body, "# I :heart: you\n\nWhy not :coffee:?");
      expect(doc.props.length, 0);
    });

    test('Test Title Reading with blank lines', () {
      var props = LinkedHashMap<String, dynamic>.from({});
      var doc = MdYamlDoc(
          body: "\n# Why not :coffee:?\n\nI :heart: you", props: props);

      var serializer = NoteSerializer.raw();

      var note = Note(parent, "file-path-not-important");
      serializer.decode(doc, note);

      expect(note.body, "I ❤️ you");
      expect(note.title, "Why not ☕?");
    });

    test('Test Title Reading with blank lines and no body', () {
      var props = LinkedHashMap<String, dynamic>.from({});
      var doc = MdYamlDoc(body: "\n# Why not :coffee:?", props: props);

      var serializer = NoteSerializer.raw();

      var note = Note(parent, "file-path-not-important");
      serializer.decode(doc, note);

      expect(note.body.length, 0);
      expect(note.title, "Why not ☕?");
    });

    test('Test Old Title Serialization', () {
      var props = LinkedHashMap<String, dynamic>.from(
          <String, dynamic>{"title": "Why not :coffee:?"});
      var doc = MdYamlDoc(body: "I :heart: you", props: props);

      var serializer = NoteSerializer.raw();
      serializer.settings.titleSettings = SettingsTitle.InH1;

      var note = Note(parent, "file-path-not-important");
      serializer.decode(doc, note);

      expect(note.body, "I ❤️ you");
      expect(note.title, "Why not ☕?");

      serializer.encode(note, doc);
      expect(note.body, "I ❤️ you");
      expect(note.title, "Why not ☕?");
      expect(doc.props.length, 1);
    });

    test('Test Note ExtraProps', () {
      var props = LinkedHashMap<String, dynamic>.from(<String, dynamic>{
        "title": "Why not?",
        "draft": true,
      });
      var doc = MdYamlDoc(body: "body", props: props);

      var serializer = NoteSerializer.raw();
      serializer.settings.titleSettings = SettingsTitle.InYaml;

      var note = Note(parent, "file-path-not-important");
      serializer.decode(doc, note);

      expect(note.body, "body");
      expect(note.title, "Why not?");
      expect(note.extraProps, <String, dynamic>{"draft": true});

      serializer.encode(note, doc);
      expect(doc.body, "body");
      expect(doc.props.length, 2);
      expect(doc.props['title'], 'Why not?');
      expect(doc.props['draft'], true);
    });

    test('Test string tag with #', () {
      var props = LinkedHashMap<String, dynamic>.from(<String, dynamic>{
        "title": "Why not?",
        "draft": true,
        "tags": "#foo #bar-do",
      });
      var doc = MdYamlDoc(body: "body", props: props);

      var serializer = NoteSerializer.raw();
      serializer.settings.titleSettings = SettingsTitle.InYaml;

      var note = Note(parent, "file-path-not-important");
      serializer.decode(doc, note);

      expect(note.body, "body");
      expect(note.title, "Why not?");
      expect(note.extraProps, <String, dynamic>{"draft": true});
      expect(note.tags, <String>{"foo", "bar-do"});

      serializer.encode(note, doc);
      expect(doc.body, "body");
      expect(doc.props['title'], 'Why not?');
      expect(doc.props['draft'], true);
      expect(doc.props['tags'], "#foo #bar-do");
      expect(doc.props.length, 3);
    });
  });
}
