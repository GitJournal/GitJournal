import 'package:dart_git/utils/result.dart';
import 'package:universal_io/io.dart';

import 'package:gitjournal/core/md_yaml_doc_loader.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/logger/logger.dart';
import 'note.dart';

class NoteStorage {
  Future<Result<void>> save(Note note) async {
    var contents = note.serialize();

    return catchAll(() async {
      var file = File(note.filePath);
      await file.writeAsString(contents, flush: true);
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
          note.loadState = NoteLoadState.NotExists;
          note.parent.noteModified(note);
          return Result(note.loadState);
        }

        logExceptionWarning(e, stackTrace);
        note.loadState = NoteLoadState.Error;
        note.parent.noteModified(note);
        return Result(note.loadState);
      }
      Log.d("Note modified: $note.filePath");
    }

    var fpLowerCase = note.filePath.toLowerCase();
    var isMarkdown = fpLowerCase.endsWith('.md');
    var isTxt = fpLowerCase.endsWith('.txt');
    var isOrg = fpLowerCase.endsWith('.org');

    if (isMarkdown) {
      var dataResult = await mdYamlDocLoader.loadDoc(note.filePath);
      if (dataResult.isSuccess) {
        note.data = dataResult.getOrThrow();
        note.fileFormat = NoteFileFormat.Markdown;
      } else {
        if (dataResult.error is MdYamlDocNotFoundException) {
          note.loadState = NoteLoadState.NotExists;
          note.parent.noteModified(note);
          return Result(note.loadState);
        }
        if (dataResult.error is MdYamlParsingException) {
          note.loadState = NoteLoadState.Error;
          note.parent.noteModified(note);
          return Result(note.loadState);
        }
      }
    } else if (isTxt) {
      try {
        note.body = await File(note.filePath).readAsString();
        note.fileFormat = NoteFileFormat.Txt;
      } catch (e, stackTrace) {
        logExceptionWarning(e, stackTrace);

        note.loadState = NoteLoadState.Error;
        note.parent.noteModified(note);
        return Result(note.loadState);
      }
    } else if (isOrg) {
      try {
        note.body = await File(note.filePath).readAsString();
        note.fileFormat = NoteFileFormat.OrgMode;
      } catch (e, stackTrace) {
        logExceptionWarning(e, stackTrace);

        note.loadState = NoteLoadState.Error;
        note.parent.noteModified(note);
        return Result(note.loadState);
      }
    } else {
      note.loadState = NoteLoadState.Error;
      note.parent.noteModified(note);
      return Result(note.loadState);
    }

    note.fileLastModified = file.lastModifiedSync();
    note.loadState = NoteLoadState.Loaded;

    note.parent.noteModified(note);
    return Result(note.loadState);
  }
}
