import 'dart:io';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/utils/datetime.dart';
import 'package:gitjournal/settings.dart';
import 'package:path/path.dart' as p;

String getFileName(Note note) {
  switch (Settings.instance.noteFileNameFormat) {
    case NoteFileNameFormat.FromTitle:
      if (note.title.isNotEmpty) {
        return buildTitleFileName(note.parent.folderPath, note.title);
      } else {
        return toIso8601WithTimezone(note.created) + ".md";
      }
      break;
    case NoteFileNameFormat.Iso8601:
      return toIso8601(note.created) + ".md";
    case NoteFileNameFormat.Iso8601WithTimeZone:
      return toIso8601WithTimezone(note.created) + ".md";
    case NoteFileNameFormat.Iso8601WithTimeZoneWithoutColon:
      return toIso8601WithTimezone(note.created).replaceAll(":", "_") + ".md";
  }

  return note.created.toString();
}

String buildTitleFileName(String parentDir, String title) {
  var fileName = title + ".md";
  var fullPath = p.join(parentDir, fileName);
  var file = File(fullPath);
  if (!file.existsSync()) {
    return fileName;
  }

  for (var i = 1;; i++) {
    var fileName = title + "_$i.md";
    var fullPath = p.join(parentDir, fileName);
    var file = File(fullPath);
    if (!file.existsSync()) {
      return fileName;
    }
  }
}
