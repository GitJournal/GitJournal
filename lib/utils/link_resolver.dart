import 'package:path/path.dart' as p;

import 'package:gitjournal/core/link.dart';
import 'package:gitjournal/core/note.dart';

class LinkResolver {
  final Note inputNote;

  LinkResolver(this.inputNote);

  Note resolveLink(Link l) {
    var href = l.filePath;
    href ??= '[[${l.term}]]';

    return resolve(href);
  }

  Note resolve(String link) {
    var spec = link;
    var folder = inputNote.parent;

    if (link.startsWith('[[') && link.endsWith(']]') && link.length > 4) {
      // FIXME: What if the case is different?
      spec = link.substring(2, link.length - 2).trim();

      // In the case of Wiki Links we always resolve from the Root Folder
      folder = inputNote.parent.rootFolder;
    }

    if (link.startsWith('./')) {
      spec = link.substring(2);
    }

    if (spec.contains(p.separator)) {
      spec = p.normalize(spec);
    }

    var linkedNote = folder.getNoteWithSpec(spec);
    if (linkedNote != null) {
      return linkedNote;
    }

    if (!spec.endsWith('.md')) {
      linkedNote = folder.getNoteWithSpec(spec + '.md');
      if (linkedNote != null) {
        return linkedNote;
      }
    }

    if (!spec.endsWith('.txt')) {
      linkedNote = folder.getNoteWithSpec(spec + '.txt');
      if (linkedNote != null) {
        return linkedNote;
      }
    }

    return null;
  }
}
