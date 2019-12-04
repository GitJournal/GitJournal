import 'note.dart';
import 'note_folder.dart';

// FIXME: Maybe the parent should be a part of the Note, and the NoteFolder
//        or maybe also a part of the NoteFolder
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
