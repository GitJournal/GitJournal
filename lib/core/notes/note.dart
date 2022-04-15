import 'package:path/path.dart' as p;

import 'package:gitjournal/core/file/file.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/editors/common_types.dart';
import '../note.dart';

class NoteN extends File {
  NoteN({
    required File file,
  }) : super(
          oid: file.oid,
          filePath: file.filePath,
          repoPath: file.repoPath,
          modified: file.modified,
          created: file.created,
          fileLastModified: file.fileLastModified,
        ) {
    assert(file.oid.isNotEmpty);
  }
}

typedef NoteSelectedFunction = void Function(Note note);
typedef NoteBoolPropertyFunction = bool Function(Note note);

enum NoteType { Unknown, Checklist, Journal, Org }

class NoteFileFormatInfo {
  final NotesFolderConfig config;
  NoteFileFormatInfo(this.config);

  static String defaultExtension(NoteFileFormat format) {
    switch (format) {
      case NoteFileFormat.Markdown:
        return ".md";
      case NoteFileFormat.OrgMode:
        return '.org';
      case NoteFileFormat.Txt:
        return ".txt";
    }
  }

  static EditorType defaultEditor(NoteFileFormat format) {
    switch (format) {
      case NoteFileFormat.Markdown:
        return EditorType.Markdown;
      case NoteFileFormat.Txt:
        return EditorType.Raw;
      case NoteFileFormat.OrgMode:
        return EditorType.Org;
    }
  }

  static NoteFileFormat fromFilePath(String filePath) {
    var ext = p.extension(filePath).toLowerCase();
    switch (ext) {
      case ".md":
        return NoteFileFormat.Markdown;
      case ".org":
        return NoteFileFormat.OrgMode;
      case ".txt":
      default:
        return NoteFileFormat.Txt;
    }
  }

  bool isAllowedFileName(String filePath) {
    var noteFilePath = filePath.toLowerCase();
    for (var ext in config.allowedFileExts) {
      if (p.extension(noteFilePath) == ext) {
        return true;
      }
    }

    return false;
  }
}

// FIXME: Treat Markdown and Markdown + YAML differently
enum NoteFileFormat {
  Markdown,
  OrgMode,
  Txt,
}
