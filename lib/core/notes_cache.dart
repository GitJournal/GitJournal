import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:path/path.dart' as p;
import 'package:collection/collection.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/core/sorting_mode.dart';
import 'package:gitjournal/utils/logger.dart';

class NotesCache {
  final String filePath;
  final String notesBasePath;
  final bool enabled = true;

  static const CACHE_SIZE = 20;

  NotesCache({@required this.filePath, @required this.notesBasePath});

  Future load(NotesFolderFS rootFolder) async {
    if (!enabled) return;
    var fileList = await loadFromDisk();

    var sep = Platform.pathSeparator;
    var notesBasePath = this.notesBasePath;
    if (!notesBasePath.endsWith(sep)) {
      notesBasePath += sep;
    }

    for (var fullFilePath in fileList) {
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

        var subFolder = NotesFolderFS(parent, folderPath);
        parent.addFolder(subFolder);
        parent = subFolder;
      }

      var note = Note(parent, fullFilePath);
      note.load();
      parent.add(note);
    }
  }

  Future<void> clear() async {
    if (!enabled) return;
    return File(filePath).delete();
  }

  Future<void> buildCache(NotesFolderFS rootFolder) async {
    if (!enabled) return;

    print("Saving the NotesCache");

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
    var reversedFn = (Note a, Note b) {
      var r = origFn(a, b);
      if (r < 0) return 1;
      if (r > 0) return -1;
      return 0;
    };
    var heap = HeapPriorityQueue<Note>(reversedFn);

    for (var note in allNotes) {
      if (!heap.contains(note)) {
        heap.add(note);
      }
      if (heap.length > CACHE_SIZE) {
        heap.removeFirst();
      }
    }

    return heap.toList().reversed;
  }

  @visibleForTesting
  Future<List<String>> loadFromDisk() async {
    String contents = "";
    try {
      contents = await File(filePath).readAsString();
    } on FileSystemException catch (ex) {
      if (ex.osError.errorCode == 2 /* file not found */) {
        return [];
      }
      rethrow;
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
  Future<void> saveToDisk(List<String> files) {
    var contents = json.encode(files);
    return File(filePath).writeAsString(contents);
  }
}
