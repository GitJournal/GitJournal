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
}
