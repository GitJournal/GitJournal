import 'dart:async';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:gitjournal/apis/git.dart';
import 'package:gitjournal/note.dart';
import 'package:gitjournal/settings.dart';
import 'package:path/path.dart' as p;

class NoteRepoResult {
  bool error;
  String noteFilePath;

  NoteRepoResult({
    @required this.error,
    this.noteFilePath,
  });
}

class GitNoteRepository {
  final String dirName;
  final String subDirName;
  final String baseDirectory;
  String notesBasePath;
  final GitRepo _gitRepo;

  // vHanda: This no longer needs to be so complex. It will only ever take the baseDirectory + dirName
  // The directory should already exist!
  GitNoteRepository({
    @required this.dirName,
    @required this.subDirName,
    @required this.baseDirectory,
  }) : _gitRepo = GitRepo(
          folderName: dirName,
          authorEmail: Settings.instance.gitAuthorEmail,
          authorName: Settings.instance.gitAuthor,
        ) {
    notesBasePath = p.join(baseDirectory, dirName, subDirName);
  }

  Future<NoteRepoResult> addNote(Note note) async {
    return _addNote(note, "Added Journal Entry");
  }

  Future<NoteRepoResult> _addNote(Note note, String commitMessage) async {
    await note.save();
    await _gitRepo.add(".");
    await _gitRepo.commit(
      message: commitMessage,
    );

    return NoteRepoResult(noteFilePath: note.filePath, error: false);
  }

  Future<NoteRepoResult> removeNote(Note note) async {
    var gitDir = p.join(baseDirectory, dirName);
    var pathSpec = note.filePath.replaceFirst(gitDir, "").substring(1);

    // We are not calling note.remove() as gitRm will also remove the file
    await _gitRepo.rm(pathSpec);
    await _gitRepo.commit(
      message: "Removed Journal entry",
    );

    return NoteRepoResult(noteFilePath: note.filePath, error: false);
  }

  Future<NoteRepoResult> resetLastCommit() async {
    await _gitRepo.resetLast();
    return NoteRepoResult(error: false);
  }

  Future<NoteRepoResult> updateNote(Note note) async {
    return _addNote(note, "Edited Journal Entry");
  }

  Future<List<Note>> listNotes() async {
    final dir = Directory(notesBasePath);

    var notes = <Note>[];
    var lister = dir.list(recursive: false);
    await for (var fileEntity in lister) {
      var note = Note(fileEntity.path);
      if (!note.filePath.toLowerCase().endsWith('.md')) {
        continue;
      }
      await note.load();
      notes.add(note);
    }

    // Reverse sort
    notes.sort((a, b) => b.compareTo(a));
    return notes;
  }

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
