import 'package:gitjournal/utils/datetime.dart';

import 'note.dart';
import 'serializers.dart';

abstract class NoteSerializerInterface {
  void encode(Note note, NoteData data);
  void decode(NoteData data, Note note);
}

class NoteSerializationSettings {
  String modifiedKey = "modified";
  String createdKey = "created";
  String titleKey = "title";
}

class NoteSerializer implements NoteSerializerInterface {
  var settings = NoteSerializationSettings();

  @override
  void encode(Note note, NoteData data) {
    if (note.created != null)
      data.props[settings.createdKey] = toIso8601WithTimezone(note.created);
    else
      data.props.remove(settings.createdKey);

    if (note.modified != null)
      data.props[settings.modifiedKey] = toIso8601WithTimezone(note.modified);
    else
      data.props.remove(settings.modifiedKey);

    if (note.title != null && note.title.isNotEmpty)
      data.props[settings.titleKey] = note.title;

    data.body = note.body;
  }

  @override
  void decode(NoteData data, Note note) {
    note.body = data.body;
    note.created = parseDateTime(data.props[settings.createdKey]?.toString());
    note.modified = parseDateTime(data.props[settings.modifiedKey]?.toString());
    note.title = data.props[settings.titleKey]?.toString();
  }
}
