/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'dart:collection';
import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:yaml/yaml.dart';

import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/generated/core.pb.dart' as pb;
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/utils/datetime.dart';
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

enum DateFormat {
  Iso8601,
  UnixTimeStamp,
  None,
}

class NoteSerializationSettings {
  String modifiedKey = "modified";
  String createdKey = "created";
  String titleKey = "title";
  String editorTypeKey = "type";
  String tagsKey = "tags";

  bool tagsInString = false;
  bool tagsHaveHash = false;

  SettingsTitle titleSettings = SettingsTitle.Default;

  var modifiedFormat = DateFormat.Iso8601;
  var createdFormat = DateFormat.Iso8601;

  var emojify = false;

  NoteSerializationSettings.fromConfig(NotesFolderConfig config) {
    modifiedKey = config.yamlModifiedKey;
    createdKey = config.yamlCreatedKey;
    tagsKey = config.yamlTagsKey;
    editorTypeKey = config.yamlEditorTypeKey;
    titleSettings = config.titleSettings;

    // FIXME: modified / created format!
  }
  NoteSerializationSettings();

  NoteSerializationSettings clone() {
    var s = NoteSerializationSettings();
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
      modifiedKey: modifiedKey,
      createdKey: createdKey,
      titleKey: titleKey,
      typeKey: editorTypeKey,
      tagsKey: tagsKey,
      tagsInString: tagsInString,
      tagsHaveHash: tagsHaveHash,
      emojify: emojify,
      createdFormat: _protoDateFormat(createdFormat),
      modifiedFormat: _protoDateFormat(modifiedFormat),
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

  static pb.DateFormat _protoDateFormat(DateFormat fmt) {
    switch (fmt) {
      case DateFormat.None:
        return pb.DateFormat.None;
      case DateFormat.Iso8601:
        return pb.DateFormat.Iso8601;
      case DateFormat.UnixTimeStamp:
        return pb.DateFormat.UnixTimeStamp;
    }
  }

  static DateFormat _fromProtoDateFormat(pb.DateFormat fmt) {
    switch (fmt) {
      case pb.DateFormat.None:
        return DateFormat.None;
      case pb.DateFormat.Iso8601:
        return DateFormat.Iso8601;
      case pb.DateFormat.UnixTimeStamp:
        return DateFormat.UnixTimeStamp;
    }

    return DateFormat.None;
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
    dynamic _;

    switch (settings.createdFormat) {
      case DateFormat.Iso8601:
        props[settings.createdKey] = toIso8601WithTimezone(note.created);
        break;
      case DateFormat.UnixTimeStamp:
        props[settings.createdKey] = toUnixTimeStamp(note.created);
        break;
      case DateFormat.None:
        _ = props.remove(settings.createdKey);
        break;
    }

    switch (settings.modifiedFormat) {
      case DateFormat.Iso8601:
        props[settings.modifiedKey] = toIso8601WithTimezone(note.modified);
        break;
      case DateFormat.UnixTimeStamp:
        props[settings.modifiedKey] = toUnixTimeStamp(note.modified);
        break;
      case DateFormat.None:
        _ = props.remove(settings.modifiedKey);
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
          _ = props.remove(settings.titleKey);
        }
      } else {
        if (title.isNotEmpty) {
          props[settings.titleKey] = title;
        } else {
          _ = props.remove(settings.titleKey);
        }
      }
    } else {
      _ = props.remove(settings.titleKey);
    }

    if (note.type != NoteType.Unknown) {
      var type = note.type.toString().substring(9); // Remove "NoteType."
      props[settings.editorTypeKey] = type;
    } else {
      _ = props.remove(settings.editorTypeKey);
    }

    if (note.tags.isEmpty) {
      _ = props.remove(settings.tagsKey);
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
        var _ = props.remove(key);
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
    assert(file.filePath.isNotEmpty);

    var propsUsed = <String>{};

    DateTime? modified;
    for (var possibleKey in modifiedKeyOptions) {
      var val = data.props[possibleKey];
      if (val != null) {
        if (val is int) {
          modified = parseUnixTimeStamp(val);
          settings.modifiedFormat = DateFormat.UnixTimeStamp;
        } else {
          modified = parseDateTime(val.toString());
          settings.modifiedFormat = DateFormat.Iso8601;
        }
        settings.modifiedKey = possibleKey;

        var _ = propsUsed.add(possibleKey);
        break;
      }
    }
    if (modified == null) {
      settings.modifiedFormat = DateFormat.None;
    }

    var body = settings.emojify ? emojiParser.emojify(data.body) : data.body;

    DateTime? created;
    for (var possibleKey in createdKeyOptions) {
      var val = data.props[possibleKey];
      if (val != null) {
        if (val is int) {
          created = parseUnixTimeStamp(val);
          settings.createdFormat = DateFormat.UnixTimeStamp;
        } else {
          created = parseDateTime(val.toString());
          settings.createdFormat = DateFormat.Iso8601;
        }
        settings.createdKey = possibleKey;

        var _ = propsUsed.add(possibleKey);
        break;
      }
    }
    if (created == null) {
      settings.createdFormat = DateFormat.None;
    }

    //
    // Title parsing
    //
    String? title;
    if (data.props.containsKey(settings.titleKey)) {
      title = data.props[settings.titleKey]?.toString() ?? "";
      title = settings.emojify ? emojiParser.emojify(title) : title;

      var _ = propsUsed.add(settings.titleKey);
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
        var _ = propsUsed.add(settings.editorTypeKey);
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
          var _ = propsUsed.add(settings.tagsKey);
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
