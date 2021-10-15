/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/note.dart';

class WikiLinksAutoAddProcessor {
  final NotesFolder rootFolder;

  WikiLinksAutoAddProcessor(this.rootFolder);

  void onSave(Note note) {
    //note.body = processBody(note.body, tags);
  }

  String processBody(String body, List<String> tags) {
    for (var tag in tags) {
      var regexp = RegExp('\\b$tag\\b');
      int start = 0;
      while (true) {
        var i = body.indexOf(regexp, start);
        if (i == -1) {
          break;
        }

        body = _replace(body, i, i + tag.length, '[[$tag]]');
        start = i + tag.length + 4;
      }
    }
    return body;
  }
}

String _replace(String body, int startPos, int endPos, String replacement) {
  return '${body.substring(0, startPos)}$replacement${body.substring(endPos)}';
}
