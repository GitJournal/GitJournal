/*
Copyright 2020-2021 Vishesh Handa <me@vhanda.in>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import 'package:path/path.dart' as p;

import 'package:gitjournal/core/link.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';

class LinkResolver {
  final Note inputNote;

  LinkResolver(this.inputNote);

  Note? resolveLink(Link l) {
    if (l.isWikiLink) {
      return resolveWikiLink(l.wikiTerm!);
    }

    var rootFolder = inputNote.parent.rootFolder;
    if (l.filePath!.startsWith(rootFolder.folderPath)) {
      var spec = l.filePath!.substring(rootFolder.folderPath.length);
      if (spec.startsWith('/')) {
        spec = spec.substring(1);
      }
      return _getNoteWithSpec(rootFolder, spec);
    }

    return null;
  }

  Note? resolve(String link) {
    if (isWikiLink(link)) {
      // FIXME: What if the case is different?
      return resolveWikiLink(stripWikiSyntax(link));
    }

    return _getNoteWithSpec(inputNote.parent, link);
  }

  static bool isWikiLink(String link) {
    return link.startsWith('[[') && link.endsWith(']]') && link.length > 4;
  }

  static String stripWikiSyntax(String link) {
    return link.substring(2, link.length - 2).trim();
  }

  Note? resolveWikiLink(String term) {
    if (term.contains(p.separator)) {
      var spec = p.normalize(term);
      return _getNoteWithSpec(inputNote.parent.rootFolder, spec);
    }

    var lowerCaseTerm = term.toLowerCase();

    var rootFolder = inputNote.parent.rootFolder;
    for (var note in rootFolder.getAllNotes()) {
      var fileName = note.fileName;
      var fileNameLower = fileName.toLowerCase();

      for (var ext in NoteFileFormatInfo.allowedExtensions) {
        if (fileNameLower.endsWith(ext)) {
          var termEndsWithSameExt = lowerCaseTerm.endsWith(ext);
          if (termEndsWithSameExt) {
            if (fileName == term) {
              return note;
            } else {
              break; // go to next note
            }
          }

          var f = fileName.substring(0, fileName.length - ext.length);
          if (f == term) {
            return note;
          }
        }
      }
    }

    return null;
  }

  Note? _getNoteWithSpec(NotesFolderFS folder, String spec) {
    var fullPath = p.normalize(p.join(folder.folderPath, spec));
    if (!fullPath.startsWith(folder.folderPath)) {
      folder = folder.rootFolder;
    }

    assert(fullPath.length == folder.folderPath.length);
    if (fullPath.length == folder.folderPath.length) {
      // FIXME: Why is this case occurring?
      return null;
    }
    spec = fullPath.substring(folder.folderPath.length + 1);

    var linkedNote = folder.getNoteWithSpec(spec);
    if (linkedNote != null) {
      return linkedNote;
    }

    for (var ext in NoteFileFormatInfo.allowedExtensions) {
      if (!spec.endsWith(ext)) {
        linkedNote = folder.getNoteWithSpec(spec + ext);
        if (linkedNote != null) {
          return linkedNote;
        }
      }
    }

    return null;
  }
}
