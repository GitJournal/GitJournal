/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:path/path.dart' as p;

class CommitMessageBuilder {
  String addNote(String spec) => "Added Note $spec";
  String addFolder(String spec) => "Added Folder $spec";

  String renameFolder(String oldSpec, String newSpec) =>
      "Renamed Folder $oldSpec -> $newSpec";

  String renameNote(String oldSpec, String newSpec) {
    if (p.basenameWithoutExtension(oldSpec) ==
        p.basenameWithoutExtension(newSpec)) {
      return "Renamed Note $oldSpec -> ${p.extension(newSpec)}";
    }
    return "Renamed Note $oldSpec -> $newSpec";
  }

  String renameFile(String oldSpec, String newSpec) =>
      "Renamed File $oldSpec -> $newSpec";

  String moveNote(String oldSpec, String newSpec) =>
      "Moved Note $oldSpec -> $newSpec";

  String moveNotes(List<String> oldSpecs, List<String> newSpecs) {
    var msg = "Moved ${oldSpecs.length} Notes\n\n";

    for (var i = 0; i < oldSpecs.length; i++) {
      var oldSpec = oldSpecs[i];
      var newSpec = newSpecs[i];

      msg += '* $oldSpec -> $newSpec';
    }
    return msg;
  }

  String removeNote(String spec) => "Removed Note $spec";
  String removeFolder(String spec) => "Removed Folder $spec";
  String removeNotes(Iterable<String> specs) {
    var list = specs.toList();
    var msg = "Removed ${list.length} Notes\n\n";
    for (var spec in list) {
      msg += '- $spec';
    }
    return msg;
  }

  String updateNote(String spec) => "Updated Note $spec";
}
