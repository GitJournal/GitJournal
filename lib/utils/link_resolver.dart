import 'package:path/path.dart' as p;

import 'package:gitjournal/core/link.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';

class LinkResolver {
  final Note inputNote;

  LinkResolver(this.inputNote);

  Note resolveLink(Link l) {
    if (l.isWikiLink) {
      return resolveWikiLink(l.wikiTerm);
    }

    var rootFolder = inputNote.parent.rootFolder;
    assert(l.filePath.startsWith(rootFolder.folderPath));
    var spec = l.filePath.substring(rootFolder.folderPath.length + 1);

    return rootFolder.getNoteWithSpec(spec);
  }

  Note resolve(String link) {
    if (link.startsWith('[[') && link.endsWith(']]') && link.length > 4) {
      // FIXME: What if the case is different?
      var wikiLinkTerm = link.substring(2, link.length - 2).trim();
      return resolveWikiLink(wikiLinkTerm);
    }

    var folder = inputNote.parent;
    var spec = link;

    if (link.startsWith('./')) {
      spec = link.substring(2);
    }

    if (spec.contains(p.separator)) {
      spec = p.normalize(spec);
    }

    return _getNoteWithSpec(folder, spec);
  }

  Note resolveWikiLink(String term) {
    if (term.contains(p.separator)) {
      var spec = p.normalize(term);
      return _getNoteWithSpec(inputNote.parent.rootFolder, spec);
    }

    var lowerCaseTerm = term.toLowerCase();
    var termEndsWithMd = lowerCaseTerm.endsWith('.md');
    var termEndsWithTxt = lowerCaseTerm.endsWith('.txt');

    var rootFolder = inputNote.parent.rootFolder;
    for (var note in rootFolder.getAllNotes()) {
      var fileName = note.fileName;
      if (fileName.toLowerCase().endsWith('.md')) {
        if (termEndsWithMd) {
          if (fileName == term) {
            return note;
          } else {
            continue;
          }
        }

        var f = fileName.substring(0, fileName.length - 3);
        if (f == term) {
          return note;
        }
      } else if (fileName.toLowerCase().endsWith('.txt')) {
        if (termEndsWithTxt) {
          if (fileName == term) {
            return note;
          } else {
            continue;
          }
        }

        var f = fileName.substring(0, fileName.length - 4);
        if (f == term) {
          return note;
        }
      }
    }

    return null;
  }

  Note _getNoteWithSpec(NotesFolderFS folder, String spec) {
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
