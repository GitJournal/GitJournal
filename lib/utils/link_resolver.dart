import 'package:gitjournal/core/note.dart';

class LinkResolver {
  final Note inputNote;

  LinkResolver(this.inputNote);

  Note resolve(String link) {
    var spec = link;
    var parent = inputNote.parent;

    if (link.startsWith('[[') && link.endsWith(']]') && link.length > 4) {
      // FIXME: What if the case is different?
      spec = link.substring(2, link.length - 2) + ".md";
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

// Test to write
// 1. [[Fire]] resolves to base folder [[Fire.md]]
// 2. [[Fire.md]] resolve to base folder [[Fire.md]]
// 3. [[Hello/Fire]] resolves to Hello/Fire.md
// 4. [[Hello | pipe]] resolves correctly
// 5. [[Hello Dear]] should resolve correctly
// 6. [[Hello Dear ]] check how it works in Obsidian (ignored extra spaces)
// 7. Should resolve to 'txt' files as well

// Normal Links
// 4. ./Fire.md -> resovles
// 5. Fire.md -> resolves
// 6. Fire2.md -> fails to resolve
// 7. Complex path ../../Foo/../bar/d.md
