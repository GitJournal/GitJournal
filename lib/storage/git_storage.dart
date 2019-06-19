import 'dart:async';

import 'package:fimber/fimber.dart';
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
  final GitRepo _gitRepo;

  bool cloned = false;
  bool checkForCloned = false;

  GitNoteRepository({
    @required this.dirName,
    @required this.subDirName,
    @required String baseDirectory,
  })  : _fileStorage = FileStorage(
          noteSerializer: MarkdownYAMLSerializer(),
          baseDirectory: p.join(baseDirectory, dirName, subDirName),
        ),
        _gitRepo = GitRepo(
          folderName: dirName,
          authorEmail: Settings.instance.gitAuthorEmail,
          authorName: Settings.instance.gitAuthor,
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

    await _gitRepo.add(".");
    await _gitRepo.commit(
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

    await _gitRepo.rm(filePath);
    await _gitRepo.commit(
      message: "Removed Journal entry",
    );

    return result;
  }

  Future<NoteRepoResult> resetLastCommit() async {
    await _gitRepo.resetLast();
    return NoteRepoResult(error: false);
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
      await _gitRepo.pull();
    } on GitException catch (ex) {
      Fimber.d(ex.toString());
    }

    try {
      await _gitRepo.push();
    } on GitException catch (ex) {
      Fimber.d(ex.toString());
      rethrow;
    }

    return true;
  }
}
