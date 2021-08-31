import 'package:hive/hive.dart';

import 'note.dart';

typedef NotesViewComputer<T> = T Function(Note note);

class NotesView<T> {
  final Box storageBox;
  final NotesViewComputer computeFn;

  NotesView._internal(this.storageBox, this.computeFn);

  static Future<NotesView<T>> loadView<T>(
    String name,
    NotesViewComputer computeFn,
  ) async {
    var box = await Hive.openBox<T>(name);
    return NotesView<T>._internal(box, computeFn);
  }

  // FIXME: The return value doesn't need to be optional
  // FIXME: Make sure the old values are discarded

  T? fetch(Note note) {
    if (note.fileLastModified == null) {
      return null;
    }

    // FIXME: the note.filePath doesn't need to contain the full path!
    var ts = note.fileLastModified!.toUtc().millisecondsSinceEpoch / 1000;
    var path = note.filePath;
    var key = '${ts}_$path';

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
