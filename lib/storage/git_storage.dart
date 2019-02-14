import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:journal/apis/git.dart';
import 'package:journal/note.dart';
import 'package:journal/settings.dart';
import 'package:journal/storage/file_storage.dart';
import 'package:journal/storage/notes_repository.dart';
import 'package:journal/storage/serializers.dart';
import 'package:path/path.dart' as p;

class GitNoteRepository implements NoteRepository {
  final FileStorage _fileStorage;
  final String dirName;
  final String subDirName;

  bool cloned = false;
  bool checkForCloned = false;

  GitNoteRepository({
    @required this.dirName,
    @required this.subDirName,
    @required String baseDirectory,
  }) : _fileStorage = FileStorage(
          noteSerializer: MarkdownYAMLSerializer(),
          baseDirectory: p.join(baseDirectory, dirName, subDirName),
        );

  @override
  Future<NoteRepoResult> addNote(Note note) async {
    return _addNote(note, "Added Journal Entry");
  }

  Future<NoteRepoResult> _addNote(Note note, String commitMessage) async {
    var result = await _fileStorage.addNote(note);
    if (result.error) {
      return result;
    }

    var baseDir = _fileStorage.baseDirectory;
    var filePath = result.noteFilePath.replaceFirst(baseDir + "/", "");

    await gitAdd(this.dirName, filePath);
    await gitCommit(
      gitFolder: this.dirName,
      authorEmail: Settings.instance.gitAuthorEmail,
      authorName: Settings.instance.gitAuthor,
      message: commitMessage,
    );

    return result;
  }

  @override
  Future<NoteRepoResult> removeNote(Note note) async {
    var result = await _fileStorage.addNote(note);
    if (result.error) {
      return result;
    }

    // FIXME: '/' is not valid on all platforms
    var baseDir = _fileStorage.baseDirectory;
    var filePath = result.noteFilePath.replaceFirst(baseDir + "/", "");

    await gitRm(this.dirName, filePath);
    await gitCommit(
      gitFolder: this.dirName,
      authorEmail: Settings.instance.gitAuthorEmail,
      authorName: Settings.instance.gitAuthor,
      message: "Removed Journal entry",
    );

    return result;
  }

  @override
  Future<NoteRepoResult> updateNote(Note note) async {
    return _addNote(note, "Edited Journal Entry");
  }

  @override
  Future<List<Note>> listNotes() {
    return _fileStorage.listNotes();
  }

  @override
  Future<bool> sync() async {
    try {
      await gitPull(this.dirName);
    } on GitException catch (ex) {
      print(ex);
    }

    try {
      await gitPush(this.dirName);
    } on GitException catch (ex) {
      print(ex);
      rethrow;
    }

    return true;
  }
}
