/*
 * SPDX-FileCopyrightText: 2020-2021 Roland Fredenhagen <important@van-fredenhagen.de>
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:gitjournal/core/transformers/base.dart';
import 'package:gitjournal/editors/common_types.dart';
import 'package:gitjournal/folder_views/common_types.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'settings_sharedpref.dart';

const DEFAULT_ID = "0";
const SETTINGS_VERSION = 3;

class Settings extends ChangeNotifier with SettingsSharedPref {
  Settings(this.id, this.pref);

  @override
  final String id;

  @override
  final SharedPreferences pref;

  String customMetaData = "";

  String defaultNewNoteFolderSpec = "";
  String journalEditordefaultNewNoteFolderSpec = "";
  bool journalEditorSingleNote = false;

  RemoteSyncFrequency remoteSyncFrequency = RemoteSyncFrequency.Default;

  int version = SETTINGS_VERSION;

  SettingsHomeScreen homeScreen = SettingsHomeScreen.Default;
  SettingsTheme theme = SettingsTheme.Default;

  SettingsMarkdownDefaultView markdownDefaultView =
      SettingsMarkdownDefaultView.Default;
  SettingsMarkdownDefaultView markdownLastUsedView =
      SettingsMarkdownDefaultView.Edit;

  bool zenMode = false;

  bool swipeToDelete = true;
  bool emojiParser = true;

  bool bottomMenuBar = true;
  bool confirmDelete = true;
  bool hardWrap = false;

  void load() {
    defaultNewNoteFolderSpec =
        getString("defaultNewNoteFolderSpec") ?? defaultNewNoteFolderSpec;
    journalEditordefaultNewNoteFolderSpec =
        getString("journalEditordefaultNewNoteFolderSpec") ??
            journalEditordefaultNewNoteFolderSpec;
    journalEditorSingleNote =
        getBool("journalEditorSingleNote") ?? journalEditorSingleNote;

    remoteSyncFrequency = RemoteSyncFrequency.fromInternalString(
        getString("remoteSyncFrequency"));

    markdownDefaultView = SettingsMarkdownDefaultView.fromInternalString(
        getString("markdownDefaultView"));
    markdownLastUsedView = SettingsMarkdownDefaultView.fromInternalString(
        getString("markdownLastUsedView"));
    if (markdownLastUsedView == SettingsMarkdownDefaultView.LastUsed) {
      markdownLastUsedView = SettingsMarkdownDefaultView.Edit;
    }

    version = getInt("settingsVersion") ?? version;
    emojiParser = getBool("emojiParser") ?? emojiParser;

    homeScreen = SettingsHomeScreen.fromInternalString(getString("homeScreen"));
    theme = SettingsTheme.fromInternalString(getString("theme"));

    zenMode = getBool("zenMode") ?? zenMode;
    swipeToDelete = getBool("swipeToDelete") ?? swipeToDelete;

    // From AppState
    bottomMenuBar = getBool("bottomMenuBar") ?? bottomMenuBar;
    confirmDelete = getBool("confirmDelete") ?? confirmDelete;

    hardWrap = getBool("hardWrap") ?? hardWrap;
  }

  Future<void> save() async {
    var pref = await SharedPreferences.getInstance();
    var def = Settings(id, pref);

    await setString("defaultNewNoteFolderSpec", defaultNewNoteFolderSpec,
        def.defaultNewNoteFolderSpec);
    await setString(
        "journalEditordefaultNewNoteFolderSpec",
        journalEditordefaultNewNoteFolderSpec,
        def.journalEditordefaultNewNoteFolderSpec);
    await setBool("journalEditorSingleNote", journalEditorSingleNote,
        def.journalEditorSingleNote);
    await setString(
        "remoteSyncFrequency",
        remoteSyncFrequency.toInternalString(),
        def.remoteSyncFrequency.toInternalString());
    await setString(
        "markdownDefaultView",
        markdownDefaultView.toInternalString(),
        def.markdownDefaultView.toInternalString());
    await setString(
        "markdownLastUsedView",
        markdownLastUsedView.toInternalString(),
        def.markdownLastUsedView.toInternalString());
    await setBool("emojiParser", emojiParser, def.emojiParser);
    await setString("homeScreen", homeScreen.toInternalString(),
        def.homeScreen.toInternalString());
    await setString(
        "theme", theme.toInternalString(), def.theme.toInternalString());

    await setBool("zenMode", zenMode, def.zenMode);
    await setBool("swipeToDelete", swipeToDelete, def.swipeToDelete);
    await setBool("bottomMenuBar", bottomMenuBar, def.bottomMenuBar);
    await setBool("confirmDelete", confirmDelete, def.confirmDelete);

    await setInt("settingsVersion", version, def.version);

    await setBool("hardWrap", hardWrap, def.hardWrap);

    notifyListeners();
  }

  Map<String, String> toLoggableMap() {
    return <String, String>{
      "customMetaData": customMetaData,
      "defaultNewNoteFolderSpec":
          defaultNewNoteFolderSpec.isNotEmpty.toString(),
      "journalEditordefaultNewNoteFolderSpec":
          journalEditordefaultNewNoteFolderSpec,
      'journalEditorSingleNote': journalEditorSingleNote.toString(),
      "remoteSyncFrequency": remoteSyncFrequency.toInternalString(),
      "version": version.toString(),
      'markdownDefaultView': markdownDefaultView.toInternalString(),
      'markdownLastUsedView': markdownLastUsedView.toInternalString(),
      'homeScreen': homeScreen.toInternalString(),
      'theme': theme.toInternalString(),
      'zenMode': zenMode.toString(),
      'swipeToDelete': swipeToDelete.toString(),
      'emojiParser': emojiParser.toString(),
      'bottomMenuBar': bottomMenuBar.toString(),
      'confirmDelete': confirmDelete.toString(),
    };
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
      case Org:
        return EditorType.Org;
      default:
        assert(false, "Editor Type mismatch");
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
    Org,
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

class SettingsNoteFileFormat {
  static const Markdown = SettingsNoteFileFormat(
      LocaleKeys.settings_fileFormat_markdown, "Markdown");
  static const Txt =
      SettingsNoteFileFormat(LocaleKeys.settings_fileFormat_txt, "Txt");
  static const OrgMode =
      SettingsNoteFileFormat(LocaleKeys.settings_fileFormat_orgMode, "Org");
  static const Default = Markdown;

  final String _str;
  final String _publicString;
  const SettingsNoteFileFormat(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicString);
  }

  NoteFileFormat toFileFormat() {
    switch (this) {
      case Markdown:
        return NoteFileFormat.Markdown;
      case Txt:
        return NoteFileFormat.Txt;
      case OrgMode:
        return NoteFileFormat.OrgMode;
      default:
        return NoteFileFormat.Markdown;
    }
  }

  static SettingsNoteFileFormat fromFileFormat(NoteFileFormat format) {
    switch (format) {
      case NoteFileFormat.Markdown:
        return Markdown;
      case NoteFileFormat.Txt:
        return Txt;
      case NoteFileFormat.OrgMode:
        return OrgMode;
    }
  }

  static const options = <SettingsNoteFileFormat>[
    Markdown,
    Txt,
    OrgMode,
  ];

  static SettingsNoteFileFormat fromInternalString(String? str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static SettingsNoteFileFormat fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }

  @override
  String toString() {
    assert(false, "SettingsNoteFileFormat toString should never be called");
    return "";
  }
}

class SettingsFolderViewType {
  static const Standard = SettingsFolderViewType(
      LocaleKeys.widgets_FolderView_views_standard, "Standard");
  static const Journal = SettingsFolderViewType(
      LocaleKeys.widgets_FolderView_views_journal, "Journal");
  static const Card =
      SettingsFolderViewType(LocaleKeys.widgets_FolderView_views_card, "Card");
  static const Grid =
      SettingsFolderViewType(LocaleKeys.widgets_FolderView_views_grid, "Grid");
  static const Calendar = SettingsFolderViewType(
      LocaleKeys.widgets_FolderView_views_calendar, "Calendar");
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
    // Calendar,
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
      case Calendar:
        return FolderViewType.Calendar;
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
      case FolderViewType.Calendar:
        return SettingsFolderViewType.Calendar;
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
  static const Dark = SettingsTheme(LocaleKeys.settings_theme_dark, "dark");
  static const Light = SettingsTheme(LocaleKeys.settings_theme_light, "light");
  static const SystemDefault =
      SettingsTheme(LocaleKeys.settings_theme_default, "default");
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
