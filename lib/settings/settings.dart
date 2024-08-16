/*
 * SPDX-FileCopyrightText: 2020-2021 Roland Fredenhagen <important@van-fredenhagen.de>
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/core/folder/sorting_mode.dart';
import 'package:gitjournal/core/notes/note.dart';
import 'package:gitjournal/editors/common_types.dart';
import 'package:gitjournal/folder_views/common_types.dart';
import 'package:gitjournal/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';
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

  String locale = Platform.localeName;

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
    locale = getString("locale") ?? locale;
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
    await setString("locale", locale, def.locale);

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

class SettingsEditorType extends GjSetting {
  static const Markdown =
      SettingsEditorType(Lk.settingsEditorsMarkdownEditor, "Markdown");
  static const Raw = SettingsEditorType(Lk.settingsEditorsRawEditor, "Raw");
  static const Journal =
      SettingsEditorType(Lk.settingsEditorsJournalEditor, "Journal");
  static const Checklist =
      SettingsEditorType(Lk.settingsEditorsChecklistEditor, "Checklist");
  static const Org = SettingsEditorType(Lk.settingsEditorsOrgEditor, "Org");
  static const Default = Markdown;

  const SettingsEditorType(super.lk, super.str);

  static const options = <SettingsEditorType>[
    Markdown,
    Raw,
    Journal,
    Checklist,
    Org,
  ];

  static SettingsEditorType fromInternalString(String? str) =>
      GjSetting.fromInternalString(options, Default, str) as SettingsEditorType;

  static SettingsEditorType fromPublicString(
          BuildContext context, String str) =>
      GjSetting.fromPublicString(context, options, Default, str)
          as SettingsEditorType;

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
  static const Default = Standard;

  const SettingsFolderViewType(super.lk, super.str);

  static const options = <SettingsFolderViewType>[
    Standard,
    Journal,
    Card,
    Grid,
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

class SettingsMarkdownDefaultView extends GjSetting {
  static const Edit =
      SettingsMarkdownDefaultView(Lk.settingsEditorDefaultViewEdit, "Edit");
  static const View =
      SettingsMarkdownDefaultView(Lk.settingsEditorDefaultViewView, "View");
  static const LastUsed = SettingsMarkdownDefaultView(
      Lk.settingsEditorDefaultViewLastUsed, "Last Used");
  static const Default = LastUsed;

  const SettingsMarkdownDefaultView(super.lk, super.str);

  static const options = <SettingsMarkdownDefaultView>[
    Edit,
    View,
    LastUsed,
  ];

  static SettingsMarkdownDefaultView fromInternalString(String? str) =>
      GjSetting.fromInternalString(options, Default, str)
          as SettingsMarkdownDefaultView;

  static SettingsMarkdownDefaultView fromPublicString(
          BuildContext context, String str) =>
      GjSetting.fromPublicString(context, options, Default, str)
          as SettingsMarkdownDefaultView;
}

class SettingsHomeScreen extends GjSetting {
  static const AllNotes =
      SettingsHomeScreen(Lk.settingsHomeScreenAllNotes, "all_notes");
  static const AllFolders =
      SettingsHomeScreen(Lk.settingsHomeScreenAllFolders, "all_folders");
  static const Default = AllNotes;

  const SettingsHomeScreen(super.lk, super.str);

  static const options = <SettingsHomeScreen>[
    AllNotes,
    AllFolders,
  ];

  static SettingsHomeScreen fromInternalString(String? str) =>
      GjSetting.fromInternalString(options, Default, str) as SettingsHomeScreen;

  static SettingsHomeScreen fromPublicString(
          BuildContext context, String str) =>
      GjSetting.fromPublicString(context, options, Default, str)
          as SettingsHomeScreen;
}

String generateRandomId() {
  return const Uuid().v4().substring(0, 8);
}

class SettingsTheme extends GjSetting {
  static const Dark = SettingsTheme(Lk.settingsThemeDark, "dark");
  static const Light = SettingsTheme(Lk.settingsThemeLight, "light");
  static const SystemDefault =
      SettingsTheme(Lk.settingsThemeDefault, "default");
  static const Default = SystemDefault;

  const SettingsTheme(super.lk, super.str);

  static const options = <SettingsTheme>[
    Light,
    Dark,
    SystemDefault,
  ];

  static SettingsTheme fromInternalString(String? str) =>
      GjSetting.fromInternalString(options, Default, str) as SettingsTheme;

  static SettingsTheme fromPublicString(BuildContext context, String str) =>
      GjSetting.fromPublicString(context, options, Default, str)
          as SettingsTheme;

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

class SettingsTitle extends GjSetting {
  static const InYaml =
      SettingsTitle(Lk.settingsNoteMetaDataTitleMetaDataFromYaml, "yaml");
  static const InH1 =
      SettingsTitle(Lk.settingsNoteMetaDataTitleMetaDataFromH1, "h1");
  static const InFileName =
      SettingsTitle(Lk.settingsNoteMetaDataTitleMetaDataFilename, "filename");

  static const Default = InH1;

  const SettingsTitle(super.lk, super.str);

  static const options = <SettingsTitle>[
    InH1,
    InYaml,
    // InFileName,
  ];

  static SettingsTitle fromInternalString(String? str) =>
      GjSetting.fromInternalString(options, Default, str) as SettingsTitle;

  static SettingsTitle fromPublicString(BuildContext context, String str) =>
      GjSetting.fromPublicString(context, options, Default, str)
          as SettingsTitle;
}

Set<String> parseTags(String tags) {
  return tags
      .toLowerCase()
      .split(",")
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toSet();
}
