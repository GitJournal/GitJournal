import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:journal/note.dart';

class NoteRepoResult {
  bool error;
  String noteFilePath;

  NoteRepoResult({
    @required this.error,
    this.noteFilePath,
  });
}

abstract class NoteRepository {
  // TODO: Better error message!
  Future<bool> sync();

  Future<NoteRepoResult> addNote(Note note);
  Future<NoteRepoResult> updateNote(Note note);
  Future<NoteRepoResult> removeNote(Note note);

  Future<List<Note>> listNotes();
}
