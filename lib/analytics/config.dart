/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

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

    enabled = getBool("collectUsageStatistics") ?? enabled;
  }

  Future<void> save() async {
    var def = AnalyticsConfig(id, pref);

    await setBool("collectUsageStatistics", enabled, def.enabled);
    var _ = await pref.setString("appVersion", appVersion);
  }
}
