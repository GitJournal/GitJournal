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

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:icloud_documents_path/icloud_documents_path.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:gitjournal/core/sorting_mode.dart';
import 'package:gitjournal/editors/common_types.dart';
import 'package:gitjournal/folder_views/common_types.dart';

const DEFAULT_ID = "0";
const FOLDER_NAME_KEY = "remoteGitRepoPath";
const SETTINGS_VERSION = 3;

class Settings extends ChangeNotifier {
  Settings(this.id);

  final String id;

  String folderName = "journal";

  // Properties
  String gitAuthor = "GitJournal";
  String gitAuthorEmail = "app@gitjournal.io";
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

  // Display - Image
  bool rotateImageGestures = false;
  double maxImageZoom = 10;

  // Display - Image - Theming
  bool themeRasterGraphics = false;
  SettingsImageTextType themeOverrideTagLocation =
      SettingsImageTextType.Default;
  Set<String> doNotThemeTags = {"notheme", "!nt"};
  Set<String> doThemeTags = {"dotheme", "!dt"};
  SettingsThemeVectorGraphics themeVectorGraphics =
      SettingsThemeVectorGraphics.Default;
  bool themeSvgWithBackground = false;
  bool matchCanvasColor = true;
  SettingsVectorGraphicsAdjustColors vectorGraphicsAdjustColors =
      SettingsVectorGraphicsAdjustColors.Default;

  // Display - Image - Caption
  bool overlayCaption = true;
  bool transparentCaption = true;
  bool blurBehindCaption = true;
  bool tooltipFirst = false;
  SettingsImageTextType useAsCaption = SettingsImageTextType.Default;
  Set<String> doNotCaptionTags = {"nocaption", "!nc"};
  Set<String> doCaptionTags = {"docaption", "!dc"};

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

  bool storeInternally = true;
  String storageLocation = "";

  String sshPublicKey = "";
  String sshPrivateKey = "";
  String sshPassword = "";

  void load(SharedPreferences pref) {
    gitAuthor = _getString(pref, "gitAuthor") ?? gitAuthor;
    gitAuthorEmail = _getString(pref, "gitAuthorEmail") ?? gitAuthorEmail;

    noteFileNameFormat = NoteFileNameFormat.fromInternalString(
        _getString(pref, "noteFileNameFormat"));
    journalNoteFileNameFormat = NoteFileNameFormat.fromInternalString(
        _getString(pref, "journalNoteFileNameFormat"));

    yamlModifiedKey = _getString(pref, "yamlModifiedKey") ?? yamlModifiedKey;
    yamlCreatedKey = _getString(pref, "yamlCreatedKey") ?? yamlCreatedKey;
    yamlTagsKey = _getString(pref, "yamlTagsKey") ?? yamlTagsKey;
    customMetaData = _getString(pref, "customMetaData") ?? customMetaData;

    yamlHeaderEnabled =
        _getBool(pref, "yamlHeaderEnabled") ?? yamlHeaderEnabled;
    defaultNewNoteFolderSpec = _getString(pref, "defaultNewNoteFolderSpec") ??
        defaultNewNoteFolderSpec;
    journalEditordefaultNewNoteFolderSpec =
        _getString(pref, "journalEditordefaultNewNoteFolderSpec") ??
            journalEditordefaultNewNoteFolderSpec;
    journalEditorSingleNote =
        _getBool(pref, "journalEditorSingleNote") ?? journalEditorSingleNote;

    remoteSyncFrequency = RemoteSyncFrequency.fromInternalString(
        _getString(pref, "remoteSyncFrequency"));

    sortingField =
        SortingField.fromInternalString(_getString(pref, "sortingField"));
    sortingOrder =
        SortingOrder.fromInternalString(_getString(pref, "sortingOrder"));
    defaultEditor = SettingsEditorType.fromInternalString(
        _getString(pref, "defaultEditor"));
    defaultView = SettingsFolderViewType.fromInternalString(
        _getString(pref, "defaultView"));

    markdownDefaultView = SettingsMarkdownDefaultView.fromInternalString(
        _getString(pref, "markdownDefaultView"));
    markdownLastUsedView = SettingsMarkdownDefaultView.fromInternalString(
        _getString(pref, "markdownLastUsedView"));
    if (markdownLastUsedView == SettingsMarkdownDefaultView.LastUsed) {
      markdownLastUsedView = SettingsMarkdownDefaultView.Edit;
    }

    showNoteSummary = _getBool(pref, "showNoteSummary") ?? showNoteSummary;
    folderViewHeaderType =
        _getString(pref, "folderViewHeaderType") ?? folderViewHeaderType;

    version = _getInt(pref, "settingsVersion") ?? version;
    emojiParser = _getBool(pref, "emojiParser") ?? emojiParser;

    homeScreen =
        SettingsHomeScreen.fromInternalString(_getString(pref, "homeScreen"));
    theme = SettingsTheme.fromInternalString(_getString(pref, "theme"));

    // Display - Image
    rotateImageGestures =
        _getBool(pref, "rotateImageGestures") ?? rotateImageGestures;
    maxImageZoom = _getDouble(pref, "maxImageZoom") ?? maxImageZoom;

    // Display - Image - Theming
    themeRasterGraphics =
        _getBool(pref, "themeRasterGraphics") ?? themeRasterGraphics;
    themeOverrideTagLocation = SettingsImageTextType.fromInternalString(
        _getString(pref, "themeOverrideTagLocation"));
    doNotThemeTags = _getStringSet(pref, "doNotThemeTags") ?? doNotThemeTags;
    doThemeTags = _getStringSet(pref, "doThemeTags") ?? doThemeTags;
    themeVectorGraphics = SettingsThemeVectorGraphics.fromInternalString(
        _getString(pref, "themeVectorGraphics"));
    themeSvgWithBackground =
        _getBool(pref, "themeSvgWithBackground") ?? themeSvgWithBackground;
    matchCanvasColor = _getBool(pref, "matchCanvasColor") ?? matchCanvasColor;
    vectorGraphicsAdjustColors =
        SettingsVectorGraphicsAdjustColors.fromInternalString(
            _getString(pref, "vectorGraphicsAdjustColors"));

    // Display - Image - Caption
    overlayCaption = _getBool(pref, "overlayCaption") ?? overlayCaption;
    transparentCaption =
        _getBool(pref, "transparentCaption") ?? transparentCaption;
    blurBehindCaption =
        _getBool(pref, "blurBehindCaption") ?? blurBehindCaption;
    tooltipFirst = _getBool(pref, "tooltipFirst") ?? tooltipFirst;
    useAsCaption = SettingsImageTextType.fromInternalString(
        _getString(pref, "useAsCaption"));
    doNotCaptionTags =
        _getStringSet(pref, "doNotCaptionTag") ?? doNotCaptionTags;
    doCaptionTags = _getStringSet(pref, "doCaptionTag") ?? doCaptionTags;

    imageLocationSpec =
        _getString(pref, "imageLocationSpec") ?? imageLocationSpec;

    zenMode = _getBool(pref, "zenMode") ?? zenMode;
    titleSettings =
        SettingsTitle.fromInternalString(_getString(pref, "titleSettings"));
    swipeToDelete = _getBool(pref, "swipeToDelete") ?? swipeToDelete;

    inlineTagPrefixes =
        _getStringList(pref, "inlineTagPrefixes")?.toSet() ?? inlineTagPrefixes;

    // From AppState
    folderName = _getString(pref, FOLDER_NAME_KEY) ?? folderName;

    sshPublicKey = _getString(pref, "sshPublicKey") ?? sshPublicKey;
    sshPrivateKey = _getString(pref, "sshPrivateKey") ?? sshPrivateKey;
    sshPassword = _getString(pref, "sshPassword") ?? sshPassword;

    bottomMenuBar = _getBool(pref, "bottomMenuBar") ?? bottomMenuBar;
    confirmDelete = _getBool(pref, "confirmDelete") ?? confirmDelete;
    storeInternally = _getBool(pref, "storeInternally") ?? storeInternally;
    storageLocation = _getString(pref, "storageLocation") ?? "";
  }

  String? _getString(SharedPreferences pref, String key) {
    return pref.getString(id + '_' + key);
  }

  bool? _getBool(SharedPreferences pref, String key) {
    return pref.getBool(id + '_' + key);
  }

  List<String>? _getStringList(SharedPreferences pref, String key) {
    return pref.getStringList(id + '_' + key);
  }

  Set<String>? _getStringSet(SharedPreferences pref, String key) {
    return _getStringList(pref, key)?.toSet();
  }

  int? _getInt(SharedPreferences pref, String key) {
    return pref.getInt(id + '_' + key);
  }

  double? _getDouble(SharedPreferences pref, String key) {
    return pref.getDouble(id + '_' + key);
  }

  Future<void> save() async {
    var pref = await SharedPreferences.getInstance();
    var defaultSet = Settings(id);

    await _setString(pref, "gitAuthor", gitAuthor, defaultSet.gitAuthor);
    await _setString(
        pref, "gitAuthorEmail", gitAuthorEmail, defaultSet.gitAuthorEmail);
    await _setString(
        pref,
        "noteFileNameFormat",
        noteFileNameFormat.toInternalString(),
        defaultSet.noteFileNameFormat.toInternalString());
    await _setString(
        pref,
        "journalNoteFileNameFormat",
        journalNoteFileNameFormat.toInternalString(),
        defaultSet.journalNoteFileNameFormat.toInternalString());
    await _setString(
        pref, "yamlModifiedKey", yamlModifiedKey, defaultSet.yamlModifiedKey);
    await _setString(
        pref, "yamlCreatedKey", yamlCreatedKey, defaultSet.yamlCreatedKey);
    await _setString(pref, "yamlTagsKey", yamlTagsKey, defaultSet.yamlTagsKey);
    await _setString(
        pref, "customMetaData", customMetaData, defaultSet.customMetaData);
    await _setBool(pref, "yamlHeaderEnabled", yamlHeaderEnabled,
        defaultSet.yamlHeaderEnabled);
    await _setString(pref, "defaultNewNoteFolderSpec", defaultNewNoteFolderSpec,
        defaultSet.defaultNewNoteFolderSpec);
    await _setString(
        pref,
        "journalEditordefaultNewNoteFolderSpec",
        journalEditordefaultNewNoteFolderSpec,
        defaultSet.journalEditordefaultNewNoteFolderSpec);
    await _setBool(pref, "journalEditorSingleNote", journalEditorSingleNote,
        defaultSet.journalEditorSingleNote);
    await _setString(
        pref,
        "remoteSyncFrequency",
        remoteSyncFrequency.toInternalString(),
        defaultSet.remoteSyncFrequency.toInternalString());
    await _setString(pref, "sortingField", sortingField.toInternalString(),
        defaultSet.sortingField.toInternalString());
    await _setString(pref, "sortingOrder", sortingOrder.toInternalString(),
        defaultSet.sortingOrder.toInternalString());
    await _setString(pref, "defaultEditor", defaultEditor.toInternalString(),
        defaultSet.defaultEditor.toInternalString());
    await _setString(pref, "defaultView", defaultView.toInternalString(),
        defaultSet.defaultView.toInternalString());
    await _setString(
        pref,
        "markdownDefaultView",
        markdownDefaultView.toInternalString(),
        defaultSet.markdownDefaultView.toInternalString());
    await _setString(
        pref,
        "markdownLastUsedView",
        markdownLastUsedView.toInternalString(),
        defaultSet.markdownLastUsedView.toInternalString());
    await _setBool(
        pref, "showNoteSummary", showNoteSummary, defaultSet.showNoteSummary);
    await _setString(pref, "folderViewHeaderType", folderViewHeaderType,
        defaultSet.folderViewHeaderType);
    await _setBool(pref, "emojiParser", emojiParser, defaultSet.emojiParser);
    await _setString(pref, "homeScreen", homeScreen.toInternalString(),
        defaultSet.homeScreen.toInternalString());
    await _setString(pref, "theme", theme.toInternalString(),
        defaultSet.theme.toInternalString());

    // Display - Image
    await _setBool(pref, "rotateImageGestures", rotateImageGestures,
        defaultSet.rotateImageGestures);
    await _setDouble(
        pref, "maxImageZoom", maxImageZoom, defaultSet.maxImageZoom);

    // Display - Image - Theme
    await _setBool(pref, "themeRasterGraphics", themeRasterGraphics,
        defaultSet.themeRasterGraphics);
    await _setString(
        pref,
        "themeOverrideTagLocation",
        themeOverrideTagLocation.toInternalString(),
        defaultSet.themeOverrideTagLocation.toInternalString());
    await _setStringSet(
        pref, "doNotThemeTags", doNotThemeTags, defaultSet.doNotThemeTags);
    await _setStringSet(
        pref, "doThemeTags", doThemeTags, defaultSet.doThemeTags);
    await _setString(
        pref,
        "themeVectorGraphics",
        themeVectorGraphics.toInternalString(),
        defaultSet.themeVectorGraphics.toInternalString());
    await _setBool(pref, "themeSvgWithBackground", themeSvgWithBackground,
        defaultSet.themeSvgWithBackground);
    await _setBool(pref, "matchCanvasColor", matchCanvasColor,
        defaultSet.matchCanvasColor);
    await _setString(
        pref,
        "vectorGraphicsAdjustColors",
        vectorGraphicsAdjustColors.toInternalString(),
        defaultSet.vectorGraphicsAdjustColors.toInternalString());

    // Display - Image - Caption
    await _setBool(
        pref, "overlayCaption", overlayCaption, defaultSet.overlayCaption);
    await _setBool(pref, "transparentCaption", transparentCaption,
        defaultSet.transparentCaption);
    await _setBool(pref, "blurBehindCaption", blurBehindCaption,
        defaultSet.blurBehindCaption);
    await _setBool(pref, "tooltipFirst", tooltipFirst, defaultSet.tooltipFirst);
    await _setString(pref, "useAsCaption", useAsCaption.toInternalString(),
        defaultSet.useAsCaption.toInternalString());
    await _setStringSet(
        pref, "doNotCaptionTag", doNotCaptionTags, defaultSet.doNotCaptionTags);
    await _setStringSet(
        pref, "doCaptionTag", doCaptionTags, defaultSet.doCaptionTags);

    await _setString(pref, "imageLocationSpec", imageLocationSpec,
        defaultSet.imageLocationSpec);
    await _setBool(pref, "zenMode", zenMode, defaultSet.zenMode);
    await _setString(pref, "titleSettings", titleSettings.toInternalString(),
        defaultSet.titleSettings.toInternalString());
    await _setBool(
        pref, "swipeToDelete", swipeToDelete, defaultSet.swipeToDelete);
    await _setStringSet(pref, "inlineTagPrefixes", inlineTagPrefixes,
        defaultSet.inlineTagPrefixes);
    await _setBool(
        pref, "bottomMenuBar", bottomMenuBar, defaultSet.bottomMenuBar);
    await _setBool(
        pref, "confirmDelete", confirmDelete, defaultSet.confirmDelete);
    await _setBool(
        pref, "storeInternally", storeInternally, defaultSet.storeInternally);
    await _setString(
        pref, "storageLocation", storageLocation, defaultSet.storageLocation);

    await _setString(
        pref, "sshPublicKey", sshPublicKey, defaultSet.sshPublicKey);
    await _setString(
        pref, "sshPrivateKey", sshPrivateKey, defaultSet.sshPrivateKey);
    await _setString(pref, "sshPassword", sshPassword, defaultSet.sshPassword);

    await _setInt(pref, "settingsVersion", version, defaultSet.version);

    await _setString(pref, FOLDER_NAME_KEY, folderName, defaultSet.folderName);

    notifyListeners();
  }

  Future<void> _setString(
    SharedPreferences pref,
    String key,
    String value,
    String? defaultValue,
  ) async {
    key = id + '_' + key;
    if (value == defaultValue) {
      await pref.remove(key);
    } else {
      await pref.setString(key, value);
    }
  }

  Future<void> _setBool(
    SharedPreferences pref,
    String key,
    bool value,
    bool defaultValue,
  ) async {
    key = id + '_' + key;
    if (value == defaultValue) {
      await pref.remove(key);
    } else {
      await pref.setBool(key, value);
    }
  }

  Future<void> _setInt(
    SharedPreferences pref,
    String key,
    int value,
    int defaultValue,
  ) async {
    key = id + '_' + key;
    if (value == defaultValue) {
      await pref.remove(key);
    } else {
      await pref.setInt(key, value);
    }
  }

  Future<void> _setDouble(
    SharedPreferences pref,
    String key,
    double value,
    double defaultValue,
  ) async {
    key = id + '_' + key;
    if (value == defaultValue) {
      await pref.remove(key);
    } else {
      await pref.setDouble(key, value);
    }
  }

  Future<void> _setStringSet(
    SharedPreferences pref,
    String key,
    Set<String> value,
    Set<String> defaultValue,
  ) async {
    key = id + '_' + key;

    final bool Function(Set<dynamic>, Set<dynamic>) eq =
        const SetEquality().equals;

    if (eq(value, defaultValue)) {
      await pref.remove(key);
    } else {
      await pref.setStringList(key, value.toList());
    }
  }

  Map<String, String?> toMap() {
    return <String, String?>{
      "gitAuthor": gitAuthor,
      "gitAuthorEmail": gitAuthorEmail,
      "noteFileNameFormat": noteFileNameFormat.toInternalString(),
      "journalNoteFileNameFormat": journalNoteFileNameFormat.toInternalString(),
      "yamlModifiedKey": yamlModifiedKey,
      "yamlCreatedKey": yamlCreatedKey,
      "yamlTagsKey": yamlTagsKey,
      "customMetaData": customMetaData,
      "yamlHeaderEnabled": yamlHeaderEnabled.toString(),
      "defaultNewNoteFolderSpec": defaultNewNoteFolderSpec,
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
      // Display - Image
      'rotateImageGestures': rotateImageGestures.toString(),
      'maxImageZoom': maxImageZoom.toString(),
      // Display - Image - Theming
      'themeRasterGraphics': themeRasterGraphics.toString(),
      'themeOverrideTagLocation': themeOverrideTagLocation.toInternalString(),
      'doNotThemeTags': csvTags(doNotThemeTags),
      'doThemeTags': csvTags(doThemeTags),
      'themeVectorGraphics': themeVectorGraphics.toInternalString(),
      'themeSvgWithBackground': themeSvgWithBackground.toString(),
      'matchCanvasColor': matchCanvasColor.toString(),
      'vectorGraphicsAdjustColors':
          vectorGraphicsAdjustColors.toInternalString(),
      // Display - Image - Caption
      'overlayCaption': overlayCaption.toString(),
      'transparentCaption': transparentCaption.toString(),
      'blurBehindCaption': blurBehindCaption.toString(),
      'tooltipFirst': tooltipFirst.toString(),
      'useAsCaption': useAsCaption.toInternalString(),
      'doNotCaptionTag': csvTags(doNotCaptionTags),
      'doCaptionTag': csvTags(doCaptionTags),
      //
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
      'sshPublicKey': sshPublicKey.isNotEmpty.toString(),
      'sshPrivateKey': sshPrivateKey.isNotEmpty.toString(),
    };
  }

  Map<String, String?> toLoggableMap() {
    var m = toMap();
    m.remove("gitAuthor");
    m.remove("gitAuthorEmail");
    m.remove("defaultNewNoteFolderSpec");
    return m;
  }

  Future<String?> buildRepoPath(String internalDir) async {
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
        return null;
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

class SettingsImageTextType {
  static const AltTool = SettingsImageTextType(
      "settings.display.images.imageTextType.altAndTooltip", "alt_and_tooltip");
  static const Tooltip = SettingsImageTextType(
      "settings.display.images.imageTextType.tooltip", "tooltip");
  static const Alt =
      SettingsImageTextType("settings.display.images.imageTextType.alt", "alt");
  static const None = SettingsImageTextType(
      "settings.display.images.imageTextType.none", "none");
  static const Default = AltTool;

  final String _str;
  final String _publicString;
  const SettingsImageTextType(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicString);
  }

  static const options = <SettingsImageTextType>[
    AltTool,
    Tooltip,
    Alt,
    None,
  ];

  static SettingsImageTextType fromInternalString(String? str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static SettingsImageTextType fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }

  @override
  String toString() {
    assert(false,
        "SettingsThemeOverrideTagLocation toString should never be called");
    return "";
  }
}

class SettingsThemeVectorGraphics {
  static const On = SettingsThemeVectorGraphics(
      "settings.display.images.theming.themeVectorGraphics.on", "on");
  static const Off = SettingsThemeVectorGraphics(
      "settings.display.images.theming.themeVectorGraphics.off", "off");
  static const Filter = SettingsThemeVectorGraphics(
      "settings.display.images.theming.themeVectorGraphics.filter", "filter");
  static const Default = On;

  final String _str;
  final String _publicString;
  const SettingsThemeVectorGraphics(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicString);
  }

  static const options = <SettingsThemeVectorGraphics>[
    On,
    Off,
    Filter,
  ];

  static SettingsThemeVectorGraphics fromInternalString(String? str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static SettingsThemeVectorGraphics fromPublicString(String str) {
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
        false, "SettingsThemeVectorGraphics toString should never be called");
    return "";
  }
}

class SettingsVectorGraphicsAdjustColors {
  static const All = SettingsVectorGraphicsAdjustColors(
      "settings.display.images.theming.adjustColors.all", "all");
  static const BnW = SettingsVectorGraphicsAdjustColors(
      "settings.display.images.theming.adjustColors.blackAndWhite",
      "black_and_white");
  static const Grays = SettingsVectorGraphicsAdjustColors(
      "settings.display.images.theming.adjustColors.grays", "grays");
  static const Default = All;

  final String _str;
  final String _publicString;
  const SettingsVectorGraphicsAdjustColors(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicString);
  }

  static const options = <SettingsVectorGraphicsAdjustColors>[
    BnW,
    Grays,
    All,
  ];

  static SettingsVectorGraphicsAdjustColors fromInternalString(String? str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static SettingsVectorGraphicsAdjustColors fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }

  @override
  String toString() {
    assert(false,
        "SettingsVectorGraphicsAdjustColors toString should never be called");
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

String csvTags(Set<String> tags) {
  return tags.join(", ");
}
