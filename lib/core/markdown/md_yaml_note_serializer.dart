/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'dart:collection';
import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/folder/sorting_mode.dart';
import 'package:gitjournal/core/notes/note.dart';
import 'package:gitjournal/generated/core.pb.dart' as pb;
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/utils/datetime.dart';
import 'package:yaml/yaml.dart';

import '../file/file.dart';
import '../note.dart';
import 'md_yaml_doc.dart';

abstract class NoteSerializerInterface {
  MdYamlDoc encode(Note note);
  Note decode({
    required MdYamlDoc data,
    required NotesFolderFS parent,
    required File file,
    required NoteFileFormat fileFormat,
  });
}

var emojiParser = EmojiParser();

class NoteSerializationUnixTimestampMagnitude extends GjSetting {
  static const Seconds = NoteSerializationUnixTimestampMagnitude(
    Lk.settingsNoteMetaDataUnixTimestampDateMagnitudeSeconds,
    "seconds",
  );
  static const Milliseconds = NoteSerializationUnixTimestampMagnitude(
    Lk.settingsNoteMetaDataUnixTimestampDateMagnitudeMilliseconds,
    "milliseconds",
  );
  static const Default = Seconds;

  const NoteSerializationUnixTimestampMagnitude(super.lk, super.str);

  static const options = <NoteSerializationUnixTimestampMagnitude>[
    Seconds,
    Milliseconds,
  ];

  static NoteSerializationUnixTimestampMagnitude fromInternalString(
          String? str) =>
      GjSetting.fromInternalString(options, Default, str)
          as NoteSerializationUnixTimestampMagnitude;

  static NoteSerializationUnixTimestampMagnitude fromPublicString(
          BuildContext context, String str) =>
      GjSetting.fromPublicString(context, options, Default, str)
          as NoteSerializationUnixTimestampMagnitude;
}

class NoteSerializationDateFormat extends GjSetting {
  static const Iso8601 = NoteSerializationDateFormat(
      Lk.settingsNoteMetaDataDateFormatIso8601, "iso8601");
  static const UnixTimeStamp = NoteSerializationDateFormat(
      Lk.settingsNoteMetaDataDateFormatUnixTimestamp, "unixTimestamp");
  static const YearMonthDay = NoteSerializationDateFormat(
      Lk.settingsNoteMetaDataDateFormatYearMonthDay, "yearMonthDay");
  static const None = NoteSerializationDateFormat(
      Lk.settingsNoteMetaDataDateFormatNone, "none");
  static const Default = Iso8601;

  const NoteSerializationDateFormat(super.lk, super.str);

  static const options = <NoteSerializationDateFormat>[
    Iso8601,
    UnixTimeStamp,
    YearMonthDay,
    None,
  ];

  static NoteSerializationDateFormat fromInternalString(String? str) =>
      GjSetting.fromInternalString(options, Default, str)
          as NoteSerializationDateFormat;

  static NoteSerializationDateFormat fromPublicString(
          BuildContext context, String str) =>
      GjSetting.fromPublicString(context, options, Default, str)
          as NoteSerializationDateFormat;
}

class NoteSerializationSettings {
  var unixTimestampMagnitude = NoteSerializationUnixTimestampMagnitude.Default;
  String modifiedKey = "modified";
  var modifiedFormat = NoteSerializationDateFormat.Default;
  String createdKey = "created";
  var createdFormat = NoteSerializationDateFormat.Default;
  String titleKey = "title";
  String editorTypeKey = "type";
  String tagsKey = "tags";

  bool tagsInString = false;
  bool tagsHaveHash = false;

  SettingsTitle titleSettings = SettingsTitle.Default;

  var emojify = false;

  NoteSerializationSettings.fromConfig(NotesFolderConfig config) {
    unixTimestampMagnitude = config.yamlUnixTimestampMagnitude;
    modifiedKey = config.yamlModifiedKey;
    modifiedFormat = config.yamlModifiedFormat;
    createdKey = config.yamlCreatedKey;
    createdFormat = config.yamlCreatedFormat;
    tagsKey = config.yamlTagsKey;
    editorTypeKey = config.yamlEditorTypeKey;
    titleSettings = config.titleSettings;
  }
  NoteSerializationSettings();

  NoteSerializationSettings clone() {
    var s = NoteSerializationSettings();
    s.unixTimestampMagnitude = unixTimestampMagnitude;
    s.createdKey = createdKey;
    s.createdFormat = createdFormat;
    s.modifiedKey = modifiedKey;
    s.modifiedFormat = modifiedFormat;
    s.titleKey = titleKey;
    s.editorTypeKey = editorTypeKey;
    s.tagsKey = tagsKey;
    s.tagsInString = tagsInString;
    s.tagsHaveHash = tagsHaveHash;
    s.titleSettings = titleSettings;
    s.emojify = emojify;
    return s;
  }

  pb.NoteSerializationSettings toProtoBuf() {
    return pb.NoteSerializationSettings(
      unixTimestampMagnitude:
          _protoUnixTimestampMagnitude(unixTimestampMagnitude),
      modifiedKey: modifiedKey,
      modifiedFormat: _protoDateFormat(modifiedFormat),
      createdKey: createdKey,
      createdFormat: _protoDateFormat(createdFormat),
      titleKey: titleKey,
      typeKey: editorTypeKey,
      tagsKey: tagsKey,
      tagsInString: tagsInString,
      tagsHaveHash: tagsHaveHash,
      emojify: emojify,
      titleSettings: titleSettings.toInternalString(),
    );
  }

  static NoteSerializationSettings fromProtoBuf(
      pb.NoteSerializationSettings p) {
    var s = NoteSerializationSettings();
    s.createdKey = p.createdKey;
    s.createdFormat = _fromProtoDateFormat(p.createdFormat);
    s.modifiedKey = p.modifiedKey;
    s.modifiedFormat = _fromProtoDateFormat(p.modifiedFormat);
    s.titleKey = p.titleKey;
    s.editorTypeKey = p.typeKey;
    s.tagsKey = p.tagsKey;
    s.tagsInString = p.tagsInString;
    s.tagsHaveHash = p.tagsHaveHash;
    s.emojify = p.emojify;
    s.titleSettings = SettingsTitle.fromInternalString(p.titleSettings);

    return s;
  }

  static pb.UnixTimestampMagnitude _protoUnixTimestampMagnitude(
      NoteSerializationUnixTimestampMagnitude magnitude) {
    switch (magnitude) {
      case NoteSerializationUnixTimestampMagnitude.Milliseconds:
        return pb.UnixTimestampMagnitude.Milliseconds;
      case NoteSerializationUnixTimestampMagnitude.Seconds:
      default:
        return pb.UnixTimestampMagnitude.Seconds;
    }
  }

  static pb.DateFormat _protoDateFormat(NoteSerializationDateFormat fmt) {
    switch (fmt) {
      case NoteSerializationDateFormat.None:
        return pb.DateFormat.None;
      case NoteSerializationDateFormat.UnixTimeStamp:
        return pb.DateFormat.UnixTimeStamp;
      case NoteSerializationDateFormat.YearMonthDay:
        return pb.DateFormat.YearMonthDay;
      case NoteSerializationDateFormat.Iso8601:
      default:
        return pb.DateFormat.Iso8601;
    }
  }

  static NoteSerializationDateFormat _fromProtoDateFormat(pb.DateFormat fmt) {
    switch (fmt) {
      case pb.DateFormat.None:
        return NoteSerializationDateFormat.None;
      case pb.DateFormat.Iso8601:
        return NoteSerializationDateFormat.Iso8601;
      case pb.DateFormat.YearMonthDay:
        return NoteSerializationDateFormat.YearMonthDay;
      case pb.DateFormat.UnixTimeStamp:
        return NoteSerializationDateFormat.UnixTimeStamp;
    }

    return NoteSerializationDateFormat.None;
  }

  @override
  bool operator ==(Object other) =>
      other is NoteSerializationSettings &&
      runtimeType == other.runtimeType &&
      toProtoBuf().toString() == other.toProtoBuf().toString();

  @override
  int get hashCode {
    throw UnimplementedError();
  }
}

// Rename to MarkdownYamlNoteSerializer
class NoteSerializer implements NoteSerializerInterface {
  final NoteSerializationSettings settings;

  NoteSerializer.fromConfig(this.settings);
  NoteSerializer.raw() : settings = NoteSerializationSettings();

  static final createdKeyOptions = ["created", "date"];
  static final modifiedKeyOptions = [
    "modified",
    "mod",
    "lastModified",
    "lastMod",
    "lastmodified",
    "lastmod",
    "updated",
  ];
  static final editorTypeKeyOptions = ["type", "editorType"];
  static final tagKeyOptions = ["tags", "categories", "keywords"];

  @override
  MdYamlDoc encode(Note note) {
    var body = settings.emojify ? emojiParser.unemojify(note.body) : note.body;

    // HACKish support for Txt and OrgFiles
    if (!note.canHaveMetadata) {
      return MdYamlDoc(body: body);
    }

    var props = <String, dynamic>{};

    switch (settings.createdFormat) {
      case NoteSerializationDateFormat.Iso8601:
        props[settings.createdKey] = toIso8601WithTimezone(note.created);
        break;
      case NoteSerializationDateFormat.YearMonthDay:
        props[settings.createdKey] = toDateString(note.created);
        break;
      case NoteSerializationDateFormat.UnixTimeStamp:
        props[settings.createdKey] =
            toUnixTimeStamp(note.created, settings.unixTimestampMagnitude);
        break;
      case NoteSerializationDateFormat.None:
        props.remove(settings.createdKey);
        break;
    }

    switch (settings.modifiedFormat) {
      case NoteSerializationDateFormat.Iso8601:
        props[settings.modifiedKey] = toIso8601WithTimezone(note.modified);
        break;
      case NoteSerializationDateFormat.YearMonthDay:
        props[settings.modifiedKey] = toDateString(note.modified);
        break;
      case NoteSerializationDateFormat.UnixTimeStamp:
        props[settings.modifiedKey] =
            toUnixTimeStamp(note.modified, settings.unixTimestampMagnitude);
        break;
      case NoteSerializationDateFormat.None:
        props.remove(settings.modifiedKey);
        break;
    }

    var noteTitle = note.title;
    if (noteTitle != null) {
      noteTitle = noteTitle.trim();
      var title =
          settings.emojify ? emojiParser.unemojify(noteTitle) : noteTitle;
      if (settings.titleSettings == SettingsTitle.InH1) {
        if (title.isNotEmpty) {
          body = '# $title\n\n$body';
          props.remove(settings.titleKey);
        }
      } else {
        if (title.isNotEmpty) {
          props[settings.titleKey] = title;
        } else {
          props.remove(settings.titleKey);
        }
      }
    } else {
      props.remove(settings.titleKey);
    }

    if (note.type != NoteType.Unknown) {
      var type = note.type.toString().substring(9); // Remove "NoteType."
      props[settings.editorTypeKey] = type;
    } else {
      props.remove(settings.editorTypeKey);
    }

    if (note.tags.isEmpty) {
      props.remove(settings.tagsKey);
    } else {
      props[settings.tagsKey] = note.tags.toList();
      if (settings.tagsInString) {
        var tags = note.tags;
        if (settings.tagsHaveHash) {
          tags = tags.map((e) => '#$e').toSet().lock;
        }
        props[settings.tagsKey] = tags.join(' ');
      }
    }

    note.extraProps.forEach((key, value) {
      props[key] = value;
    });

    LinkedHashMap<String, dynamic> sortedProps = LinkedHashMap();
    for (var key in note.propsList) {
      var v = props[key];
      if (v != null) {
        sortedProps[key] = v;
        props.remove(key);
      }
    }

    for (var e in props.entries) {
      sortedProps[e.key] = e.value;
    }

    return MdYamlDoc(body: body, props: sortedProps.lock);
  }

  static Note decodeNote({
    required MdYamlDoc data,
    required NotesFolderFS parent,
    required File file,
    required NoteSerializationSettings settings,
    required NoteFileFormat fileFormat,
  }) {
    var serializer = NoteSerializer.fromConfig(settings.clone());
    return serializer.decode(
      data: data,
      parent: parent,
      file: file,
      fileFormat: fileFormat,
    );
  }

  @override
  Note decode({
    required MdYamlDoc data,
    required NotesFolderFS parent,
    required File file,
    required NoteFileFormat fileFormat,
  }) {
    var propsUsed = <String>{};

    DateTime? modified;
    for (var possibleKey in modifiedKeyOptions) {
      var val = data.props[possibleKey];
      if (val != null) {
        if (val is int) {
          modified = parseUnixTimeStamp(val, settings.unixTimestampMagnitude);
          settings.modifiedFormat = NoteSerializationDateFormat.UnixTimeStamp;
        } else {
          var str = val.toString();
          if (str.length == 10) {
            modified = parseDateTime(str);
            settings.modifiedFormat = NoteSerializationDateFormat.YearMonthDay;
          } else {
            modified = parseDateTime(str);
            settings.modifiedFormat = NoteSerializationDateFormat.Iso8601;
          }
        }
        settings.modifiedKey = possibleKey;

        propsUsed.add(possibleKey);
        break;
      }
    }
    if (modified == null) {
      settings.modifiedFormat = NoteSerializationDateFormat.None;
    }

    var body = settings.emojify ? emojiParser.emojify(data.body) : data.body;

    DateTime? created;
    for (var possibleKey in createdKeyOptions) {
      var val = data.props[possibleKey];
      if (val != null) {
        if (val is int) {
          created = parseUnixTimeStamp(val, settings.unixTimestampMagnitude);
          settings.createdFormat = NoteSerializationDateFormat.UnixTimeStamp;
        } else {
          var str = val.toString();
          if (str.length == 10) {
            created = parseDateTime(val.toString());
            settings.createdFormat = NoteSerializationDateFormat.YearMonthDay;
          } else {
            created = parseDateTime(val.toString());
            settings.createdFormat = NoteSerializationDateFormat.Iso8601;
          }
        }
        settings.createdKey = possibleKey;

        propsUsed.add(possibleKey);
        break;
      }
    }
    if (created == null) {
      settings.createdFormat = NoteSerializationDateFormat.None;
    }

    //
    // Title parsing
    //
    String? title;
    if (data.props.containsKey(settings.titleKey)) {
      title = data.props[settings.titleKey]?.toString() ?? "";
      title = settings.emojify ? emojiParser.emojify(title) : title;

      propsUsed.add(settings.titleKey);
      settings.titleSettings = SettingsTitle.InYaml;
    } else {
      var startsWithH1 = false;
      for (var line in LineSplitter.split(body)) {
        if (line.trim().isEmpty) {
          continue;
        }
        startsWithH1 = line.startsWith('#') && !line.startsWith('##');
        break;
      }

      if (startsWithH1) {
        var titleStartIndex = body.indexOf('#');
        var titleEndIndex = body.indexOf('\n', titleStartIndex);
        if (titleEndIndex == -1 || titleEndIndex == body.length) {
          title = body.substring(titleStartIndex + 1).trim();
          body = "";
        } else {
          title = body.substring(titleStartIndex + 1, titleEndIndex).trim();
          body = body.substring(titleEndIndex + 1).trim();
        }
      }
    }
    if (title != null && title.isEmpty) {
      title = null;
    }

    var type = NoteType.Unknown;
    for (var possibleKey in editorTypeKeyOptions) {
      var typeStr = data.props[possibleKey];
      switch (typeStr) {
        case "Checklist":
          type = NoteType.Checklist;
          break;
        case "Journal":
          type = NoteType.Journal;
          break;
        default:
          type = NoteType.Unknown;
          break;
      }
      if (typeStr != null) {
        propsUsed.add(settings.editorTypeKey);
        break;
      }
    }

    Set<String>? _tags;
    try {
      for (var possibleKey in tagKeyOptions) {
        var tags = data.props[possibleKey];
        if (tags != null) {
          if (tags is YamlList) {
            _tags = tags.map((t) => t.toString()).toSet();
          } else if (tags is List) {
            _tags = tags.map((t) => t.toString()).toSet();
          } else if (tags is String) {
            settings.tagsInString = true;
            var allTags = tags.split(' ');
            settings.tagsHaveHash = allTags.every((t) => t.startsWith('#'));
            if (settings.tagsHaveHash) {
              allTags.removeWhere((e) => e.length <= 1);
              allTags = allTags.map((e) => e.substring(1)).toList();
            }

            _tags = allTags.toSet();
          } else {
            Log.e("Note Tags Decoding Failed: $tags");
          }

          settings.tagsKey = possibleKey;
          propsUsed.add(settings.tagsKey);
          break;
        }
      }
    } catch (e) {
      Log.e("Note Decoding Failed: $e");
    }

    // Extra Props
    var extraProps = <String, dynamic>{};
    data.props.forEach((key, val) {
      if (propsUsed.contains(key)) {
        return;
      }

      extraProps[key] = val;
    });

    return Note.build(
      parent: parent,
      file: file,
      modified: modified,
      created: created,
      body: body,
      title: title,
      noteType: type,
      extraProps: extraProps,
      tags: ISet(_tags),
      propsList: data.props.keys.toIList(),
      serializerSettings: settings,
      fileFormat: fileFormat,
    );
  }

  @override
  bool operator ==(Object other) {
    throw UnimplementedError();
  }

  @override
  int get hashCode {
    throw UnimplementedError();
  }
}
