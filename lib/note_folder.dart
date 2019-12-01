import 'dart:io';

import 'package:gitjournal/note.dart';

class NoteFSEntity {
  NoteFolder parent;
  NoteFolder folder;
  Note note;

  NoteFSEntity(this.parent, {this.folder, this.note}) {
    assert(folder != null || note != null);
  }

  bool get isNote {
    return note != null;
  }

  bool get isFolder {
    return folder != null;
  }
}

class NoteFolder {
  List<NoteFSEntity> entities = [];
  String folderPath;

  NoteFolder(this.folderPath);

  // Recurisvely gets all Notes within this folder
  List<Note> getAllNotes() {
    var notes = <Note>[];

    for (var entity in entities) {
      if (entity.isNote) {
        notes.add(entity.note);
      } else {
        notes.addAll(entity.folder.getAllNotes());
      }
    }
    return notes;
  }

  // FIXME: This asynchronously loads everything. Maybe it should just list them, and the individual entities
  //        should be loaded as required?
  Future<void> load() async {
    final dir = Directory(folderPath);

    var lister = dir.list(recursive: false, followLinks: false);
    await for (var fsEntity in lister) {
      if (fsEntity is Directory) {
        var subFolder = NoteFolder(fsEntity.path);
        await subFolder.load();

        var noteFSEntity = NoteFSEntity(this, folder: subFolder);
        entities.add(noteFSEntity);
      }

      var note = Note(fsEntity.path);
      if (!note.filePath.toLowerCase().endsWith('.md')) {
        continue;
      }
      await note.load();

      var noteFSEntity = NoteFSEntity(this, note: note);
      entities.add(noteFSEntity);
    }
  }
}
