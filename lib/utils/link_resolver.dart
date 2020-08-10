import 'package:gitjournal/core/note.dart';

class LinkResolver {
  final Note inputNote;

  LinkResolver(this.inputNote);

  Note resolve(String link) {
    var spec = link;
    var parent = inputNote.parent;

    if (link.startsWith('[[') && link.endsWith(']]') && link.length > 4) {
      // FIXME: What if the case is different?
      spec = link.substring(2, link.length - 2).trim();
    }

    if (link.startsWith('./')) {
      spec = link.substring(2);
    }

    var linkedNote = parent.getNoteWithSpec(spec);
    if (linkedNote != null) {
      return linkedNote;
    }

    if (!spec.endsWith('.md')) {
      linkedNote = parent.getNoteWithSpec(spec + '.md');
      if (linkedNote != null) {
        return linkedNote;
      }
    }

    if (!spec.endsWith('.txt')) {
      linkedNote = parent.getNoteWithSpec(spec + '.txt');
      if (linkedNote != null) {
        return linkedNote;
      }
    }

    return null;
  }
}
