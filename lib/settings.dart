import 'package:shared_preferences/shared_preferences.dart';

enum NoteFileNameFormat {
  Iso8601,
  Iso8601WithTimeZone,
  Iso8601WithTimeZoneWithoutColon,
}

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
  NoteFileNameFormat noteFileNameFormat =
      NoteFileNameFormat.Iso8601WithTimeZone;

  NoteFontSize noteFontSize;

  bool collectUsageStatistics = true;
  bool collectCrashReports = true;

  void load(SharedPreferences pref) {
    gitAuthor = pref.getString("gitAuthor") ?? gitAuthor;
    gitAuthorEmail = pref.getString("gitAuthorEmail") ?? gitAuthorEmail;

    noteFontSize =
        NoteFontSize.fromInternalString(pref.getString("noteFontSize"));

    String str;
    str = pref.getString("noteFileNameFormat") ?? noteFileNameFormat.toString();
    noteFileNameFormat =
        NoteFileNameFormat.values.firstWhere((e) => e.toString() == str);

    collectUsageStatistics =
        pref.getBool("collectCrashReports") ?? collectUsageStatistics;
    collectCrashReports =
        pref.getBool("collectCrashReports") ?? collectCrashReports;
  }

  Future save() async {
    var pref = await SharedPreferences.getInstance();
    pref.setString("gitAuthor", gitAuthor);
    pref.setString("gitAuthorEmail", gitAuthorEmail);
    pref.setString("noteFontSize", noteFontSize.toInternalString());
    pref.setString("noteFileNameFormat", noteFileNameFormat.toString());
    pref.setBool("collectUsageStatistics", collectUsageStatistics);
    pref.setBool("collectCrashReports", collectCrashReports);

    // Shouldn't we check if something has actually changed?
    for (var f in changeObservers) {
      f();
    }
  }
}

class NoteFontSize {
  static const ExtraSmall = NoteFontSize("ExtraSmall", "Small", 12.0);
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
