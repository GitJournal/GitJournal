import 'package:dart_git/utils/result.dart';
import 'package:universal_io/io.dart';

import 'note.dart';

class NoteStorage {
  Future<Result<void>> save(Note note) async {
    var contents = note.serialize();

    try {
      var file = File(note.filePath);
      await file.writeAsString(contents, flush: true);
    } on Exception catch (e, st) {
      return Result.fail(e, st);
    }

    return Result(null);
  }

  Future<Note> load(Note note) async {
    return note;
  }
}
