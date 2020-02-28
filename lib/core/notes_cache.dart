import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';

enum NotesCacheSortOrder {
  Modified,
  Created,
}

class NotesCache {
  final String filePath;
  final String notesBasePath;

  NotesCache({@required this.filePath, @required this.notesBasePath});

  void updateCache(NotesFolder rootFolder) {}

  Future<NotesFolder> load() async {
    var fileList = await loadFromDisk();
    var rootFolder = NotesFolder(null, this.notesBasePath);

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

        var folders = parent.subFolders;
        var folderIndex = folders.indexWhere((f) => f.folderPath == folderPath);
        if (folderIndex != -1) {
          parent = folders[folderIndex];
          continue;
        }

        var subFolder = NotesFolder(parent, folderPath);
        parent.addFolder(subFolder);
        parent = subFolder;
      }

      var note = Note(parent, fullFilePath);
      note.load();
      parent.add(note);
    }

    return rootFolder;
  }

  Future buildCache(NotesFolder rootFolder, NotesCacheSortOrder sortOrder) {
    // FIXME: This could be optimized quite a bit
    var files = rootFolder.getAllNotes();
    files.sort(_buildSortingFunc(sortOrder));
    files = files.sublist(0, 10);
    var fileList = files.map((f) => f.filePath);

    return saveToDisk(fileList);
  }

  Function _buildSortingFunc(NotesCacheSortOrder order) {
    switch (order) {
      case NotesCacheSortOrder.Modified:
        return (Note a, Note b) {
          var a1 = a.modified ?? a.fileLastModified;
          var b1 = b.modified ?? b.fileLastModified;
          return a1.isBefore(b1);
        };

      // FIXE: We should have an actual created date!
      case NotesCacheSortOrder.Created:
        return (Note a, Note b) {
          var a1 = a.created ?? a.fileLastModified;
          var b1 = b.created ?? b.fileLastModified;
          return a1.isBefore(b1);
        };
    }

    assert(false, "Why is the sorting Func nill?");
    return () => {};
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

    return json.decode(contents).cast<String>();
  }

  @visibleForTesting
  Future saveToDisk(List<String> files) {
    var contents = json.encode(files);
    return File(filePath).writeAsString(contents);
  }
}
