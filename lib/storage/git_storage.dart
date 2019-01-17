import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'package:journal/note.dart';
import 'package:journal/storage/git.dart';
import 'package:journal/storage/serializers.dart';
import 'package:journal/storage/file_storage.dart';
import 'package:journal/storage/notes_repository.dart';

class GitNoteRepository implements NoteRepository {
  final FileStorage _fileStorage;
  final String gitCloneUrl;
  final String dirName;

  bool cloned = false;
  bool checkForCloned = false;

  final Future<Directory> Function() getDirectory;

  GitNoteRepository({
    @required this.gitCloneUrl,
    @required this.dirName,
    @required this.getDirectory,
    @required fileNameGenerator,
  }) : _fileStorage = FileStorage(
          noteSerializer: new MarkdownYAMLSerializer(),
          fileNameGenerator: fileNameGenerator,
          getDirectory: getDirectory,
        ) {
    // FIXME: This isn't correct. The gitUrl might not be cloned at this point!
  }

  @override
  Future<NoteRepoResult> addNote(Note note) async {
    return _addNote(note, "Added Journal Entry");
  }

  Future<NoteRepoResult> _addNote(Note note, String commitMessage) async {
    print("Calling gitStorage addNote");
    var result = await _fileStorage.addNote(note);
    if (result.error) {
      return result;
    }

    var baseDir = await this.getDirectory();
    var filePath = result.noteFilePath.replaceFirst(baseDir.path + "/", "");

    await gitAdd(this.dirName, filePath);
    await gitCommit(
      gitFolder: this.dirName,
      authorEmail: "app@gitjournal.io",
      authorName: "GitJournal",
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

    var baseDir = await this.getDirectory();
    var filePath = result.noteFilePath.replaceFirst(baseDir.path + "/", "");

    await gitRm(this.dirName, filePath);
    await gitCommit(
      gitFolder: this.dirName,
      authorEmail: "app@gitjournal.io",
      authorName: "GitJournal",
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
    print("Starting Sync");
    if (!checkForCloned) {
      var baseDir = await this.getDirectory();
      var dotGitDir = new Directory(p.join(baseDir.path, ".git"));
      cloned = await dotGitDir.exists();
      checkForCloned = true;
    }
    if (!cloned) {
      await gitClone(this.gitCloneUrl, this.dirName);
      cloned = true;
      return true;
    }

    try {
      await gitPull(this.dirName);
    } on GitException catch (ex) {
      print(ex);
    }

    try {
      await gitPush(this.dirName);
    } on GitException catch (ex) {
      print(ex);
      throw ex;
    }

    return true;
  }
}
