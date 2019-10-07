import 'package:shared_preferences/shared_preferences.dart';

enum NoteViewerFontSize { Normal, Small, ExtraSmall, Large, ExtraLarge }
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

  NoteViewerFontSize noteViewerFontSize = NoteViewerFontSize.Normal;

  bool collectUsageStatistics = true;
  bool collectCrashReports = true;

  void load(SharedPreferences pref) {
    gitAuthor = pref.getString("gitAuthor") ?? gitAuthor;
    gitAuthorEmail = pref.getString("gitAuthorEmail") ?? gitAuthorEmail;

    String str;
    str = pref.getString("noteViewerFontSize") ?? noteViewerFontSize.toString();
    noteViewerFontSize =
        NoteViewerFontSize.values.firstWhere((e) => e.toString() == str);

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
    pref.setString("noteViewerFontSize", noteViewerFontSize.toString());
    pref.setString("noteFileNameFormat", noteFileNameFormat.toString());
    pref.setBool("collectUsageStatistics", collectUsageStatistics);
    pref.setBool("collectCrashReports", collectCrashReports);

    // Shouldn't we check if something has actually changed?
    for (var f in changeObservers) {
      f();
    }
  }

  double getNoteViewerFontSize() {
    return noteViewerFontSizeToDouble(noteViewerFontSize);
  }

  static double noteViewerFontSizeToDouble(NoteViewerFontSize size) {
    switch (size) {
      case NoteViewerFontSize.Normal:
        return 18.0;
      case NoteViewerFontSize.Small:
        return 15.0;
      case NoteViewerFontSize.ExtraSmall:
        return 12.0;
      case NoteViewerFontSize.Large:
        return 22.0;
      case NoteViewerFontSize.ExtraLarge:
        return 26.0;
    }

    assert(false, "noteViewerFontSizeToDouble: We should never be here");
    return 50000.0;
  }

  static String noteViewerFontSizeToString(NoteViewerFontSize size) {
    switch (size) {
      case NoteViewerFontSize.Normal:
        return "Normal";
      case NoteViewerFontSize.Small:
        return "Small";
      case NoteViewerFontSize.ExtraSmall:
        return "Extra Small";
      case NoteViewerFontSize.Large:
        return "Large";
      case NoteViewerFontSize.ExtraLarge:
        return "Extra Large";
    }

    assert(false, "noteViewerFontSizeToString: We should never be here");
    return "";
  }

  static NoteViewerFontSize noteViewerFontSizeFromString(String val) {
    switch (val) {
      case "Extra Small":
        return NoteViewerFontSize.ExtraSmall;
      case "Small":
        return NoteViewerFontSize.Small;
      case "Normal":
        return NoteViewerFontSize.Normal;
      case "Large":
        return NoteViewerFontSize.Large;
      case "Extra Large":
        return NoteViewerFontSize.ExtraLarge;
      default:
        return NoteViewerFontSize.Normal;
    }
  }
}
