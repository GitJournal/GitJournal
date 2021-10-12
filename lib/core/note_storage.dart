/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:dart_git/utils/result.dart';
import 'package:universal_io/io.dart';

import 'package:gitjournal/core/md_yaml_doc.dart';
import 'package:gitjournal/core/md_yaml_doc_codec.dart';
import 'package:gitjournal/core/md_yaml_doc_loader.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/logger/logger.dart';
import 'note.dart';

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

  Future<Result<void>> save(Note note) async {
    var contents = serialize(note);

    return catchAll(() async {
      var file = File(note.filePath);
      var _ = await file.writeAsString(contents, flush: true);

      var stat = file.statSync();
      note.fileLastModified = stat.modified;

      return Result(null);
    });
  }

  static final mdYamlDocLoader = MdYamlDocLoader();

  Future<Result<NoteLoadState>> load(Note note) async {
    assert(note.filePath.isNotEmpty);

    if (note.loadState == NoteLoadState.Loading) {
      return Result(note.loadState);
    }

    final file = File(note.filePath);
    if (note.loadState == NoteLoadState.Loaded) {
      try {
        var fileLastModified = file.lastModifiedSync();
        if (note.fileLastModified == fileLastModified) {
          return Result(note.loadState);
        }
        note.fileLastModified = fileLastModified;
      } catch (e, stackTrace) {
        if (e is FileSystemException &&
            e.osError!.errorCode == 2 /* File Not Found */) {
          note.apply(loadState: NoteLoadState.NotExists);
          return Result(note.loadState);
        }

        logExceptionWarning(e, stackTrace);
        note.apply(loadState: NoteLoadState.Error);
        return Result(note.loadState);
      }
      Log.d("Note modified: ${note.filePath}");
    }

    var fpLowerCase = note.filePath.toLowerCase();
    var isMarkdown = fpLowerCase.endsWith('.md');
    var isTxt = fpLowerCase.endsWith('.txt');
    var isOrg = fpLowerCase.endsWith('.org');

    if (isMarkdown) {
      var dataResult = await mdYamlDocLoader.loadDoc(note.filePath);
      if (dataResult.isSuccess) {
        note.data = dataResult.getOrThrow();
        note.apply(fileFormat: NoteFileFormat.Markdown);
      } else {
        if (dataResult.error is MdYamlDocNotFoundException) {
          note.apply(loadState: NoteLoadState.NotExists);
          return Result(note.loadState);
        }
        if (dataResult.error is MdYamlParsingException) {
          note.apply(loadState: NoteLoadState.Error);
          return Result(note.loadState);
        }
      }
    } else if (isTxt) {
      try {
        note.apply(
          body: await File(note.filePath).readAsString(),
          fileFormat: NoteFileFormat.Txt,
        );
      } catch (e, stackTrace) {
        Log.e("Failed to load ${note.filePath}", ex: e, stacktrace: stackTrace);

        note.apply(loadState: NoteLoadState.Error);
        return Result(note.loadState);
      }
    } else if (isOrg) {
      try {
        note.apply(
          body: await File(note.filePath).readAsString(),
          fileFormat: NoteFileFormat.OrgMode,
        );
      } catch (e, stackTrace) {
        logExceptionWarning(e, stackTrace);

        note.apply(loadState: NoteLoadState.Error);
        return Result(note.loadState);
      }
    } else {
      note.apply(loadState: NoteLoadState.Error);
      return Result(note.loadState);
    }

    note.fileLastModified = file.lastModifiedSync();
    note.apply(loadState: NoteLoadState.Loaded);

    note.parent.noteModified(note);
    return Result(note.loadState);
  }
}
