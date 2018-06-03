import 'dart:async';
import 'package:journal/note.dart';

abstract class NoteRepository {
  // TODO: Better error message!
  Future<bool> sync();

  Future<bool> addNote(Note note);
  Future<bool> updateNote(Note note);
  Future<bool> removeNote(Note note);

  Future<List<Note>> listNotes();
}
