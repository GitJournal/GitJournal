import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:git_bindings/git_bindings.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils/logger.dart';

import 'package:dart_git/git.dart' as git;

class NoteRepoResult {
  bool error;
  String noteFilePath;

  NoteRepoResult({
    @required this.error,
    this.noteFilePath,
  });
}

class GitNoteRepository {
  final String gitDirPath;
  final GitRepo _gitRepo;

  GitNoteRepository({
    @required this.gitDirPath,
  }) : _gitRepo = GitRepo(
          folderPath: gitDirPath,
          authorEmail: Settings.instance.gitAuthorEmail,
          authorName: Settings.instance.gitAuthor,
        );

  Future<NoteRepoResult> addNote(Note note) async {
    return _addNote(note, "Added Note");
  }

  Future<NoteRepoResult> _addNote(Note note, String commitMessage) async {
    await note.save();
    await _gitRepo.add(".");
    await _gitRepo.commit(
      message: commitMessage,
    );

    return NoteRepoResult(noteFilePath: note.filePath, error: false);
  }

  Future<NoteRepoResult> addFolder(NotesFolderFS folder) async {
    await _gitRepo.add(".");
    await _gitRepo.commit(
      message: "Created New Folder",
    );

    return NoteRepoResult(noteFilePath: folder.folderPath, error: false);
  }

  Future<NoteRepoResult> addFolderConfig(NotesFolderConfig config) async {
    var pathSpec = config.folder.pathSpec();
    pathSpec = pathSpec.isNotEmpty ? pathSpec : '/';

    await _gitRepo.add(".");
    await _gitRepo.commit(
      message: "Update folder config for $pathSpec",
    );

    return NoteRepoResult(noteFilePath: config.folder.folderPath, error: false);
  }

  Future<NoteRepoResult> renameFolder(
    String oldFullPath,
    String newFullPath,
  ) async {
    // FIXME: This is a hacky way of adding the changes, ideally we should be calling rm + add or something
    await _gitRepo.add(".");
    await _gitRepo.commit(
      message: "Renamed Folder",
    );

    return NoteRepoResult(noteFilePath: newFullPath, error: false);
  }

  Future<NoteRepoResult> renameNote(
    String oldFullPath,
    String newFullPath,
  ) async {
    // FIXME: This is a hacky way of adding the changes, ideally we should be calling rm + add or something
    await _gitRepo.add(".");
    await _gitRepo.commit(
      message: "Renamed Note",
    );

    return NoteRepoResult(noteFilePath: newFullPath, error: false);
  }

  Future<NoteRepoResult> moveNote(
    String oldFullPath,
    String newFullPath,
  ) async {
    // FIXME: This is a hacky way of adding the changes, ideally we should be calling rm + add or something
    await _gitRepo.add(".");
    await _gitRepo.commit(
      message: "Note Moved",
    );

    return NoteRepoResult(noteFilePath: newFullPath, error: false);
  }

  Future<NoteRepoResult> removeNote(Note note) async {
    // We are not calling note.remove() as gitRm will also remove the file
    var spec = note.pathSpec();
    await _gitRepo.rm(spec);
    await _gitRepo.commit(
      message: "Removed Note " + spec,
    );

    return NoteRepoResult(noteFilePath: note.filePath, error: false);
  }

  Future<NoteRepoResult> removeFolder(NotesFolderFS folder) async {
    var spec = folder.pathSpec();
    await _gitRepo.rm(spec);
    await _gitRepo.commit(
      message: "Removed Folder " + spec,
    );

    await Directory(folder.folderPath).delete(recursive: true);

    return NoteRepoResult(noteFilePath: folder.folderPath, error: false);
  }

  Future<NoteRepoResult> resetLastCommit() async {
    await _gitRepo.resetLast();
    return NoteRepoResult(error: false);
  }

  Future<NoteRepoResult> updateNote(Note note) async {
    return _addNote(note, "Edited Note");
  }

  Future<void> pull() async {
    try {
      await _gitRepo.pull();
    } on GitException catch (ex) {
      Log.d(ex.toString());
    }
  }

  Future<void> push() async {
    // Only push if we have something we need to push
    try {
      var repo = await git.GitRepository.load(gitDirPath);
      if ((await repo.canPush()) == false) {
        return;
      }
    } catch (_) {}

    try {
      await _gitRepo.push();
    } on GitException catch (ex) {
      if (ex.cause == 'cannot push non-fastforwardable reference') {
        await pull();
        return push();
      }
      Log.d(ex.toString());
      rethrow;
    }
  }
}

const ignoredMessages = [
  'connection timed out',
  'failed to resolve address for',
  'failed to connect to',
  'no address associated with hostname',
  'unauthorized',
  'invalid credentials',
  'failed to start ssh session',
  'failure while draining',
  'network is unreachable',
  'software caused connection abort',
  'unable to exchange encryption keys',
  'the key you are authenticating with has been marked as read only',
  'transport read',
];

bool shouldLogGitException(GitException ex) {
  var msg = ex.cause.toLowerCase();
  for (var i = 0; i < ignoredMessages.length; i++) {
    if (msg.contains(ignoredMessages[i])) {
      return false;
    }
  }
  return true;
}
