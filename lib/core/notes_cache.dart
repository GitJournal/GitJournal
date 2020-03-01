import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gitjournal/settings.dart';
import 'package:path/path.dart' as p;

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';

class NotesCache {
  final String filePath;
  final String notesBasePath;

  NotesCache({@required this.filePath, @required this.notesBasePath});

  void updateCache(NotesFolder rootFolder) {}

  Future load(NotesFolder rootFolder) async {
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
  }

  Future buildCache(NotesFolder rootFolder, SortingMode sortOrder) {
    print("Saving the NotesCache");
    // FIXME: This could be optimized quite a bit
    var files = rootFolder.getAllNotes();
    assert(files.every((n) => n.loadState == NoteLoadState.Loaded));

    files.sort(_buildSortingFunc(sortOrder));
    files = files.sublist(0, 10);
    var fileList = files.map((f) => f.filePath).toList();

    return saveToDisk(fileList);
  }

  Function _buildSortingFunc(SortingMode order) {
    switch (order) {
      case SortingMode.Modified:
        return (Note a, Note b) {
          var aDt = a.modified ?? a.fileLastModified;
          var bDt = b.modified ?? b.fileLastModified;
          if (aDt == null && bDt != null) {
            return -1;
          }
          if (aDt != null && bDt == null) {
            return -1;
          }
          if (bDt == null || aDt == null) {
            return 0;
          }
          return bDt.compareTo(aDt);
        };

      // FIXE: We should have an actual created date!
      case SortingMode.Created:
        return (Note a, Note b) {
          var aDt = a.created ?? a.fileLastModified;
          var bDt = b.created ?? b.fileLastModified;
          if (aDt == null && bDt != null) {
            return -1;
          }
          if (aDt != null && bDt == null) {
            return -1;
          }
          if (bDt == null || aDt == null) {
            return 0;
          }
          return bDt.compareTo(aDt);
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
