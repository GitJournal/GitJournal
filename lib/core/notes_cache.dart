/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart' as io;

import 'package:gitjournal/core/file/file.dart';
import 'package:gitjournal/core/file/file_storage.dart';
import 'package:gitjournal/core/file/unopened_files.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/folder/sorting_mode.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/logger/logger.dart';

class NotesCache {
  final String folderPath;
  final String repoPath;
  final bool enabled = true;
  final FileStorage fileStorage;

  String get filePath => p.join(folderPath, 'notes_cache_$version.json');

  static const CACHE_SIZE = 20;
  static const version = 1;

  NotesCache({
    required this.folderPath,
    required this.repoPath,
    required this.fileStorage,
  }) {
    assert(repoPath.endsWith(p.separator));
    assert(folderPath.startsWith(p.separator));
  }

  Future<void> load(NotesFolderFS rootFolder) async {
    if (!enabled) return;

    var fileList = await loadFromDisk();
    Log.i("Notes Cache Loaded: ${fileList.length} items");

    assert(repoPath.endsWith(p.separator));

    var selectFolders = <NotesFolderFS>{};
    for (var file in fileList) {
      var parentFolderPath = p.dirname(file.filePath);
      var parent = rootFolder.getOrBuildFolderWithSpec(parentFolderPath);

      var unopenFile = UnopenedFile(file: file, parent: parent);
      parent.addFile(unopenFile);
      var _ = selectFolders.add(parent);
    }

    // Load all the notes recursively
    var futures = selectFolders.map((f) => f.loadNotes()).toList();
    var _ = await Future.wait(futures);
  }

  Future<void> clear() async {
    if (!enabled) return;
    var _ = await io.File(filePath).delete();
  }

  Future<void> buildCache(NotesFolderFS rootFolder) async {
    if (!enabled) return;

    var notes = rootFolder.getAllNotes();
    var sortingMode = rootFolder.config.sortingMode;

    var topNotes = _fetchTop(notes, sortingMode);
    var pinned = _fetchPinned(notes);
    var fileList = pinned.followedBy(topNotes);

    return saveToDisk(fileList);
  }

  Iterable<File> _fetchTop(
    Iterable<Note> allNotes,
    SortingMode sortingMode,
  ) {
    var origFn = sortingMode.sortingFunction();

    reversedFn(File a, File b) {
      var r = origFn(a, b);
      if (r < 0) return 1;
      if (r > 0) return -1;
      return 0;
    }

    var heap = HeapPriorityQueue<Note>(reversedFn);

    for (var note in allNotes) {
      if (!heap.contains(note)) {
        heap.add(note);
      }
      if (heap.length > CACHE_SIZE) {
        var _ = heap.removeFirst();
      }
    }

    return heap.toList().reversed;
  }

  Iterable<File> _fetchPinned(Iterable<Note> allNotes) sync* {
    for (var note in allNotes) {
      if (note.pinned) {
        yield note;
      }
    }
  }

  @visibleForTesting
  Future<List<File>> loadFromDisk() async {
    String contents = "";
    try {
      assert(filePath.startsWith(p.separator));
      contents = await io.File(filePath).readAsString();
    } on io.FileSystemException catch (ex) {
      if (ex.osError?.errorCode == 2 /* file not found */) {
        return [];
      }
      rethrow;
    }

    if (contents.isEmpty) {
      return [];
    }

    try {
      var mapL = json.decode(contents);
      if (mapL is! List) {
        throw Exception("Cache not an array");
      }

      var files = mapL.map((e) => File.fromMap(e));
      return files.toList();
    } catch (ex, st) {
      Log.e("Exception - $ex for contents: $contents");
      await logExceptionWarning(ex, st);
      return [];
    }
  }

  @visibleForTesting
  Future<void> saveToDisk(Iterable<File> files) async {
    var contents = json.encode(files.map((e) => e.toMap()).toList());
    var newFilePath = filePath + ".new";

    try {
      assert(newFilePath.startsWith(p.separator));
      var file = io.File(newFilePath);
      dynamic _;
      _ = await file.writeAsString(contents);
      _ = await file.rename(filePath);
    } catch (ex, st) {
      // FIXME: Do something in this case!!
      Log.e("Failed to save Notes Cache", ex: ex, stacktrace: st);
    }
  }
}
