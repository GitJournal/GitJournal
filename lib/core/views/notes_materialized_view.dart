import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;

import '../note.dart';

typedef NotesViewComputer<T> = Future<T> Function(Note note);

class NotesMaterializedView<T> {
  Box? storageBox;
  final String name;

  final NotesViewComputer<T> computeFn;
  final String repoPath;

  NotesMaterializedView({
    required this.name,
    required this.computeFn,
    required this.repoPath,
  }) {
    var path = repoPath;
    if (!path.endsWith(p.separator)) {
      path += p.separator;
    }
  }

  // FIXME: The return value doesn't need to be optional
  // FIXME: Make sure the old values are discarded

  Future<T?> fetch(Note note) async {
    assert(note.filePath.startsWith(repoPath));

    if (note.fileLastModified == null) {
      return null;
    }

    var ts = note.fileLastModified!.toUtc().millisecondsSinceEpoch ~/ 1000;
    var path = note.filePath.substring(repoPath.length);
    var key = '${path}_$ts';

    storageBox ??= await Hive.openBox<T>(name);
    var box = storageBox!;

    T? val = box.get(key, defaultValue: null);
    if (val == null) {
      val = await computeFn(note);
      box.put(key, val);
    }

    return val;
  }
}
