// @dart=2.9

import 'package:gitjournal/core/note.dart';

export 'package:gitjournal/core/note.dart';

abstract class NoteReadTransformer {
  Future<Note> onRead(Note note);
}

abstract class NoteWriteTransformer {
  Future<Note> onWrite(Note note);
}

// ReadTransformersLoader(folderConfig) -> ...
// WriteTransformerLoader(folderConfig) -> ...
// -> test it out again
