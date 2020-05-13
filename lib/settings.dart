import 'package:gitjournal/folder_views/common.dart';
import 'package:gitjournal/screens/note_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gitjournal/core/sorting_mode.dart';

import 'package:uuid/uuid.dart';

class Settings {
  static List<Function> changeObservers = [];

  // singleton
  static final Settings _singleton = Settings._internal();
  factory Settings() => _singleton;
  Settings._internal();
  static Settings get instance => _singleton;

  // Properties
  String gitAuthor = "GitJournal";
  String gitAuthorEmail = "app@gitjournal.io";
  NoteFileNameFormat noteFileNameFormat;

  bool collectUsageStatistics = true;
  bool collectCrashReports = true;

  String yamlModifiedKey = "modified";
  bool yamlHeaderEnabled = true;
  String defaultNewNoteFolderSpec = "";
  String journalEditordefaultNewNoteFolderSpec = "";

  RemoteSyncFrequency remoteSyncFrequency = RemoteSyncFrequency.Default;
  SortingMode sortingMode = SortingMode.Default;
  SettingsEditorType defaultEditor = SettingsEditorType.Default;
  SettingsFolderViewType defaultView = SettingsFolderViewType.Default;
  bool showNoteSummary = true;
  String folderViewHeaderType = "TitleGenerated";
  int version = 0;

  bool proMode = false;
  String proExpirationDate = "";

  String _pseudoId;
  String get pseudoId => _pseudoId;

  SettingsHomeScreen homeScreen = SettingsHomeScreen.Default;

  SettingsMarkdownDefaultView markdownDefaultView =
      SettingsMarkdownDefaultView.Default;

  void load(SharedPreferences pref) {
    gitAuthor = pref.getString("gitAuthor") ?? gitAuthor;
    gitAuthorEmail = pref.getString("gitAuthorEmail") ?? gitAuthorEmail;

    noteFileNameFormat = NoteFileNameFormat.fromInternalString(
        pref.getString("noteFileNameFormat"));

    collectUsageStatistics =
        pref.getBool("collectUsageStatistics") ?? collectUsageStatistics;
    collectCrashReports =
        pref.getBool("collectCrashReports") ?? collectCrashReports;

    yamlModifiedKey = pref.getString("yamlModifiedKey") ?? yamlModifiedKey;
    yamlHeaderEnabled = pref.getBool("yamlHeaderEnabled") ?? yamlHeaderEnabled;
    defaultNewNoteFolderSpec =
        pref.getString("defaultNewNoteFolderSpec") ?? defaultNewNoteFolderSpec;
    journalEditordefaultNewNoteFolderSpec =
        pref.getString("journalEditordefaultNewNoteFolderSpec") ??
            journalEditordefaultNewNoteFolderSpec;

    remoteSyncFrequency = RemoteSyncFrequency.fromInternalString(
        pref.getString("remoteSyncFrequency"));

    sortingMode = SortingMode.fromInternalString(pref.getString("sortingMode"));
    defaultEditor =
        SettingsEditorType.fromInternalString(pref.getString("defaultEditor"));
    defaultView = SettingsFolderViewType.fromInternalString(
        pref.getString("defaultView"));
    markdownDefaultView = SettingsMarkdownDefaultView.fromInternalString(
        pref.getString("markdownDefaultView"));

    showNoteSummary = pref.getBool("showNoteSummary") ?? showNoteSummary;
    folderViewHeaderType =
        pref.getString("folderViewHeaderType") ?? folderViewHeaderType;

    version = pref.getInt("settingsVersion") ?? version;
    proMode = pref.getBool("proMode") ?? proMode;
    proExpirationDate =
        pref.getString("proExpirationDate") ?? proExpirationDate;

    _pseudoId = pref.getString("pseudoId");
    if (_pseudoId == null) {
      _pseudoId = Uuid().v4();
      pref.setString("pseudoId", _pseudoId);
    }

    homeScreen =
        SettingsHomeScreen.fromInternalString(pref.getString("homeScreen"));
  }

  Future save() async {
    var pref = await SharedPreferences.getInstance();
    pref.setString("gitAuthor", gitAuthor);
    pref.setString("gitAuthorEmail", gitAuthorEmail);
    pref.setString("noteFileNameFormat", noteFileNameFormat.toInternalString());
    pref.setBool("collectUsageStatistics", collectUsageStatistics);
    pref.setBool("collectCrashReports", collectCrashReports);
    pref.setString("yamlModifiedKey", yamlModifiedKey);
    pref.setBool("yamlHeaderEnabled", yamlHeaderEnabled);
    pref.setString("defaultNewNoteFolderSpec", defaultNewNoteFolderSpec);
    pref.setString("journalEditordefaultNewNoteFolderSpec",
        journalEditordefaultNewNoteFolderSpec);
    pref.setString(
        "remoteSyncFrequency", remoteSyncFrequency.toInternalString());
    pref.setString("sortingMode", sortingMode.toInternalString());
    pref.setString("defaultEditor", defaultEditor.toInternalString());
    pref.setString("defaultView", defaultView.toInternalString());
    pref.setString(
        "markdownDefaultView", markdownDefaultView.toInternalString());
    pref.setBool("showNoteSummary", showNoteSummary);
    pref.setString("folderViewHeaderType", folderViewHeaderType);
    pref.setString("proExpirationDate", proExpirationDate);
    pref.setInt("settingsVersion", version);
    pref.setBool("proMode", proMode);
    pref.setString("homeScreen", homeScreen.toInternalString());

    // Shouldn't we check if something has actually changed?
    for (var f in changeObservers) {
      f();
    }
  }

  Map<String, String> toMap() {
    return <String, String>{
      "gitAuthor": gitAuthor,
      "gitAuthorEmail": gitAuthorEmail,
      "noteFileNameFormat": noteFileNameFormat.toInternalString(),
      "collectUsageStatistics": collectUsageStatistics.toString(),
      "collectCrashReports": collectCrashReports.toString(),
      "yamlModifiedKey": yamlModifiedKey,
      "yamlHeaderEnabled": yamlHeaderEnabled.toString(),
      "defaultNewNoteFolderSpec": defaultNewNoteFolderSpec,
      "journalEditordefaultNewNoteFolderSpec":
          journalEditordefaultNewNoteFolderSpec,
      "defaultEditor": defaultEditor.toInternalString(),
      "defaultView": defaultView.toInternalString(),
      "sortingMode": sortingMode.toInternalString(),
      "remoteSyncFrequency": remoteSyncFrequency.toInternalString(),
      "showNoteSummary": showNoteSummary.toString(),
      "folderViewHeaderType": folderViewHeaderType,
      "version": version.toString(),
      "proMode": proMode.toString(),
      'pseudoId': pseudoId,
      'markdownDefaultView': markdownDefaultView.toInternalString(),
      'homeScreen': homeScreen.toInternalString(),
    };
  }

  Map<String, String> toLoggableMap() {
    var m = toMap();
    m.remove("gitAuthor");
    m.remove("gitAuthorEmail");
    m.remove("defaultNewNoteFolderSpec");
    return m;
  }
}

class NoteFileNameFormat {
  static const Iso8601WithTimeZone =
      NoteFileNameFormat("Iso8601WithTimeZone", "ISO8601 With TimeZone");
  static const Iso8601 = NoteFileNameFormat("Iso8601", "Iso8601");
  static const Iso8601WithTimeZoneWithoutColon = NoteFileNameFormat(
      "Iso8601WithTimeZoneWithoutColon", "ISO8601 without Colons");
  static const FromTitle = NoteFileNameFormat("FromTitle", "Title");
  static const SimpleDate =
      NoteFileNameFormat("SimpleDate", "yyyy-mm-dd-hh-mm-ss");

  static const Default = FromTitle;

  static const options = <NoteFileNameFormat>[
    SimpleDate,
    FromTitle,
    Iso8601,
    Iso8601WithTimeZone,
    Iso8601WithTimeZoneWithoutColon,
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
    return _publicStr;
  }

  @override
  String toString() {
    assert(false, "NoteFileNameFormat toString should never be called");
    return "";
  }
}

class RemoteSyncFrequency {
  static const Automatic = RemoteSyncFrequency("Automatic");
  static const Manual = RemoteSyncFrequency("Manual");
  static const Default = Automatic;

  final String _str;
  const RemoteSyncFrequency(this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return _str;
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
  static const Markdown = SettingsEditorType("Markdown", "Markdown");
  static const Raw = SettingsEditorType("Raw", "Raw");
  static const Journal = SettingsEditorType("Journal", "Journal");
  static const Checklist = SettingsEditorType("Checklist", "Checklist");
  static const Default = Markdown;

  final String _str;
  final String _publicString;
  const SettingsEditorType(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return _publicString;
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
  static const Standard = SettingsFolderViewType("Standard", "Standard");
  static const Journal = SettingsFolderViewType("Journal", "Journal");
  static const Card = SettingsFolderViewType("Card", "Card");
  static const Grid = SettingsFolderViewType("Grid", "Grid");
  static const Default = Standard;

  final String _str;
  final String _publicString;
  const SettingsFolderViewType(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return _publicString;
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
  static const Edit = SettingsMarkdownDefaultView("Edit");
  static const View = SettingsMarkdownDefaultView("View");
  static const Default = Edit;

  final String _str;
  const SettingsMarkdownDefaultView(this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return _str;
  }

  static const options = <SettingsMarkdownDefaultView>[
    Edit,
    View,
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
  static const AllNotes = SettingsHomeScreen("All Notes", "all_notes");
  static const AllFolders = SettingsHomeScreen("All Folders", "all_folders");
  static const Default = AllNotes;

  final String _str;
  final String _publicString;
  const SettingsHomeScreen(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return _publicString;
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
