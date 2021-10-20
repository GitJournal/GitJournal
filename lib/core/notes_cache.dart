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
import 'package:gitjournal/core/file/unopened_files.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/folder/sorting_mode.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/logger/logger.dart';

class NotesCache {
  final String folderPath;
  final String notesBasePath;
  final bool enabled = true;
  final NotesFolderConfig folderConfig;

  String get filePath => p.join(folderPath, 'notes_cache_$version.json');

  static const CACHE_SIZE = 20;
  static const version = 1;

  NotesCache({
    required this.folderPath,
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

    for (var file in fileList) {
      if (!file.filePath.startsWith(notesBasePath)) {
        continue;
      }

      var filePath = file.filePath.substring(notesBasePath.length);
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

      var unopenFile = UnopenedFile(
        filePath: file.filePath,
        fileLastModified: DateTime.fromMillisecondsSinceEpoch(0),
        created: null,
        modified: null,
        oid: GitHash.zero(),
        parent: parent,
      );
      parent.addFile(unopenFile);
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
    var fileList = _fetchFirst10(notes, sortingMode);

    return saveToDisk(fileList);
  }

  Iterable<File> _fetchFirst10(
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

  @visibleForTesting
  Future<List<File>> loadFromDisk() async {
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
