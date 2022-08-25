/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/core/folder/sorting_mode.dart';
import 'package:gitjournal/core/markdown/md_yaml_note_serializer.dart';
import 'package:gitjournal/core/notes/note.dart';
import 'package:gitjournal/editors/common_types.dart';
import 'package:gitjournal/folder_views/standard_view.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/settings_sharedpref.dart';

class NotesFolderConfig extends ChangeNotifier with SettingsSharedPref {
  NotesFolderConfig(this.id, this.pref);

  @override
  final String id;

  @override
  final SharedPreferences pref;

  var sortingField = SortingField.Default;
  var sortingOrder = SortingOrder.Default;

  var _defaultEditor = SettingsEditorType.Default;
  var defaultFileFormat = SettingsNoteFileFormat.Default;

  var defaultView = SettingsFolderViewType.Default;

  var folderViewHeaderType = "TitleGenerated";
  var showNoteSummary = true;
  var fileNameFormat = NoteFileNameFormat.Default;
  var journalFileNameFormat = NoteFileNameFormat.Default;

  var yamlHeaderEnabled = true;

  var yamlUnixTimestampMagnitude =
      NoteSerializationUnixTimestampMagnitude.Default;
  var yamlModifiedKey = "modified";
  var yamlModifiedFormat = NoteSerializationDateFormat.Default;
  var yamlCreatedKey = "created";
  var yamlCreatedFormat = NoteSerializationDateFormat.Default;
  var yamlTagsKey = "tags";
  var yamlEditorTypeKey = "type";
  var titleSettings = SettingsTitle.Default;

  var inlineTagPrefixes = {'#'};
  var imageLocationSpec = "."; // . means the same folder

  var emojify = false;

  /// The extensions with the dot. Eg - '.md'
  /// Case insensitive
  var allowedFileExts = <String>{'.md', '.txt', '.org'};

  void load() {
    fileNameFormat =
        NoteFileNameFormat.fromInternalString(getString("noteFileNameFormat"));
    journalFileNameFormat = NoteFileNameFormat.fromInternalString(
        getString("journalNoteFileNameFormat"));

    yamlUnixTimestampMagnitude =
        NoteSerializationUnixTimestampMagnitude.fromInternalString(
            getString("yamlUnixTimestampMagnitude"));
    yamlModifiedKey = getString("yamlModifiedKey") ?? yamlModifiedKey;
    yamlModifiedFormat = NoteSerializationDateFormat.fromInternalString(
        getString("yamlModifiedFormat"));
    yamlCreatedKey = getString("yamlCreatedKey") ?? yamlCreatedKey;
    yamlCreatedFormat = NoteSerializationDateFormat.fromInternalString(
        getString("yamlCreatedFormat"));
    yamlTagsKey = getString("yamlTagsKey") ?? yamlTagsKey;
    yamlEditorTypeKey = getString("yamlEditorTypeKey") ?? yamlEditorTypeKey;

    yamlHeaderEnabled = getBool("yamlHeaderEnabled") ?? yamlHeaderEnabled;

    sortingField = SortingField.fromInternalString(getString("sortingField"));
    sortingOrder = SortingOrder.fromInternalString(getString("sortingOrder"));
    _defaultEditor =
        SettingsEditorType.fromInternalString(getString("defaultEditor"));
    defaultView =
        SettingsFolderViewType.fromInternalString(getString("defaultView"));

    defaultFileFormat = SettingsNoteFileFormat.fromInternalString(
        getString("defaultFileFormat"));

    showNoteSummary = getBool("showNoteSummary") ?? showNoteSummary;
    folderViewHeaderType =
        getString("folderViewHeaderType") ?? folderViewHeaderType;

    imageLocationSpec = getString("imageLocationSpec") ?? imageLocationSpec;

    titleSettings =
        SettingsTitle.fromInternalString(getString("titleSettings"));

    inlineTagPrefixes = getStringSet("inlineTagPrefixes") ?? inlineTagPrefixes;

    emojify = getBool("emojify") ?? emojify;
    allowedFileExts = getStringSet("allowedFileExts") ?? allowedFileExts;
  }

  Future<void> save() async {
    var def = NotesFolderConfig(id, pref);

    await setString("noteFileNameFormat", fileNameFormat.toInternalString(),
        def.fileNameFormat.toInternalString());
    await setString(
        "journalNoteFileNameFormat",
        journalFileNameFormat.toInternalString(),
        def.journalFileNameFormat.toInternalString());

    await setString("sortingField", sortingField.toInternalString(),
        def.sortingField.toInternalString());
    await setString("sortingOrder", sortingOrder.toInternalString(),
        def.sortingOrder.toInternalString());
    await setString("defaultEditor", _defaultEditor.toInternalString(),
        def._defaultEditor.toInternalString());
    await setString("defaultView", defaultView.toInternalString(),
        def.defaultView.toInternalString());
    await setString("defaultFileFormat", defaultFileFormat.toInternalString(),
        def.defaultFileFormat.toInternalString());
    await setBool("showNoteSummary", showNoteSummary, def.showNoteSummary);
    await setString(
        "folderViewHeaderType", folderViewHeaderType, def.folderViewHeaderType);

    await setBool(
        "yamlHeaderEnabled", yamlHeaderEnabled, def.yamlHeaderEnabled);
    await setString(
        "yamlUnixTimestampMagnitude",
        yamlUnixTimestampMagnitude.toInternalString(),
        def.yamlUnixTimestampMagnitude.toInternalString());
    await setString("yamlModifiedKey", yamlModifiedKey, def.yamlModifiedKey);
    await setString("yamlModifiedFormat", yamlModifiedFormat.toInternalString(),
        def.yamlModifiedFormat.toInternalString());
    await setString("yamlCreatedKey", yamlCreatedKey, def.yamlCreatedKey);
    await setString("yamlCreatedFormat", yamlCreatedFormat.toInternalString(),
        def.yamlCreatedFormat.toInternalString());
    await setString("yamlTagsKey", yamlTagsKey, def.yamlTagsKey);
    await setString(
        "yamlEditorTypeKey", yamlEditorTypeKey, def.yamlEditorTypeKey);
    await setString("titleSettings", titleSettings.toInternalString(),
        def.titleSettings.toInternalString());

    await setStringSet(
        "inlineTagPrefixes", inlineTagPrefixes, def.inlineTagPrefixes);
    await setString(
        "imageLocationSpec", imageLocationSpec, def.imageLocationSpec);

    await setBool("emojify", emojify, def.emojify);

    await setStringSet("allowedFileExts", allowedFileExts, def.allowedFileExts);

    notifyListeners();
  }

  Map<String, String> toLoggableMap() {
    return <String, String>{
      "noteFileNameFormat": fileNameFormat.toInternalString(),
      "journalNoteFileNameFormat": journalFileNameFormat.toInternalString(),
      "yamlModifiedKey": yamlModifiedKey,
      "yamlCreatedKey": yamlCreatedKey,
      "yamlTagsKey": yamlTagsKey,
      "yamlEditorTypeKey": yamlEditorTypeKey,
      "yamlHeaderEnabled": yamlHeaderEnabled.toString(),
      "defaultEditor": _defaultEditor.toInternalString(),
      "defaultView": defaultView.toInternalString(),
      'defaultFileFormat': defaultFileFormat.toInternalString(),
      "sortingField": sortingField.toInternalString(),
      "sortingOrder": sortingOrder.toInternalString(),
      "showNoteSummary": showNoteSummary.toString(),
      "folderViewHeaderType": folderViewHeaderType,
      'imageLocationSpec': imageLocationSpec,
      'titleSettings': titleSettings.toInternalString(),
      'inlineTagPrefixes': inlineTagPrefixes.join(' '),
      'emojify': emojify.toString(),
      'allowedFileExts': allowedFileExts.join(' '),
    };
  }

  StandardViewHeader get viewHeader {
    switch (folderViewHeaderType) {
      case "TitleGenerated":
        return StandardViewHeader.TitleGenerated;
      case "FileName":
        return StandardViewHeader.FileName;
      case "TitleOrFileName":
      default:
        return StandardViewHeader.TitleOrFileName;
    }
  }

  set viewHeader(StandardViewHeader viewHeader) {
    switch (viewHeader) {
      case StandardViewHeader.FileName:
        folderViewHeaderType = "FileName";
        break;
      case StandardViewHeader.TitleGenerated:
        folderViewHeaderType = "TitleGenerated";
        break;
      case StandardViewHeader.TitleOrFileName:
        folderViewHeaderType = "TitleOrFileName";
        break;
    }
  }

  SortingMode get sortingMode {
    return SortingMode(sortingField, sortingOrder);
  }

  SettingsEditorType get defaultEditor {
    var format = defaultFileFormat.toFileFormat();

    if (editorSupported(format, _defaultEditor.toEditorType())) {
      return _defaultEditor;
    }

    var editor = NoteFileFormatInfo.defaultEditor(format);
    return SettingsEditorType.fromEditorType(editor);
  }

  set defaultEditor(SettingsEditorType editorType) {
    var format = defaultFileFormat.toFileFormat();

    if (editorSupported(format, editorType.toEditorType())) {
      _defaultEditor = editorType;
      return;
    }

    assert(false, "Why is the default editor incompatible with the file type");
    _defaultEditor = defaultEditor;
  }
}
