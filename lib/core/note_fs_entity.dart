import 'note.dart';
import 'notes_folder.dart';

class NoteFSEntity {
  NotesFolder folder;
  Note note;

  NoteFSEntity({this.folder, this.note}) {
    assert(folder != null || note != null);
  }

  bool get isNote {
    return note != null;
  }

  bool get isFolder {
    return folder != null;
  }
}
