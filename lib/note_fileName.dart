import 'package:gitjournal/note.dart';
import 'package:gitjournal/datetime_utils.dart';
import 'package:gitjournal/settings.dart';

String getFileName(Note note) {
  switch (Settings.instance.noteFileNameFormat) {
    case NoteFileNameFormat.Iso8601:
      return toIso8601(note.created) + ".md";
    case NoteFileNameFormat.Iso8601WithTimeZone:
      return toIso8601WithTimezone(note.created) + ".md";
    case NoteFileNameFormat.Iso8601WithTimeZoneWithoutColon:
      return toIso8601WithTimezone(note.created).replaceAll(":", "_") + ".md";
  }

  return note.created.toString();
}
