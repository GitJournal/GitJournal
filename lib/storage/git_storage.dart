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

  bool cloned = false;
  bool checkForCloned = false;

  GitNoteRepository({
    @required this.dirName,
    @required String baseDirectory,
  }) : _fileStorage = FileStorage(
          noteSerializer: MarkdownYAMLSerializer(),
          baseDirectory: p.join(baseDirectory, dirName),
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
    /*
    Disable git clone for now - The repo should have already been cloned!

    if (gitCloneUrl == null || gitCloneUrl.isEmpty) {
      print("Cannot sync because of lack of clone url");
      return false;
    }

    if (!checkForCloned) {
      var baseDir = Directory(_fileStorage.baseDirectory);
      var dotGitDir = Directory(p.join(baseDir.path, ".git"));
      cloned = await dotGitDir.exists();
      checkForCloned = true;
    }
    // FIXME: If we are calling sync, it should always be cloned!
    assert(cloned == true);
    if (!cloned) {
      await gitClone(this.gitCloneUrl, this.dirName);
      cloned = true;
      return true;
    }
    */

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
