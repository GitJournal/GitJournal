/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:dart_git/utils/result.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart' as io;

import 'package:gitjournal/core/file/file.dart';
import 'package:gitjournal/core/file/unopened_files.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/folder/sorting_mode.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/logger/logger.dart';

class NotesCache {
  final String filePath;
  final String notesBasePath;
  final bool enabled = true;
  final NotesFolderConfig folderConfig;

  static const CACHE_SIZE = 20;

  NotesCache({
    required this.filePath,
    required this.notesBasePath,
    required this.folderConfig,
  });

  Future<void> load(NotesFolderFS rootFolder) async {
    if (!enabled) return;

    var fileList = await loadFromDisk();
    Log.i("Notes Cache Loaded: ${fileList.length} items");

    var sep = p.separator;
    var notesBasePath = this.notesBasePath;
    if (!notesBasePath.endsWith(sep)) {
      notesBasePath += sep;
    }

    var futures = <Future<void>>[];

    for (var fullFilePath in fileList) {
      if (!fullFilePath.startsWith(notesBasePath)) {
        continue;
      }
      var filePath = fullFilePath.substring(notesBasePath.length);
      var components = filePath.split(sep);

      //
      // Create required folders
      var parent = rootFolder;
      for (var i = 0; i < components.length - 1; i++) {
        var c = components.sublist(0, i + 1);
        var folderPath = p.join(this.notesBasePath, c.join(sep));

        var folders = parent.subFoldersFS;
        var folderIndex = folders.indexWhere((f) => f.folderPath == folderPath);
        if (folderIndex != -1) {
          parent = folders[folderIndex];
          continue;
        }

        var subFolder = NotesFolderFS(parent, folderPath, folderConfig);
        parent.addFolder(subFolder);
        parent = subFolder;
      }

      var file = UnopenedFile(
        filePath: fullFilePath,
        fileLastModified: DateTime.fromMillisecondsSinceEpoch(0),
        created: null,
        modified: null,
        oid: GitHash.zero(),
        parent: parent,
      );
      parent.addFile(file);
      var f = parent.loadNotes();
      futures.add(f);
    }

    // Load all the notes recursively
    await Future.wait(futures);
  }

  Future<void> clear() async {
    if (!enabled) return;
    var _ = await io.File(filePath).delete();
  }

  Future<void> buildCache(NotesFolderFS rootFolder) async {
    if (!enabled) return;

    var notes = rootFolder.getAllNotes();
    var sortingMode = rootFolder.config.sortingMode;
    var fileList =
        _fetchFirst10(notes, sortingMode).map((f) => f.filePath).toList();

    return saveToDisk(fileList);
  }

  Iterable<Note> _fetchFirst10(
    Iterable<Note> allNotes,
    SortingMode sortingMode,
  ) {
    var origFn = sortingMode.sortingFunction();

    reversedFn(Note a, Note b) {
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

  @visibleForTesting
  Future<List<String>> loadFromDisk() async {
    String contents = "";
    try {
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
      return json.decode(contents).cast<String>();
    } catch (ex, st) {
      Log.e("Exception - $ex for contents: $contents");
      await logExceptionWarning(ex, st);
      return [];
    }
  }

  @visibleForTesting
  Future<void> saveToDisk(List<String> files) async {
    var contents = json.encode(files);
    var newFilePath = filePath + ".new";

    var file = io.File(newFilePath);
    dynamic _;
    _ = await file.writeAsString(contents);
    _ = await file.rename(filePath);
  }
}
