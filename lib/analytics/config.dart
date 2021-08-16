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
  var enabled = true;

  void load(SharedPreferences pref) {
    appVersion = pref.getString("appVersion") ?? "";

    enabled = pref.getBool("collectUsageStatistics") ?? enabled;
  }

  Future<void> save() async {
    var def = AnalyticsConfig(id, pref);

    await setBool("collectUsageStatistics", enabled, def.enabled);
    await pref.setString("appVersion", appVersion);
  }
}
