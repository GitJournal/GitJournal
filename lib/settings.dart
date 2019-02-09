import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  // singleton
  static final Settings _singleton = Settings._internal();
  factory Settings() => _singleton;
  Settings._internal();
  static Settings get instance => _singleton;

  Future load() async {
    var pref = await SharedPreferences.getInstance();
    gitAuthor = pref.getString("gitAuthor") ?? gitAuthor;
    gitAuthorEmail = pref.getString("gitAuthorEmail") ?? gitAuthorEmail;
  }

  Future save() async {
    var pref = await SharedPreferences.getInstance();
    pref.setString("gitAuthor", gitAuthor);
    pref.setString("gitAuthorEmail", gitAuthorEmail);
  }

  String gitAuthor = "GitJournal";
  String gitAuthorEmail = "app@gitjournal.io";
}
