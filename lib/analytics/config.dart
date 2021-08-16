import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/settings/settings_sharedpref.dart';

class AnalyticsConfig extends ChangeNotifier with SettingsSharedPref {
  AnalyticsConfig(this.id, this.pref);

  @override
  final String id;

  @override
  final SharedPreferences pref;

  var appVersion = "";

  void load(SharedPreferences pref) {
    appVersion = pref.getString("appVersion") ?? "";
  }

  Future<void> save() async {
    // var def = AnalyticsConfig(id, pref);

    pref.setString("appVersion", appVersion);
  }
}


// TODO
// 1. Config
// 2. Move all the logic from app to here (firebase)
// 3. Move the controlling logic over here
// 4. Backend stuff
// 5. Simple event log - UI
