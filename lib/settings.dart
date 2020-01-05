import 'package:shared_preferences/shared_preferences.dart';

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

  NoteFontSize noteFontSize;

  bool collectUsageStatistics = true;
  bool collectCrashReports = true;

  String yamlModifiedKey = "modified";
  int version = 0;

  void load(SharedPreferences pref) {
    gitAuthor = pref.getString("gitAuthor") ?? gitAuthor;
    gitAuthorEmail = pref.getString("gitAuthorEmail") ?? gitAuthorEmail;

    noteFontSize =
        NoteFontSize.fromInternalString(pref.getString("noteFontSize"));

    noteFileNameFormat = NoteFileNameFormat.fromInternalString(
        pref.getString("noteFileNameFormat"));

    collectUsageStatistics =
        pref.getBool("collectCrashReports") ?? collectUsageStatistics;
    collectCrashReports =
        pref.getBool("collectCrashReports") ?? collectCrashReports;

    yamlModifiedKey = pref.getString("yamlModifiedKey") ?? yamlModifiedKey;
    version = pref.getInt("settingsVersion") ?? version;
  }

  Future save() async {
    var pref = await SharedPreferences.getInstance();
    pref.setString("gitAuthor", gitAuthor);
    pref.setString("gitAuthorEmail", gitAuthorEmail);
    pref.setString("noteFontSize", noteFontSize.toInternalString());
    pref.setString("noteFileNameFormat", noteFileNameFormat.toInternalString());
    pref.setBool("collectUsageStatistics", collectUsageStatistics);
    pref.setBool("collectCrashReports", collectCrashReports);
    pref.setString("yamlModifiedKey", yamlModifiedKey);
    pref.setInt("settingsVersion", version);

    // Shouldn't we check if something has actually changed?
    for (var f in changeObservers) {
      f();
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "gitAuthor": gitAuthor,
      "gitAuthorEmail": gitAuthorEmail,
      "noteFontSize": noteFontSize.toInternalString(),
      "noteFileNameFormat": noteFileNameFormat.toInternalString(),
      "collectUsageStatistics": collectUsageStatistics,
      "collectCrashReports": collectCrashReports,
      "yamlModifiedKey": yamlModifiedKey,
      "version": version,
    };
  }

  Map<String, dynamic> toLoggableMap() {
    var m = toMap();
    m.remove("gitAuthor");
    m.remove("gitAuthorEmail");
    return m;
  }
}

class NoteFontSize {
  static const ExtraSmall = NoteFontSize("ExtraSmall", "Extra Small", 12.0);
  static const Small = NoteFontSize("Small", "Small", 16.0);
  static const Normal = NoteFontSize("Normal", "Normal", 18.0);
  static const Large = NoteFontSize("Large", "Large", 22.0);
  static const ExtraLarge = NoteFontSize("ExtraLarge", "Extra Large", 26.0);

  static const options = <NoteFontSize>[
    ExtraSmall,
    Small,
    Normal,
    Large,
    ExtraLarge,
  ];

  static NoteFontSize fromInternalString(String str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Normal;
  }

  static NoteFontSize fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Normal;
  }

  final String _str;
  final String _publicStr;
  final double _value;

  const NoteFontSize(this._str, this._publicStr, this._value);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return _publicStr;
  }

  double toDouble() {
    return _value;
  }

  @override
  String toString() {
    assert(false, "NoteFontSize toString should never be called");
    return "";
  }
}

class NoteFileNameFormat {
  static const Iso8601WithTimeZone =
      NoteFileNameFormat("Iso8601WithTimeZone", "ISO8601 With TimeZone");
  static const Iso8601 = NoteFileNameFormat("Iso8601", "Iso8601");
  static const Iso8601WithTimeZoneWithoutColon = NoteFileNameFormat(
      "Iso8601WithTimeZoneWithoutColon", "ISO8601 without Colons");

  static const Default = Iso8601WithTimeZone;

  static const options = <NoteFileNameFormat>[
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
