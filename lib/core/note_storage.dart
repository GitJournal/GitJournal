/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:gitjournal/core/file/file_storage.dart';
import 'package:gitjournal/core/markdown/md_yaml_doc.dart';
import 'package:gitjournal/core/markdown/md_yaml_doc_codec.dart';
import 'package:gitjournal/core/markdown/md_yaml_doc_loader.dart';
import 'package:gitjournal/core/markdown/md_yaml_note_serializer.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart' as io;

import 'file/file.dart';
import 'folder/notes_folder_fs.dart';
import 'note.dart';
import 'notes/note.dart';

class NoteStorage {
  static final _serializer = MarkdownYAMLCodec();

  static String serialize(Note note) {
    // HACK: This isn't great as the raw editor still shows the note with metadata
    var data = note.data;
    if (!note.canHaveMetadata) {
      data = MdYamlDoc(body: data.body);
    }

    var contents = _serializer.encode(data);
    // Make sure all docs end with a \n
    if (!contents.endsWith('\n')) {
      contents += '\n';
    }

    return contents;
  }

  static Future<Note> save(Note note) async {
    assert(note.filePath.isNotEmpty);
    assert(note.fileName.isNotEmpty);
    assert(note.oid.isEmpty);

    var contents = utf8.encode(serialize(note));

    assert(note.fullFilePath.startsWith(p.separator));

    var file = io.File(note.fullFilePath);
    await file.writeAsBytes(contents, flush: true);

    var stat = file.statSync();
    note = note.copyWith(
      file: note.file.copyFile(
        fileLastModified: stat.modified,
        oid: GitHash.compute(contents),
        modified: DateTime.now(),
      ),
    );

    return note;
  }

  static final mdYamlDocLoader = MdYamlDocLoader();

  /// Fails with 'NoteReloadNotRequired' if the note doesn't need to be reloaded
  static Future<Note> reload(Note note, FileStorage fileStorage) async {
    var newFile = await fileStorage.load(note.filePath);

    if (note.file == newFile) {
      throw NoteReloadNotRequired();
    }
    Log.d("Note modified: ${note.filePath}");

    return load(newFile, note.parent);
  }

  static Future<Note> load(File file, NotesFolderFS parentFolder) async {
    assert(file.filePath.isNotEmpty);
    assert(!file.filePath.startsWith('/'));
    assert(file.oid.isNotEmpty);

    var filePath = file.fullFilePath;
    var format = NoteFileFormatInfo.fromFilePath(filePath);

    if (format == NoteFileFormat.Markdown) {
      var data = await mdYamlDocLoader.loadDoc(filePath);
      var settings = NoteSerializationSettings.fromConfig(parentFolder.config);
      var noteSerializer = NoteSerializer.fromConfig(settings);
      var note = noteSerializer.decode(
        data: data,
        parent: parentFolder,
        file: file,
        fileFormat: format,
      );
      return note;
    } else if (format == NoteFileFormat.Txt) {
      var note = Note.build(
        parent: parentFolder,
        file: file,
        title: null,
        body: await io.File(filePath).readAsString(),
        noteType: NoteType.Unknown,
        tags: ISet(),
        extraProps: const {},
        fileFormat: NoteFileFormat.Txt,
        propsList: IList(),
        serializerSettings:
            NoteSerializationSettings.fromConfig(parentFolder.config),
        created: null,
        modified: null,
      );
      return note;
    } else if (format == NoteFileFormat.OrgMode) {
      var note = Note.build(
        parent: parentFolder,
        file: file,
        title: null,
        body: await io.File(filePath).readAsString(),
        noteType: NoteType.Unknown,
        tags: ISet(),
        extraProps: const {},
        fileFormat: NoteFileFormat.OrgMode,
        propsList: IList(),
        serializerSettings:
            NoteSerializationSettings.fromConfig(parentFolder.config),
        created: null,
        modified: null,
      );
      return note;
    }

    throw Exception("Unknown Note type. WTF");
  }
}

class NoteReloadNotRequired implements Exception {
  NoteReloadNotRequired();
}
