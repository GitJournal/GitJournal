/*
Copyright 2020-2021 Vishesh Handa <me@vhanda.in>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/features.dart';

class AppSettings extends ChangeNotifier {
  // singleton
  static final AppSettings _singleton = AppSettings._internal();
  factory AppSettings() => _singleton;
  AppSettings._internal();
  static AppSettings get instance => _singleton;

  //
  // Properties
  //
  var onBoardingCompleted = false;
  var collectCrashReports = true;

  int version = 0;

  var proMode = Features.alwaysPro;
  var proExpirationDate = "";
  var validateProMode = true;

  var debugLogLevel = 'v';

  var experimentalFs = false;
  var experimentalSubfolders = false;
  var experimentalMarkdownToolbar = false;
  var experimentalGraphView = false;
  var experimentalAccounts = false;
  var experimentalGitMerge = false;
  var experimentalGitOps = false;

  void load(SharedPreferences pref) {
    onBoardingCompleted = pref.getBool("onBoardingCompleted") ?? false;

    collectCrashReports =
        pref.getBool("collectCrashReports") ?? collectCrashReports;

    version = pref.getInt("appSettingsVersion") ?? version;
    proMode = pref.getBool("proMode") ?? proMode;
    proExpirationDate =
        pref.getString("proExpirationDate") ?? proExpirationDate;
    validateProMode = pref.getBool("validateProMode") ?? validateProMode;

    debugLogLevel = pref.getString("debugLogLevel") ?? debugLogLevel;
    experimentalFs = pref.getBool("experimentalFs") ?? experimentalFs;
    experimentalSubfolders =
        pref.getBool("experimentalSubfolders") ?? experimentalSubfolders;
    experimentalMarkdownToolbar = pref.getBool("experimentalMarkdownToolbar") ??
        experimentalMarkdownToolbar;
    experimentalGraphView =
        pref.getBool("experimentalGraphView") ?? experimentalGraphView;
    experimentalAccounts =
        pref.getBool("experimentalAccounts") ?? experimentalAccounts;
    experimentalGitMerge =
        pref.getBool("experimentalGitMerge") ?? experimentalGitMerge;
    experimentalGitOps =
        pref.getBool("experimentalGitOps") ?? experimentalGitOps;
  }

  Future<void> save() async {
    var pref = await SharedPreferences.getInstance();
    var defaultSet = AppSettings._internal();

    pref.setBool("onBoardingCompleted", onBoardingCompleted);

    _setBool(pref, "collectCrashReports", collectCrashReports,
        defaultSet.collectCrashReports);

    _setString(pref, "proExpirationDate", proExpirationDate,
        defaultSet.proExpirationDate);
    _setBool(pref, "proMode", proMode, defaultSet.proMode);
    _setBool(
        pref, "validateProMode", validateProMode, defaultSet.validateProMode);
    _setString(pref, "debugLogLevel", debugLogLevel, defaultSet.debugLogLevel);
    _setBool(pref, "experimentalFs", experimentalFs, defaultSet.experimentalFs);
    _setBool(pref, "experimentalSubfolders", experimentalSubfolders,
        defaultSet.experimentalSubfolders);
    _setBool(pref, "experimentalMarkdownToolbar", experimentalMarkdownToolbar,
        defaultSet.experimentalMarkdownToolbar);
    _setBool(pref, "experimentalGraphView", experimentalGraphView,
        defaultSet.experimentalGraphView);
    _setBool(pref, "experimentalAccounts", experimentalAccounts,
        defaultSet.experimentalAccounts);
    _setBool(pref, "experimentalGitMerge", experimentalGitMerge,
        defaultSet.experimentalGitMerge);
    _setBool(pref, "experimentalGitOps", experimentalGitOps,
        defaultSet.experimentalGitOps);

    pref.setInt("appSettingsVersion", version);

    notifyListeners();
  }

  Map<String, String> toMap() {
    return {
      "onBoardingCompleted": onBoardingCompleted.toString(),
      "collectCrashReports": collectCrashReports.toString(),
      "version": version.toString(),
      "proMode": proMode.toString(),
      'validateProMode': validateProMode.toString(),
      'proExpirationDate': proExpirationDate,
      'debugLogLevel': debugLogLevel,
      'experimentalFs': experimentalFs.toString(),
      'experimentalMarkdownToolbar': experimentalMarkdownToolbar.toString(),
      'experimentalGraphView': experimentalGraphView.toString(),
      'experimentalAccounts': experimentalAccounts.toString(),
      'experimentalGitMerge': experimentalGitMerge.toString(),
      'experimentalGitOps': experimentalGitOps.toString(),
    };
  }

  Future<void> _setString(
    SharedPreferences pref,
    String key,
    String value,
    String defaultValue,
  ) async {
    if (value == defaultValue) {
      await pref.remove(key);
    } else {
      await pref.setString(key, value);
    }
  }

  Future<void> _setBool(
    SharedPreferences pref,
    String key,
    bool value,
    bool defaultValue,
  ) async {
    if (value == defaultValue) {
      await pref.remove(key);
    } else {
      await pref.setBool(key, value);
    }
  }
}
