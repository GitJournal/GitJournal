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
  }) : _fileStorage = FileStorage(
          noteSerializer: new MarkdownYAMLSerializer(),
          fileNameGenerator: (Note note) => note.id,
          getDirectory: getDirectory,
        ) {
    // FIXME: This isn't correct. The gitUrl might not be cloned at this point!
  }

  @override
  Future<NoteRepoResult> addNote(Note note) async {
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
      authorEmail: "noemail@example.com",
      authorName: "Vishesh Handa",
      message: "Added Journal entry",
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
      authorEmail: "noemail@example.com",
      authorName: "Vishesh Handa",
      message: "Added Journal entry",
    );

    return result;
  }

  @override
  Future<NoteRepoResult> updateNote(Note note) async {
    return this.addNote(note);
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

    await gitPull(this.dirName);
    await gitPush(this.dirName);

    return true;
  }
}
