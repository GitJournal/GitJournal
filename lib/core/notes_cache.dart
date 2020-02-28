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
      parent.add(note);
    }

    return rootFolder;
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

//
// To Add: buildCache(NotesFolder rootFolder)
// To Add: either noteAdded / noteRemoved
//         or monitor the root NotesFolder directly
