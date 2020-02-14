import 'package:gitjournal/utils/datetime.dart';
import 'package:gitjournal/settings.dart';

import 'note.dart';
import 'md_yaml_doc.dart';

abstract class NoteSerializerInterface {
  void encode(Note note, MdYamlDoc data);
  void decode(MdYamlDoc data, Note note);
}

class NoteSerializationSettings {
  String modifiedKey = Settings.instance.yamlModifiedKey;
  String createdKey = "created";
  String titleKey = "title";
}

class NoteSerializer implements NoteSerializerInterface {
  var settings = NoteSerializationSettings();

  @override
  void encode(Note note, MdYamlDoc data) {
    if (note.created != null) {
      data.props[settings.createdKey] = toIso8601WithTimezone(note.created);
    } else {
      data.props.remove(settings.createdKey);
    }

    if (note.modified != null) {
      data.props[settings.modifiedKey] = toIso8601WithTimezone(note.modified);
    } else {
      data.props.remove(settings.modifiedKey);
    }

    if (note.title != null) {
      var title = note.title.trim();
      if (title.isNotEmpty) {
        data.props[settings.titleKey] = note.title;
      } else {
        data.props.remove(settings.titleKey);
      }
    } else {
      data.props.remove(settings.titleKey);
    }

    data.body = note.body;
  }

  @override
  void decode(MdYamlDoc data, Note note) {
    var modifiedKeyOptions = [
      "modified",
      "mod",
      "lastModified",
      "lastMod",
      "lastmodified",
      "lastmod",
    ];
    for (var i = 0; i < modifiedKeyOptions.length; i++) {
      var possibleKey = modifiedKeyOptions[i];
      var modifiedVal = data.props[possibleKey];
      if (modifiedVal != null) {
        note.modified = parseDateTime(modifiedVal.toString());
        settings.modifiedKey = possibleKey;
        break;
      }
    }

    note.body = data.body;
    note.created = parseDateTime(data.props[settings.createdKey]?.toString());
    note.title = data.props[settings.titleKey]?.toString() ?? "";
  }
}
