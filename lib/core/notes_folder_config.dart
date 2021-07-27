import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/core/sorting_mode.dart';
import 'package:gitjournal/folder_views/standard_view.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/settings_sharedpref.dart';

class NotesFolderConfig extends ChangeNotifier with SettingsSharedPref {
  NotesFolderConfig(this.id);

  @override
  final String id;

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

  void load(SharedPreferences pref) {
    fileNameFormat = NoteFileNameFormat.fromInternalString(
        getString(pref, "noteFileNameFormat"));
    journalFileNameFormat = NoteFileNameFormat.fromInternalString(
        getString(pref, "journalNoteFileNameFormat"));

    yamlModifiedKey = getString(pref, "yamlModifiedKey") ?? yamlModifiedKey;
    yamlCreatedKey = getString(pref, "yamlCreatedKey") ?? yamlCreatedKey;
    yamlTagsKey = getString(pref, "yamlTagsKey") ?? yamlTagsKey;

    yamlHeaderEnabled = getBool(pref, "yamlHeaderEnabled") ?? yamlHeaderEnabled;

    sortingField =
        SortingField.fromInternalString(getString(pref, "sortingField"));
    sortingOrder =
        SortingOrder.fromInternalString(getString(pref, "sortingOrder"));
    defaultEditor =
        SettingsEditorType.fromInternalString(getString(pref, "defaultEditor"));
    defaultView = SettingsFolderViewType.fromInternalString(
        getString(pref, "defaultView"));

    showNoteSummary = getBool(pref, "showNoteSummary") ?? showNoteSummary;
    folderViewHeaderType =
        getString(pref, "folderViewHeaderType") ?? folderViewHeaderType;

    imageLocationSpec =
        getString(pref, "imageLocationSpec") ?? imageLocationSpec;

    titleSettings =
        SettingsTitle.fromInternalString(getString(pref, "titleSettings"));

    inlineTagPrefixes =
        getStringSet(pref, "inlineTagPrefixes") ?? inlineTagPrefixes;
  }

  Future<void> save() async {
    var pref = await SharedPreferences.getInstance();
    var defaultSet = NotesFolderConfig(id);

    await setString(
        pref,
        "noteFileNameFormat",
        fileNameFormat.toInternalString(),
        defaultSet.fileNameFormat.toInternalString());
    await setString(
        pref,
        "journalNoteFileNameFormat",
        journalFileNameFormat.toInternalString(),
        defaultSet.journalFileNameFormat.toInternalString());

    await setString(pref, "sortingField", sortingField.toInternalString(),
        defaultSet.sortingField.toInternalString());
    await setString(pref, "sortingOrder", sortingOrder.toInternalString(),
        defaultSet.sortingOrder.toInternalString());
    await setString(pref, "defaultEditor", defaultEditor.toInternalString(),
        defaultSet.defaultEditor.toInternalString());
    await setString(pref, "defaultView", defaultView.toInternalString(),
        defaultSet.defaultView.toInternalString());
    await setBool(
        pref, "showNoteSummary", showNoteSummary, defaultSet.showNoteSummary);
    await setString(pref, "folderViewHeaderType", folderViewHeaderType,
        defaultSet.folderViewHeaderType);

    await setBool(pref, "yamlHeaderEnabled", yamlHeaderEnabled,
        defaultSet.yamlHeaderEnabled);
    await setString(
        pref, "yamlModifiedKey", yamlModifiedKey, defaultSet.yamlModifiedKey);
    await setString(
        pref, "yamlCreatedKey", yamlCreatedKey, defaultSet.yamlCreatedKey);
    await setString(pref, "yamlTagsKey", yamlTagsKey, defaultSet.yamlTagsKey);
    await setString(pref, "titleSettings", titleSettings.toInternalString(),
        defaultSet.titleSettings.toInternalString());

    await setStringSet(pref, "inlineTagPrefixes", inlineTagPrefixes,
        defaultSet.inlineTagPrefixes);
    await setString(pref, "imageLocationSpec", imageLocationSpec,
        defaultSet.imageLocationSpec);

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
