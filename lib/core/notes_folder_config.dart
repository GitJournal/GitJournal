import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/core/sorting_mode.dart';
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

  var defaultEditor = SettingsEditorType.Default;
  var defaultView = SettingsFolderViewType.Default;

  var folderViewHeaderType = "TitleGenerated";
  var showNoteSummary = true;
  var fileNameFormat = NoteFileNameFormat.Default;
  var journalFileNameFormat = NoteFileNameFormat.Default;

  var yamlHeaderEnabled = true;

  var yamlModifiedKey = "modified";
  var yamlCreatedKey = "created";
  var yamlTagsKey = "tags";
  var titleSettings = SettingsTitle.Default;

  var inlineTagPrefixes = {'#'};
  var imageLocationSpec = "."; // . means the same folder

  var emojify = false;

  void load() {
    fileNameFormat =
        NoteFileNameFormat.fromInternalString(getString("noteFileNameFormat"));
    journalFileNameFormat = NoteFileNameFormat.fromInternalString(
        getString("journalNoteFileNameFormat"));

    yamlModifiedKey = getString("yamlModifiedKey") ?? yamlModifiedKey;
    yamlCreatedKey = getString("yamlCreatedKey") ?? yamlCreatedKey;
    yamlTagsKey = getString("yamlTagsKey") ?? yamlTagsKey;

    yamlHeaderEnabled = getBool("yamlHeaderEnabled") ?? yamlHeaderEnabled;

    sortingField = SortingField.fromInternalString(getString("sortingField"));
    sortingOrder = SortingOrder.fromInternalString(getString("sortingOrder"));
    defaultEditor =
        SettingsEditorType.fromInternalString(getString("defaultEditor"));
    defaultView =
        SettingsFolderViewType.fromInternalString(getString("defaultView"));

    showNoteSummary = getBool("showNoteSummary") ?? showNoteSummary;
    folderViewHeaderType =
        getString("folderViewHeaderType") ?? folderViewHeaderType;

    imageLocationSpec = getString("imageLocationSpec") ?? imageLocationSpec;

    titleSettings =
        SettingsTitle.fromInternalString(getString("titleSettings"));

    inlineTagPrefixes = getStringSet("inlineTagPrefixes") ?? inlineTagPrefixes;

    emojify = getBool("emojify") ?? emojify;
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
    await setString("defaultEditor", defaultEditor.toInternalString(),
        def.defaultEditor.toInternalString());
    await setString("defaultView", defaultView.toInternalString(),
        def.defaultView.toInternalString());
    await setBool("showNoteSummary", showNoteSummary, def.showNoteSummary);
    await setString(
        "folderViewHeaderType", folderViewHeaderType, def.folderViewHeaderType);

    await setBool(
        "yamlHeaderEnabled", yamlHeaderEnabled, def.yamlHeaderEnabled);
    await setString("yamlModifiedKey", yamlModifiedKey, def.yamlModifiedKey);
    await setString("yamlCreatedKey", yamlCreatedKey, def.yamlCreatedKey);
    await setString("yamlTagsKey", yamlTagsKey, def.yamlTagsKey);
    await setString("titleSettings", titleSettings.toInternalString(),
        def.titleSettings.toInternalString());

    await setStringSet(
        "inlineTagPrefixes", inlineTagPrefixes, def.inlineTagPrefixes);
    await setString(
        "imageLocationSpec", imageLocationSpec, def.imageLocationSpec);

    await setBool("emojify", emojify, def.emojify);

    notifyListeners();
  }

  Map<String, String> toLoggableMap() {
    return <String, String>{
      "noteFileNameFormat": fileNameFormat.toInternalString(),
      "journalNoteFileNameFormat": journalFileNameFormat.toInternalString(),
      "yamlModifiedKey": yamlModifiedKey,
      "yamlCreatedKey": yamlCreatedKey,
      "yamlTagsKey": yamlTagsKey,
      "yamlHeaderEnabled": yamlHeaderEnabled.toString(),
      "defaultEditor": defaultEditor.toInternalString(),
      "defaultView": defaultView.toInternalString(),
      "sortingField": sortingField.toInternalString(),
      "sortingOrder": sortingOrder.toInternalString(),
      "showNoteSummary": showNoteSummary.toString(),
      "folderViewHeaderType": folderViewHeaderType,
      'imageLocationSpec': imageLocationSpec,
      'titleSettings': titleSettings.toInternalString(),
      'inlineTagPrefixes': inlineTagPrefixes.join(' '),
      'emojify': emojify.toString(),
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
}
