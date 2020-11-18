import 'dart:io';

import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:icloud_documents_path/icloud_documents_path.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:gitjournal/core/sorting_mode.dart';
import 'package:gitjournal/folder_views/common.dart';
import 'package:gitjournal/screens/note_editor.dart';

const DEFAULT_ID = "0";

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
  int version = 2;

  SettingsHomeScreen homeScreen = SettingsHomeScreen.Default;

  SettingsMarkdownDefaultView markdownDefaultView =
      SettingsMarkdownDefaultView.Default;
  SettingsMarkdownDefaultView markdownLastUsedView =
      SettingsMarkdownDefaultView.Edit;

  String imageLocationSpec = "."; // . means the same folder

  bool zenMode = false;
  bool saveTitleInH1 = true;

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

    imageLocationSpec =
        _getString(pref, "imageLocationSpec") ?? imageLocationSpec;

    zenMode = _getBool(pref, "zenMode") ?? zenMode;
    saveTitleInH1 = _getBool(pref, "saveTitleInH1") ?? saveTitleInH1;
    swipeToDelete = _getBool(pref, "swipeToDelete") ?? swipeToDelete;

    inlineTagPrefixes =
        _getStringList(pref, "inlineTagPrefixes")?.toSet() ?? inlineTagPrefixes;

    // From AppState
    folderName = _getString(pref, "remoteGitRepoPath") ?? folderName;

    sshPublicKey = _getString(pref, "sshPublicKey") ?? sshPublicKey;
    sshPrivateKey = _getString(pref, "sshPrivateKey") ?? sshPrivateKey;
    sshPassword = _getString(pref, "sshPassword") ?? sshPassword;

    bottomMenuBar = _getBool(pref, "bottomMenuBar") ?? bottomMenuBar;
    confirmDelete = _getBool(pref, "confirmDelete") ?? confirmDelete;
    storeInternally = _getBool(pref, "storeInternally") ?? storeInternally;
    storageLocation = _getString(pref, "storageLocation") ?? "";
  }

  String _getString(SharedPreferences pref, String key) {
    return pref.getString(id + '_' + key);
  }

  bool _getBool(SharedPreferences pref, String key) {
    return pref.getBool(id + '_' + key);
  }

  List<String> _getStringList(SharedPreferences pref, String key) {
    return pref.getStringList(id + '_' + key);
  }

  int _getInt(SharedPreferences pref, String key) {
    return pref.getInt(id + '_' + key);
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
    await _setString(pref, "imageLocationSpec", imageLocationSpec,
        defaultSet.imageLocationSpec);
    await _setBool(pref, "zenMode", zenMode, defaultSet.zenMode);
    await _setBool(
        pref, "saveTitleInH1", saveTitleInH1, defaultSet.saveTitleInH1);
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

    await _setString(
        pref, "remoteGitRepoPath", folderName, defaultSet.folderName);

    notifyListeners();
  }

  Future<void> _setString(
    SharedPreferences pref,
    String key,
    String value,
    String defaultValue,
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

  Future<void> _setStringSet(
    SharedPreferences pref,
    String key,
    Set<String> value,
    Set<String> defaultValue,
  ) async {
    key = id + '_' + key;

    final eq = const SetEquality().equals;

    if (eq(value, defaultValue)) {
      await pref.remove(key);
    } else {
      await pref.setStringList(key, value.toList());
    }
  }

  Map<String, String> toMap() {
    return <String, String>{
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
      'imageLocationSpec': imageLocationSpec,
      'zenMode': zenMode.toString(),
      'saveTitleInH1': saveTitleInH1.toString(),
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

  Map<String, String> toLoggableMap() {
    var m = toMap();
    m.remove("gitAuthor");
    m.remove("gitAuthorEmail");
    m.remove("defaultNewNoteFolderSpec");
    return m;
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
      NoteFileNameFormat("SimpleDate", 'settings.NoteFileNameFormat.simmple');
  static const UuidV4 =
      NoteFileNameFormat("uuidv4", 'settings.NoteFileNameFormat.uuid');
  static const Zettelkasten = NoteFileNameFormat(
      "Zettelkasten", 'settings.NoteFileNameFormat.zettelkasten');

  static const Default = FromTitle;

  static const options = <NoteFileNameFormat>[
    SimpleDate,
    FromTitle,
    Iso8601,
    Iso8601WithTimeZone,
    Iso8601WithTimeZoneWithoutColon,
    UuidV4,
    Zettelkasten,
  ];

  static NoteFileNameFormat fromInternalString(String str) {
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

  static RemoteSyncFrequency fromInternalString(String str) {
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
    }
    return SettingsEditorType.Default;
  }

  static const options = <SettingsEditorType>[
    Markdown,
    Raw,
    Journal,
    Checklist,
  ];

  static SettingsEditorType fromInternalString(String str) {
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

  static SettingsFolderViewType fromInternalString(String str) {
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
    return SettingsFolderViewType.Default;
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

  static SettingsMarkdownDefaultView fromInternalString(String str) {
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

  static SettingsHomeScreen fromInternalString(String str) {
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
  return Uuid().v4().substring(0, 8);
}
