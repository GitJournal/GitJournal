/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart' as io;

import 'package:gitjournal/core/file/file_storage.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/folder/sorting_mode.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/generated/core.pb.dart' as pb;
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/utils/file.dart';

class NotesCache {
  final String folderPath;
  final String repoPath;
  final FileStorage fileStorage;

  static const enabled = true;

  String get filePath => p.join(folderPath, 'notes_cache_v$version');

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

    var pbNotes = await loadFromDisk();
    Log.i("Notes Cache Loaded: ${pbNotes.length} items");

    assert(repoPath.endsWith(p.separator));

    // Ensure there are no duplicates
    assert(pbNotes.toSet().length == pbNotes.length);

    var selectFolders = <NotesFolderFS>{};
    for (var pbNote in pbNotes) {
      var parentFolderPath = p.dirname(pbNote.file.filePath);
      var parent = rootFolder.getOrBuildFolderWithSpec(parentFolderPath);

      var note = Note.fromProtoBuf(parent, pbNote);
      parent.add(note);
      var _ = selectFolders.add(parent);
    }
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

  Iterable<Note> _fetchTop(
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
      if (note.pinned) {
        continue;
      }
      if (!heap.contains(note)) {
        heap.add(note);
      }
      if (heap.length > CACHE_SIZE) {
        var _ = heap.removeFirst();
      }
    }

    return heap.toList().reversed;
  }

  Iterable<Note> _fetchPinned(Iterable<Note> allNotes) sync* {
    for (var note in allNotes) {
      if (note.pinned) {
        yield note;
      }
    }
  }

  @visibleForTesting
  Future<List<pb.Note>> loadFromDisk() async {
    var contents = Uint8List(0);
    try {
      assert(filePath.startsWith(p.separator));
      contents = await io.File(filePath).readAsBytes();
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
      return pb.NoteList.fromBuffer(contents).notes;
    } catch (ex, st) {
      Log.e("Failed to load NotesCache", ex: ex, stacktrace: st);
      await logExceptionWarning(ex, st);
      return [];
    }
  }

  @visibleForTesting
  Future<void> saveToDisk(Iterable<Note> notes) async {
    var contents = pb.NoteList(
      notes: notes.map((n) => n.toProtoBuf()),
    ).writeToBuffer();

    var r = await saveFileSafely(filePath, contents);
    if (r.isFailure) {
      Log.e("Notes Cache saveToDisk", result: r);
    }
  }
}
