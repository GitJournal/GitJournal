/*
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:path/path.dart' as p;

import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/link.dart';
import 'package:gitjournal/core/note.dart';

class LinkResolver {
  final Note inputNote;
  final NotesFolderConfig folderConfig;

  LinkResolver(this.inputNote) : folderConfig = inputNote.parent.config;

  Note? resolveLink(Link l) {
    if (l.isWikiLink) {
      return resolveWikiLink(l.wikiTerm!);
    }

    var spec = l.filePath!;
    if (spec.startsWith('/')) {
      spec = spec.substring(1);
    }

    var rootFolder = inputNote.parent.rootFolder;
    return _getNoteWithSpec(rootFolder, spec);
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

      for (var ext in folderConfig.allowedFileExts) {
        if (p.extension(fileNameLower) == ext) {
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
    spec = p.normalize(p.join(folder.folderPath, spec));
    folder = folder.rootFolder;

    var linkedNote = folder.getNoteWithSpec(spec);
    if (linkedNote != null) {
      return linkedNote;
    }

    for (var ext in folderConfig.allowedFileExts) {
      if (ext.isEmpty) {
        continue;
      }
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
