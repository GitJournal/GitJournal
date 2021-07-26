/*
Copyright 2020-2021 Vishesh Handa <me@vhanda.in>
                    Roland Fredenhagen <important@van-fredenhagen.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:icloud_documents_path/icloud_documents_path.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:gitjournal/core/sorting_mode.dart';
import 'package:gitjournal/editors/common_types.dart';
import 'package:gitjournal/folder_views/common_types.dart';
import 'settings_sharedpref.dart';

const DEFAULT_ID = "0";
const FOLDER_NAME_KEY = "remoteGitRepoPath";
const SETTINGS_VERSION = 3;

class Settings extends ChangeNotifier with SettingsSharedPref {
  Settings(this.id);

  @override
  final String id;

  String folderName = "journal";

  // Git Settings
  String gitAuthor = "GitJournal";
  String gitAuthorEmail = "app@gitjournal.io";
  String sshPublicKey = "";
  String sshPrivateKey = "";
  String sshPassword = "";

  NoteFileNameFormat noteFileNameFormat = NoteFileNameFormat.Default;
  NoteFileNameFormat journalNoteFileNameFormat = NoteFileNameFormat.Default;

  String yamlModifiedKey = "modified";
  String yamlCreatedKey = "created";
  String yamlTagsKey = "tags";
  String customMetaData = "";
  SettingsTitle titleSettings = SettingsTitle.Default;

  bool yamlHeaderEnabled = true;
  String defaultNewNoteFolderSpec = "";
  String journalEditordefaultNewNoteFolderSpec = "";
  bool journalEditorSingleNote = false;

  RemoteSyncFrequency remoteSyncFrequency = RemoteSyncFrequency.Default;
  SortingField sortingField = SortingField.Default;
  SortingOrder sortingOrder = SortingOrder.Default;
  SettingsEditorType defaultEditor = SettingsEditorType.Default;
  SettingsFolderViewType defaultView = SettingsFolderViewType.Default;
  bool showNoteSummary = true;
  String folderViewHeaderType = "TitleGenerated";
  int version = SETTINGS_VERSION;

  SettingsHomeScreen homeScreen = SettingsHomeScreen.Default;
  SettingsTheme theme = SettingsTheme.Default;

  SettingsMarkdownDefaultView markdownDefaultView =
      SettingsMarkdownDefaultView.Default;
  SettingsMarkdownDefaultView markdownLastUsedView =
      SettingsMarkdownDefaultView.Edit;

  String imageLocationSpec = "."; // . means the same folder

  bool zenMode = false;

  bool swipeToDelete = true;
  bool emojiParser = true;

  Set<String> inlineTagPrefixes = {'#'};

  bool bottomMenuBar = true;
  bool confirmDelete = true;
  bool hardWrap = false;

  bool storeInternally = true;
  String storageLocation = "";

  void load(SharedPreferences pref) {
    gitAuthor = getString(pref, "gitAuthor") ?? gitAuthor;
    gitAuthorEmail = getString(pref, "gitAuthorEmail") ?? gitAuthorEmail;
    sshPublicKey = getString(pref, "sshPublicKey") ?? sshPublicKey;
    sshPrivateKey = getString(pref, "sshPrivateKey") ?? sshPrivateKey;
    sshPassword = getString(pref, "sshPassword") ?? sshPassword;

    noteFileNameFormat = NoteFileNameFormat.fromInternalString(
        getString(pref, "noteFileNameFormat"));
    journalNoteFileNameFormat = NoteFileNameFormat.fromInternalString(
        getString(pref, "journalNoteFileNameFormat"));

    yamlModifiedKey = getString(pref, "yamlModifiedKey") ?? yamlModifiedKey;
    yamlCreatedKey = getString(pref, "yamlCreatedKey") ?? yamlCreatedKey;
    yamlTagsKey = getString(pref, "yamlTagsKey") ?? yamlTagsKey;
    customMetaData = getString(pref, "customMetaData") ?? customMetaData;

    yamlHeaderEnabled = getBool(pref, "yamlHeaderEnabled") ?? yamlHeaderEnabled;
    defaultNewNoteFolderSpec =
        getString(pref, "defaultNewNoteFolderSpec") ?? defaultNewNoteFolderSpec;
    journalEditordefaultNewNoteFolderSpec =
        getString(pref, "journalEditordefaultNewNoteFolderSpec") ??
            journalEditordefaultNewNoteFolderSpec;
    journalEditorSingleNote =
        getBool(pref, "journalEditorSingleNote") ?? journalEditorSingleNote;

    remoteSyncFrequency = RemoteSyncFrequency.fromInternalString(
        getString(pref, "remoteSyncFrequency"));

    sortingField =
        SortingField.fromInternalString(getString(pref, "sortingField"));
    sortingOrder =
        SortingOrder.fromInternalString(getString(pref, "sortingOrder"));
    defaultEditor =
        SettingsEditorType.fromInternalString(getString(pref, "defaultEditor"));
    defaultView = SettingsFolderViewType.fromInternalString(
        getString(pref, "defaultView"));

    markdownDefaultView = SettingsMarkdownDefaultView.fromInternalString(
        getString(pref, "markdownDefaultView"));
    markdownLastUsedView = SettingsMarkdownDefaultView.fromInternalString(
        getString(pref, "markdownLastUsedView"));
    if (markdownLastUsedView == SettingsMarkdownDefaultView.LastUsed) {
      markdownLastUsedView = SettingsMarkdownDefaultView.Edit;
    }

    showNoteSummary = getBool(pref, "showNoteSummary") ?? showNoteSummary;
    folderViewHeaderType =
        getString(pref, "folderViewHeaderType") ?? folderViewHeaderType;

    version = getInt(pref, "settingsVersion") ?? version;
    emojiParser = getBool(pref, "emojiParser") ?? emojiParser;

    homeScreen =
        SettingsHomeScreen.fromInternalString(getString(pref, "homeScreen"));
    theme = SettingsTheme.fromInternalString(getString(pref, "theme"));

    imageLocationSpec =
        getString(pref, "imageLocationSpec") ?? imageLocationSpec;

    zenMode = getBool(pref, "zenMode") ?? zenMode;
    titleSettings =
        SettingsTitle.fromInternalString(getString(pref, "titleSettings"));
    swipeToDelete = getBool(pref, "swipeToDelete") ?? swipeToDelete;

    inlineTagPrefixes =
        getStringSet(pref, "inlineTagPrefixes") ?? inlineTagPrefixes;

    // From AppState
    folderName = getString(pref, FOLDER_NAME_KEY) ?? folderName;

    bottomMenuBar = getBool(pref, "bottomMenuBar") ?? bottomMenuBar;
    confirmDelete = getBool(pref, "confirmDelete") ?? confirmDelete;
    storeInternally = getBool(pref, "storeInternally") ?? storeInternally;
    storageLocation = getString(pref, "storageLocation") ?? "";

    hardWrap = getBool(pref, "hardWrap") ?? hardWrap;
  }

  Future<void> save() async {
    var pref = await SharedPreferences.getInstance();
    var defaultSet = Settings(id);

    await setString(pref, "gitAuthor", gitAuthor, defaultSet.gitAuthor);
    await setString(
        pref, "gitAuthorEmail", gitAuthorEmail, defaultSet.gitAuthorEmail);
    await setString(
        pref, "sshPublicKey", sshPublicKey, defaultSet.sshPublicKey);
    await setString(
        pref, "sshPrivateKey", sshPrivateKey, defaultSet.sshPrivateKey);
    await setString(pref, "sshPassword", sshPassword, defaultSet.sshPassword);

    await setString(
        pref,
        "noteFileNameFormat",
        noteFileNameFormat.toInternalString(),
        defaultSet.noteFileNameFormat.toInternalString());
    await setString(
        pref,
        "journalNoteFileNameFormat",
        journalNoteFileNameFormat.toInternalString(),
        defaultSet.journalNoteFileNameFormat.toInternalString());
    await setString(
        pref, "yamlModifiedKey", yamlModifiedKey, defaultSet.yamlModifiedKey);
    await setString(
        pref, "yamlCreatedKey", yamlCreatedKey, defaultSet.yamlCreatedKey);
    await setString(pref, "yamlTagsKey", yamlTagsKey, defaultSet.yamlTagsKey);
    await setString(
        pref, "customMetaData", customMetaData, defaultSet.customMetaData);
    await setBool(pref, "yamlHeaderEnabled", yamlHeaderEnabled,
        defaultSet.yamlHeaderEnabled);
    await setString(pref, "defaultNewNoteFolderSpec", defaultNewNoteFolderSpec,
        defaultSet.defaultNewNoteFolderSpec);
    await setString(
        pref,
        "journalEditordefaultNewNoteFolderSpec",
        journalEditordefaultNewNoteFolderSpec,
        defaultSet.journalEditordefaultNewNoteFolderSpec);
    await setBool(pref, "journalEditorSingleNote", journalEditorSingleNote,
        defaultSet.journalEditorSingleNote);
    await setString(
        pref,
        "remoteSyncFrequency",
        remoteSyncFrequency.toInternalString(),
        defaultSet.remoteSyncFrequency.toInternalString());
    await setString(pref, "sortingField", sortingField.toInternalString(),
        defaultSet.sortingField.toInternalString());
    await setString(pref, "sortingOrder", sortingOrder.toInternalString(),
        defaultSet.sortingOrder.toInternalString());
    await setString(pref, "defaultEditor", defaultEditor.toInternalString(),
        defaultSet.defaultEditor.toInternalString());
    await setString(pref, "defaultView", defaultView.toInternalString(),
        defaultSet.defaultView.toInternalString());
    await setString(
        pref,
        "markdownDefaultView",
        markdownDefaultView.toInternalString(),
        defaultSet.markdownDefaultView.toInternalString());
    await setString(
        pref,
        "markdownLastUsedView",
        markdownLastUsedView.toInternalString(),
        defaultSet.markdownLastUsedView.toInternalString());
    await setBool(
        pref, "showNoteSummary", showNoteSummary, defaultSet.showNoteSummary);
    await setString(pref, "folderViewHeaderType", folderViewHeaderType,
        defaultSet.folderViewHeaderType);
    await setBool(pref, "emojiParser", emojiParser, defaultSet.emojiParser);
    await setString(pref, "homeScreen", homeScreen.toInternalString(),
        defaultSet.homeScreen.toInternalString());
    await setString(pref, "theme", theme.toInternalString(),
        defaultSet.theme.toInternalString());

    await setString(pref, "imageLocationSpec", imageLocationSpec,
        defaultSet.imageLocationSpec);
    await setBool(pref, "zenMode", zenMode, defaultSet.zenMode);
    await setString(pref, "titleSettings", titleSettings.toInternalString(),
        defaultSet.titleSettings.toInternalString());
    await setBool(
        pref, "swipeToDelete", swipeToDelete, defaultSet.swipeToDelete);
    await setStringSet(pref, "inlineTagPrefixes", inlineTagPrefixes,
        defaultSet.inlineTagPrefixes);
    await setBool(
        pref, "bottomMenuBar", bottomMenuBar, defaultSet.bottomMenuBar);
    await setBool(
        pref, "confirmDelete", confirmDelete, defaultSet.confirmDelete);
    await setBool(
        pref, "storeInternally", storeInternally, defaultSet.storeInternally);
    await setString(
        pref, "storageLocation", storageLocation, defaultSet.storageLocation);

    await setInt(pref, "settingsVersion", version, defaultSet.version);

    await setString(pref, FOLDER_NAME_KEY, folderName, defaultSet.folderName);

    await setBool(pref, "hardWrap", hardWrap, defaultSet.hardWrap);

    notifyListeners();
  }

  Map<String, String> toLoggableMap() {
    return <String, String>{
      "gitAuthor": gitAuthor.isNotEmpty.toString(),
      "gitAuthorEmail": gitAuthorEmail.isNotEmpty.toString(),
      'sshPublicKey': sshPublicKey.isNotEmpty.toString(),
      'sshPrivateKey': sshPrivateKey.isNotEmpty.toString(),
      "noteFileNameFormat": noteFileNameFormat.toInternalString(),
      "journalNoteFileNameFormat": journalNoteFileNameFormat.toInternalString(),
      "yamlModifiedKey": yamlModifiedKey,
      "yamlCreatedKey": yamlCreatedKey,
      "yamlTagsKey": yamlTagsKey,
      "customMetaData": customMetaData,
      "yamlHeaderEnabled": yamlHeaderEnabled.toString(),
      "defaultNewNoteFolderSpec":
          defaultNewNoteFolderSpec.isNotEmpty.toString(),
      "journalEditordefaultNewNoteFolderSpec":
          journalEditordefaultNewNoteFolderSpec,
      'journalEditorSingleNote': journalEditorSingleNote.toString(),
      "defaultEditor": defaultEditor.toInternalString(),
      "defaultView": defaultView.toInternalString(),
      "sortingField": sortingField.toInternalString(),
      "sortingOrder": sortingOrder.toInternalString(),
      "remoteSyncFrequency": remoteSyncFrequency.toInternalString(),
      "showNoteSummary": showNoteSummary.toString(),
      "folderViewHeaderType": folderViewHeaderType,
      "version": version.toString(),
      'markdownDefaultView': markdownDefaultView.toInternalString(),
      'markdownLastUsedView': markdownLastUsedView.toInternalString(),
      'homeScreen': homeScreen.toInternalString(),
      'theme': theme.toInternalString(),
      'imageLocationSpec': imageLocationSpec,
      'zenMode': zenMode.toString(),
      'titleSettings': titleSettings.toInternalString(),
      'swipeToDelete': swipeToDelete.toString(),
      'inlineTagPrefixes': inlineTagPrefixes.join(' '),
      'emojiParser': emojiParser.toString(),
      'folderName': folderName.toString(),
      'bottomMenuBar': bottomMenuBar.toString(),
      'confirmDelete': confirmDelete.toString(),
      'storeInternally': storeInternally.toString(),
      'storageLocation': storageLocation,
    };
  }

  Future<String> buildRepoPath(String internalDir) async {
    if (storeInternally) {
      return p.join(internalDir, folderName);
    }
    if (Platform.isIOS) {
      //
      // iOS is strange as fuck and it seems if you don't call this function
      // asking for the path, you won't be able to access the path
      // So even though we have it stored in the settings, this method
      // must be called
      //
      var basePath = await ICloudDocumentsPath.documentsPath;
      if (basePath == null) {
        // Go back to the normal path
        return p.join(storageLocation, folderName);
      }
      assert(basePath == storageLocation);
      return p.join(basePath, folderName);
    }

    return p.join(storageLocation, folderName);
  }
}

class NoteFileNameFormat {
  static const Iso8601WithTimeZone = NoteFileNameFormat(
      "Iso8601WithTimeZone", 'settings.NoteFileNameFormat.iso8601WithTimeZone');
  static const Iso8601 =
      NoteFileNameFormat("Iso8601", 'settings.NoteFileNameFormat.iso8601');
  static const Iso8601WithTimeZoneWithoutColon = NoteFileNameFormat(
      "Iso8601WithTimeZoneWithoutColon",
      'settings.NoteFileNameFormat.iso8601WithoutColon');
  static const FromTitle =
      NoteFileNameFormat("FromTitle", 'settings.NoteFileNameFormat.title');
  static const SimpleDate =
      NoteFileNameFormat("SimpleDate", 'settings.NoteFileNameFormat.simple');
  static const UuidV4 =
      NoteFileNameFormat("uuidv4", 'settings.NoteFileNameFormat.uuid');
  static const Zettelkasten = NoteFileNameFormat(
      "Zettelkasten", 'settings.NoteFileNameFormat.zettelkasten');
  static const DateOnly =
      NoteFileNameFormat("DateOnly", 'settings.NoteFileNameFormat.dateOnly');

  static const Default = FromTitle;

  static const options = <NoteFileNameFormat>[
    SimpleDate,
    FromTitle,
    Iso8601,
    Iso8601WithTimeZone,
    Iso8601WithTimeZoneWithoutColon,
    UuidV4,
    Zettelkasten,
    DateOnly,
  ];

  static NoteFileNameFormat fromInternalString(String? str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static NoteFileNameFormat fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }

  final String _str;
  final String _publicStr;

  const NoteFileNameFormat(this._str, this._publicStr);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicStr);
  }

  @override
  String toString() {
    assert(false, "NoteFileNameFormat toString should never be called");
    return "";
  }
}

class RemoteSyncFrequency {
  static const Automatic =
      RemoteSyncFrequency("settings.remoteSync.auto", "automatic");
  static const Manual =
      RemoteSyncFrequency("settings.remoteSync.manual", "manual");
  static const Default = Automatic;

  final String _str;
  final String _publicString;
  const RemoteSyncFrequency(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicString);
  }

  static const options = <RemoteSyncFrequency>[
    Automatic,
    Manual,
  ];

  static RemoteSyncFrequency fromInternalString(String? str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static RemoteSyncFrequency fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }

  @override
  String toString() {
    assert(false, "RemoteSyncFrequency toString should never be called");
    return "";
  }
}

class SettingsEditorType {
  static const Markdown =
      SettingsEditorType('settings.editors.markdownEditor', "Markdown");
  static const Raw = SettingsEditorType('settings.editors.rawEditor', "Raw");
  static const Journal =
      SettingsEditorType('settings.editors.journalEditor', "Journal");
  static const Checklist =
      SettingsEditorType('settings.editors.checklistEditor', "Checklist");
  static const Org = SettingsEditorType('settings.editors.orgEditor', "Org");
  static const Default = Markdown;

  final String _str;
  final String _publicString;
  const SettingsEditorType(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicString);
  }

  EditorType toEditorType() {
    switch (this) {
      case Markdown:
        return EditorType.Markdown;
      case Raw:
        return EditorType.Raw;
      case Journal:
        return EditorType.Journal;
      case Checklist:
        return EditorType.Checklist;
      default:
        return EditorType.Markdown;
    }
  }

  static SettingsEditorType fromEditorType(EditorType editorType) {
    switch (editorType) {
      case EditorType.Checklist:
        return SettingsEditorType.Checklist;
      case EditorType.Raw:
        return SettingsEditorType.Raw;
      case EditorType.Markdown:
        return SettingsEditorType.Markdown;
      case EditorType.Journal:
        return SettingsEditorType.Journal;
      case EditorType.Org:
        return SettingsEditorType.Org;
    }
  }

  static const options = <SettingsEditorType>[
    Markdown,
    Raw,
    Journal,
    Checklist,
  ];

  static SettingsEditorType fromInternalString(String? str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static SettingsEditorType fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }

  @override
  String toString() {
    assert(false, "EditorType toString should never be called");
    return "";
  }
}

class SettingsFolderViewType {
  static const Standard =
      SettingsFolderViewType('widgets.FolderView.views.standard', "Standard");
  static const Journal =
      SettingsFolderViewType('widgets.FolderView.views.journal', "Journal");
  static const Card =
      SettingsFolderViewType('widgets.FolderView.views.card', "Card");
  static const Grid =
      SettingsFolderViewType('widgets.FolderView.views.grid', "Grid");
  static const Default = Standard;

  final String _str;
  final String _publicString;
  const SettingsFolderViewType(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicString);
  }

  static const options = <SettingsFolderViewType>[
    Standard,
    Journal,
    Card,
    Grid,
  ];

  static SettingsFolderViewType fromInternalString(String? str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static SettingsFolderViewType fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }

  @override
  String toString() {
    assert(false, "FolderViewType toString should never be called");
    return "";
  }

  FolderViewType toFolderViewType() {
    switch (this) {
      case Standard:
        return FolderViewType.Standard;
      case Journal:
        return FolderViewType.Journal;
      case Card:
        return FolderViewType.Card;
      case Grid:
        return FolderViewType.Grid;
    }

    return FolderViewType.Standard;
  }

  static SettingsFolderViewType fromFolderViewType(FolderViewType viewType) {
    switch (viewType) {
      case FolderViewType.Standard:
        return SettingsFolderViewType.Standard;
      case FolderViewType.Journal:
        return SettingsFolderViewType.Journal;
      case FolderViewType.Card:
        return SettingsFolderViewType.Card;
      case FolderViewType.Grid:
        return SettingsFolderViewType.Grid;
    }
  }
}

class SettingsMarkdownDefaultView {
  static const Edit =
      SettingsMarkdownDefaultView('settings.EditorDefaultView.edit', "Edit");
  static const View =
      SettingsMarkdownDefaultView('settings.EditorDefaultView.view', "View");
  static const LastUsed = SettingsMarkdownDefaultView(
      'settings.EditorDefaultView.lastUsed', "Last Used");
  static const Default = LastUsed;

  final String _str;
  final String _publicStr;
  const SettingsMarkdownDefaultView(this._publicStr, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicStr);
  }

  static const options = <SettingsMarkdownDefaultView>[
    Edit,
    View,
    LastUsed,
  ];

  static SettingsMarkdownDefaultView fromInternalString(String? str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static SettingsMarkdownDefaultView fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }

  @override
  String toString() {
    assert(
        false, "SettingsMarkdownDefaultView toString should never be called");
    return "";
  }
}

class SettingsHomeScreen {
  static const AllNotes =
      SettingsHomeScreen("settings.HomeScreen.allNotes", "all_notes");
  static const AllFolders =
      SettingsHomeScreen("settings.HomeScreen.allFolders", "all_folders");
  static const Default = AllNotes;

  final String _str;
  final String _publicString;
  const SettingsHomeScreen(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicString);
  }

  static const options = <SettingsHomeScreen>[
    AllNotes,
    AllFolders,
  ];

  static SettingsHomeScreen fromInternalString(String? str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static SettingsHomeScreen fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }

  @override
  String toString() {
    assert(false, "SettingsHomeScreen toString should never be called");
    return "";
  }
}

String generateRandomId() {
  return const Uuid().v4().substring(0, 8);
}

class SettingsTheme {
  static const Dark = SettingsTheme("settings.theme.dark", "dark");
  static const Light = SettingsTheme("settings.theme.light", "light");
  static const SystemDefault =
      SettingsTheme("settings.theme.default", "default");
  static const Default = SystemDefault;

  final String _str;
  final String _publicString;
  const SettingsTheme(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicString);
  }

  static const options = <SettingsTheme>[
    Light,
    Dark,
    SystemDefault,
  ];

  static SettingsTheme fromInternalString(String? str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static SettingsTheme fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }

  @override
  String toString() {
    assert(false, "SettingsTheme toString should never be called");
    return "";
  }

  ThemeMode toThemeMode() {
    if (this == SystemDefault) {
      return ThemeMode.system;
    }
    if (this == Light) {
      return ThemeMode.light;
    }
    return ThemeMode.dark;
  }
}

class SettingsTitle {
  static const InYaml =
      SettingsTitle("settings.noteMetaData.titleMetaData.fromYaml", "yaml");
  static const InH1 =
      SettingsTitle("settings.noteMetaData.titleMetaData.fromH1", "h1");
  static const InFileName =
      SettingsTitle("settings.noteMetaData.titleMetaData.filename", "filename");

  static const Default = InH1;

  final String _str;
  final String _publicString;
  const SettingsTitle(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicString);
  }

  static const options = <SettingsTitle>[
    InH1,
    InYaml,
    // InFileName,
  ];

  static SettingsTitle fromInternalString(String? str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static SettingsTitle fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }

  @override
  String toString() {
    assert(false, "SettingsTitle toString should never be called");
    return "";
  }
}

Set<String> parseTags(String tags) {
  return tags
      .toLowerCase()
      .split(",")
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toSet();
}
