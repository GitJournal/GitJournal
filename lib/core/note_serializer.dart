/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'dart:convert';

import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:yaml/yaml.dart';

import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/utils/datetime.dart';
import 'md_yaml_doc.dart';
import 'note.dart';

abstract class NoteSerializerInterface {
  void encode(Note note, MdYamlDoc data);
  void decode(MdYamlDoc data, Note note);
}

var emojiParser = EmojiParser();

enum DateFormat {
  Iso8601,
  UnixTimeStamp,
}

class NoteSerializationSettings {
  String modifiedKey = "modified";
  String createdKey = "created";
  String titleKey = "title";
  String typeKey = "type";
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
    titleSettings = config.titleSettings;

    // FIXME: modified / created format!
  }
  NoteSerializationSettings();
}

class NoteSerializer implements NoteSerializerInterface {
  var settings = NoteSerializationSettings();

  NoteSerializer.fromConfig(this.settings);
  NoteSerializer.raw();

  @override
  void encode(Note note, MdYamlDoc data) {
    data.body = settings.emojify ? emojiParser.unemojify(note.body) : note.body;

    if (note.created != null) {
      switch (settings.createdFormat) {
        case DateFormat.Iso8601:
          data.props[settings.createdKey] =
              toIso8601WithTimezone(note.created!);
          break;
        case DateFormat.UnixTimeStamp:
          data.props[settings.createdKey] = toUnixTimeStamp(note.created!);
      }
    } else {
      data.props.remove(settings.createdKey);
    }

    if (note.modified != null) {
      switch (settings.modifiedFormat) {
        case DateFormat.Iso8601:
          data.props[settings.modifiedKey] =
              toIso8601WithTimezone(note.modified!);
          break;
        case DateFormat.UnixTimeStamp:
          data.props[settings.modifiedKey] = toUnixTimeStamp(note.modified!);
      }
    } else {
      data.props.remove(settings.modifiedKey);
    }

    if (note.title.isNotEmpty) {
      var title = settings.emojify
          ? emojiParser.unemojify(note.title.trim())
          : note.title.trim();
      if (settings.titleSettings == SettingsTitle.InH1) {
        if (title.isNotEmpty) {
          data.body = '# $title\n\n${data.body}';
          data.props.remove(settings.titleKey);
        }
      } else {
        if (title.isNotEmpty) {
          data.props[settings.titleKey] = title;
        } else {
          data.props.remove(settings.titleKey);
        }
      }
    } else {
      data.props.remove(settings.titleKey);
    }

    if (note.type != NoteType.Unknown) {
      var type = note.type.toString().substring(9); // Remove "NoteType."
      data.props[settings.typeKey] = type;
    } else {
      data.props.remove(settings.typeKey);
    }

    if (note.tags.isEmpty) {
      data.props.remove(settings.tagsKey);
    } else {
      data.props[settings.tagsKey] = note.tags.toList();
      if (settings.tagsInString) {
        var tags = note.tags;
        if (settings.tagsHaveHash) {
          tags = tags.map((e) => '#$e').toSet();
        }
        data.props[settings.tagsKey] = tags.join(' ');
      }
    }

    note.extraProps.forEach((key, value) {
      data.props[key] = value;
    });
  }

  @override
  void decode(MdYamlDoc data, Note note) {
    var propsUsed = <String>{};

    var modifiedKeyOptions = [
      "modified",
      "mod",
      "lastModified",
      "lastMod",
      "lastmodified",
      "lastmod",
      "updated",
    ];
    for (var possibleKey in modifiedKeyOptions) {
      var val = data.props[possibleKey];
      if (val != null) {
        if (val is int) {
          note.modified = parseUnixTimeStamp(val);
          settings.modifiedFormat = DateFormat.UnixTimeStamp;
        } else {
          note.modified = parseDateTime(val.toString());
          settings.modifiedFormat = DateFormat.Iso8601;
        }
        settings.modifiedKey = possibleKey;

        propsUsed.add(possibleKey);
        break;
      }
    }

    note.body = settings.emojify ? emojiParser.emojify(data.body) : data.body;

    var createdKeyOptions = [
      "created",
      "date",
    ];
    for (var possibleKey in createdKeyOptions) {
      var val = data.props[possibleKey];
      if (val != null) {
        if (val is int) {
          note.created = parseUnixTimeStamp(val);
          settings.createdFormat = DateFormat.UnixTimeStamp;
        } else {
          note.created = parseDateTime(val.toString());
          settings.createdFormat = DateFormat.Iso8601;
        }
        settings.createdKey = possibleKey;

        propsUsed.add(possibleKey);
        break;
      }
    }

    //
    // Title parsing
    //
    if (data.props.containsKey(settings.titleKey)) {
      var title = data.props[settings.titleKey]?.toString() ?? "";
      note.title = settings.emojify ? emojiParser.emojify(title) : title;

      propsUsed.add(settings.titleKey);
      settings.titleSettings = SettingsTitle.InYaml;
    } else {
      var startsWithH1 = false;
      for (var line in LineSplitter.split(note.body)) {
        if (line.trim().isEmpty) {
          continue;
        }
        startsWithH1 = line.startsWith('#') && !line.startsWith('##');
        break;
      }

      if (startsWithH1) {
        var titleStartIndex = note.body.indexOf('#');
        var titleEndIndex = note.body.indexOf('\n', titleStartIndex);
        if (titleEndIndex == -1 || titleEndIndex == note.body.length) {
          note.title = note.body.substring(titleStartIndex + 1).trim();
          note.body = "";
        } else {
          note.title =
              note.body.substring(titleStartIndex + 1, titleEndIndex).trim();
          note.body = note.body.substring(titleEndIndex + 1).trim();
        }
      }
    }

    var type = data.props[settings.typeKey];
    switch (type) {
      case "Checklist":
        note.type = NoteType.Checklist;
        break;
      case "Journal":
        note.type = NoteType.Journal;
        break;
      default:
        note.type = NoteType.Unknown;
        break;
    }
    if (type != null) {
      propsUsed.add(settings.typeKey);
    }

    try {
      var tagKeyOptions = [
        "tags",
        "categories",
        "keywords",
      ];
      for (var possibleKey in tagKeyOptions) {
        var tags = data.props[possibleKey];
        if (tags != null) {
          if (tags is YamlList) {
            note.tags = tags.map((t) => t.toString()).toSet();
          } else if (tags is List) {
            note.tags = tags.map((t) => t.toString()).toSet();
          } else if (tags is String) {
            settings.tagsInString = true;
            var allTags = tags.split(' ');
            settings.tagsHaveHash = allTags.every((t) => t.startsWith('#'));
            if (settings.tagsHaveHash) {
              allTags.removeWhere((e) => e.length <= 1);
              allTags = allTags.map((e) => e.substring(1)).toList();
            }

            note.tags = allTags.toSet();
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
    note.extraProps = {};
    data.props.forEach((key, val) {
      if (propsUsed.contains(key)) {
        return;
      }

      note.extraProps[key] = val;
    });
  }
}
