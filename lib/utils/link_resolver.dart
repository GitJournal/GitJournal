import 'package:gitjournal/core/note.dart';

class LinkResolver {
  final Note inputNote;

  LinkResolver(this.inputNote);

  Note resolve(String link) {
    var spec = link;
    var rootFolder = inputNote.parent.rootFolder;

    if (link.startsWith('[[') && link.endsWith(']]') && link.length > 4) {
      // FIXME: What if the case is different?
      spec = link.substring(2, link.length - 2).trim();
    }

    if (link.startsWith('./')) {
      spec = link.substring(2);
    }

    var linkedNote = rootFolder.getNoteWithSpec(spec);
    if (linkedNote != null) {
      return linkedNote;
    }

    if (!spec.endsWith('.md')) {
      linkedNote = rootFolder.getNoteWithSpec(spec + '.md');
      if (linkedNote != null) {
        return linkedNote;
      }
    }

    if (!spec.endsWith('.txt')) {
      linkedNote = rootFolder.getNoteWithSpec(spec + '.txt');
      if (linkedNote != null) {
        return linkedNote;
      }
    }

    return null;
  }
}
