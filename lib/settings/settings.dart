/*
 * SPDX-FileCopyrightText: 2020-2021 Roland Fredenhagen <important@van-fredenhagen.de>
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gitjournal/core/folder/sorting_mode.dart';
import 'package:gitjournal/core/notes/note.dart';
import 'package:gitjournal/editors/common_types.dart';
import 'package:gitjournal/folder_views/common_types.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'settings_sharedpref.dart';

const DEFAULT_ID = "0";
const SETTINGS_VERSION = 3;

const DEFAULT_LIGHT_THEME_NAME = "LightDefault";
const DEFAULT_DARK_THEME_NAME = "DarkDefault";

const DEFAULT_BRANCH = 'main';

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
  String lightTheme = DEFAULT_LIGHT_THEME_NAME;
  String darkTheme = DEFAULT_DARK_THEME_NAME;

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
    lightTheme = getString("lightTheme") ?? lightTheme;
    darkTheme = getString("darkTheme") ?? darkTheme;

    zenMode = getBool("zenMode") ?? zenMode;
    swipeToDelete = getBool("swipeToDelete") ?? swipeToDelete;

    // From AppState
    bottomMenuBar = getBool("bottomMenuBar") ?? bottomMenuBar;
    confirmDelete = getBool("confirmDelete") ?? confirmDelete;

    hardWrap = getBool("hardWrap") ?? hardWrap;
    customMetaData = getString("customMetaData") ?? customMetaData;
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
    await setString("lightTheme", lightTheme, def.lightTheme);
    await setString("darkTheme", darkTheme, def.darkTheme);
    await setString("customMetaData", customMetaData, def.customMetaData);

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
      'lightTheme': lightTheme,
      'darkTheme': darkTheme,
      'zenMode': zenMode.toString(),
      'swipeToDelete': swipeToDelete.toString(),
      'emojiParser': emojiParser.toString(),
      'bottomMenuBar': bottomMenuBar.toString(),
      'confirmDelete': confirmDelete.toString(),
    };
  }
}

class NoteFileNameFormat extends GjSetting {
  static const Iso8601WithTimeZone = NoteFileNameFormat(
    Lk.settingsNoteFileNameFormatIso8601WithTimeZone,
    "Iso8601WithTimeZone",
  );
  static const Iso8601 = NoteFileNameFormat(
    Lk.settingsNoteFileNameFormatIso8601,
    "Iso8601",
  );
  static const Iso8601WithTimeZoneWithoutColon = NoteFileNameFormat(
    Lk.settingsNoteFileNameFormatIso8601WithoutColon,
    "Iso8601WithTimeZoneWithoutColon",
  );
  static const FromTitle = NoteFileNameFormat(
    Lk.settingsNoteFileNameFormatTitle,
    "FromTitle",
  );
  static const SimpleDate = NoteFileNameFormat(
    Lk.settingsNoteFileNameFormatSimple,
    "SimpleDate",
  );
  static const UuidV4 =
      NoteFileNameFormat(Lk.settingsNoteFileNameFormatUuid, "uuidv4");
  static const Zettelkasten = NoteFileNameFormat(
    Lk.settingsNoteFileNameFormatZettelkasten,
    "Zettelkasten",
  );
  static const DateOnly = NoteFileNameFormat(
    Lk.settingsNoteFileNameFormatDateOnly,
    "DateOnly",
  );
  static const KebabCase = NoteFileNameFormat(
    Lk.settingsNoteFileNameFormatKebabCase,
    "KebabCase",
  );

  static const Default = FromTitle;

  const NoteFileNameFormat(super.lk, super.str);

  static const options = <NoteFileNameFormat>[
    SimpleDate,
    FromTitle,
    Iso8601,
    Iso8601WithTimeZone,
    Iso8601WithTimeZoneWithoutColon,
    UuidV4,
    Zettelkasten,
    DateOnly,
    KebabCase,
  ];

  static NoteFileNameFormat fromInternalString(String? str) =>
      GjSetting.fromInternalString(options, Default, str) as NoteFileNameFormat;

  static NoteFileNameFormat fromPublicString(
          BuildContext context, String str) =>
      GjSetting.fromPublicString(context, options, Default, str)
          as NoteFileNameFormat;
}

class RemoteSyncFrequency extends GjSetting {
  static const Automatic =
      RemoteSyncFrequency(Lk.settingsRemoteSyncAuto, "automatic");
  static const Manual =
      RemoteSyncFrequency(Lk.settingsRemoteSyncManual, "manual");
  static const Default = Automatic;

  const RemoteSyncFrequency(super.lk, super.str);

  static const options = <RemoteSyncFrequency>[
    Automatic,
    Manual,
  ];

  static RemoteSyncFrequency fromInternalString(String? str) =>
      GjSetting.fromInternalString(options, Default, str)
          as RemoteSyncFrequency;

  static RemoteSyncFrequency fromPublicString(
          BuildContext context, String str) =>
      GjSetting.fromPublicString(context, options, Default, str)
          as RemoteSyncFrequency;
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

class SettingsNoteFileFormat extends GjSetting {
  static const Markdown =
      SettingsNoteFileFormat(Lk.settingsFileFormatMarkdown, "Markdown");
  static const Txt = SettingsNoteFileFormat(Lk.settingsFileFormatTxt, "Txt");
  static const OrgMode =
      SettingsNoteFileFormat(Lk.settingsFileFormatOrgMode, "Org");
  static const Default = Markdown;

  const SettingsNoteFileFormat(super.lk, super.str);

  static const options = <SettingsNoteFileFormat>[
    Markdown,
    Txt,
    OrgMode,
  ];

  static SettingsNoteFileFormat fromInternalString(String? str) =>
      GjSetting.fromInternalString(options, Default, str)
          as SettingsNoteFileFormat;

  static SettingsNoteFileFormat fromPublicString(
          BuildContext context, String str) =>
      GjSetting.fromPublicString(context, options, Default, str)
          as SettingsNoteFileFormat;

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
}

class SettingsFolderViewType extends GjSetting {
  static const Standard =
      SettingsFolderViewType(Lk.widgetsFolderViewViewsStandard, "Standard");
  static const Journal =
      SettingsFolderViewType(Lk.widgetsFolderViewViewsJournal, "Journal");
  static const Card =
      SettingsFolderViewType(Lk.widgetsFolderViewViewsCard, "Card");
  static const Grid =
      SettingsFolderViewType(Lk.widgetsFolderViewViewsGrid, "Grid");
  static const Calendar =
      SettingsFolderViewType(Lk.widgetsFolderViewViewsCalendar, "Calendar");
  static const Default = Standard;

  const SettingsFolderViewType(super.lk, super.str);

  static const options = <SettingsFolderViewType>[
    Standard,
    Journal,
    Card,
    Grid,
    // Calendar,
  ];

  static SettingsFolderViewType fromInternalString(String? str) =>
      GjSetting.fromInternalString(options, Default, str)
          as SettingsFolderViewType;

  static SettingsFolderViewType fromPublicString(
          BuildContext context, String str) =>
      GjSetting.fromPublicString(context, options, Default, str)
          as SettingsFolderViewType;

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
