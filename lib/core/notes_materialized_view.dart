import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;

import 'note.dart';

typedef NotesViewComputer<T> = T Function(Note note);

class NotesMaterializedView<T> {
  final Box storageBox;
  final NotesViewComputer computeFn;
  final String repoPath;

  NotesMaterializedView._internal(
      this.storageBox, this.computeFn, this.repoPath);

  static Future<NotesMaterializedView<T>> loadView<T>({
    required String name,
    required NotesViewComputer computeFn,
    required String repoPath,
  }) async {
    var path = repoPath;
    if (!path.endsWith(p.separator)) {
      path += p.separator;
    }

    var box = await Hive.openBox<T>(name);
    return NotesMaterializedView<T>._internal(box, computeFn, path);
  }

  // FIXME: The return value doesn't need to be optional
  // FIXME: Make sure the old values are discarded

  T? fetch(Note note) {
    assert(note.filePath.startsWith(repoPath));

    if (note.fileLastModified == null) {
      return null;
    }

    var ts = note.fileLastModified!.toUtc().millisecondsSinceEpoch ~/ 1000;
    var path = note.filePath.substring(repoPath.length);
    var key = '${path}_$ts';

    T? val = storageBox.get(key, defaultValue: null);
    if (val == null) {
      val = computeFn(note);
      storageBox.put(key, val);
    }

    return val;
  }
}

/*

  String? _summary;
  List<Link>? _links;
  Set<String>? _inlineTags;
  Set<NoteImage>? _images;

*/
