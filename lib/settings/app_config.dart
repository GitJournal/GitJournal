/*
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/features.dart';
import 'package:gitjournal/logger/logger.dart';

class AppConfig extends ChangeNotifier {
  // singleton
  static final AppConfig _singleton = AppConfig._internal();
  factory AppConfig() => _singleton;
  AppConfig._internal();
  static AppConfig get instance => _singleton;

  //
  // Properties
  //
  var onBoardingCompleted = false;
  var collectCrashReports = true;

  int version = 0;

  DateTime? proExpirationDate;
  bool get proMode {
    if (proExpirationDate == null) return false;
    return DateTime.now().isBefore(proExpirationDate!);
  }

  var validateProMode = true;

  var debugLogLevel = 'v';

  var experimentalSubfolders = false;
  var experimentalMarkdownToolbar = false;
  var experimentalGraphView = false;
  var experimentalAccounts = false;
  var experimentalGitMerge = false;
  var experimentalGitOps = false;
  var experimentalTagAutoCompletion = false;

  var experimentalHistory = false;

  bool paidForFeature(Feature feature) {
    if (Features.alwaysPro) return true;
    if (proExpirationDate == null) return false;
    return feature.date.isBefore(proExpirationDate!);
  }

  void load(SharedPreferences pref) {
    onBoardingCompleted = pref.getBool("onBoardingCompleted") ?? false;

    collectCrashReports =
        pref.getBool("collectCrashReports") ?? collectCrashReports;

    version = pref.getInt("appSettingsVersion") ?? version;
    proExpirationDate =
        pref.getDateTime("proExpirationDate") ?? proExpirationDate;
    validateProMode = pref.getBool("validateProMode") ?? validateProMode;

    debugLogLevel = pref.getString("debugLogLevel") ?? debugLogLevel;
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
    experimentalTagAutoCompletion =
        pref.getBool("experimentalTagAutoCompletion") ??
            experimentalTagAutoCompletion;
    experimentalHistory =
        pref.getBool("experimentalHistory") ?? experimentalHistory;
  }

  Future<void> save() async {
    var pref = await SharedPreferences.getInstance();
    var defaultSet = AppConfig._internal();

    dynamic _;
    _ = pref.setBool("onBoardingCompleted", onBoardingCompleted);

    _setBool(pref, "collectCrashReports", collectCrashReports,
        defaultSet.collectCrashReports);

    _setDateTime(pref, "proExpirationDate", proExpirationDate,
        defaultSet.proExpirationDate);
    _setBool(
        pref, "validateProMode", validateProMode, defaultSet.validateProMode);
    _setString(pref, "debugLogLevel", debugLogLevel, defaultSet.debugLogLevel);
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
    _setBool(
        pref,
        "experimentalTagAutoCompletion",
        experimentalTagAutoCompletion,
        defaultSet.experimentalTagAutoCompletion);
    _setBool(pref, "experimentalHistory", experimentalHistory,
        defaultSet.experimentalHistory);

    _ = pref.setInt("appSettingsVersion", version);

    notifyListeners();
  }

  Map<String, String> toMap() {
    return {
      "onBoardingCompleted": onBoardingCompleted.toString(),
      "collectCrashReports": collectCrashReports.toString(),
      "version": version.toString(),
      'validateProMode': validateProMode.toString(),
      'proExpirationDate': proExpirationDate.toString(),
      'debugLogLevel': debugLogLevel,
      'experimentalMarkdownToolbar': experimentalMarkdownToolbar.toString(),
      'experimentalGraphView': experimentalGraphView.toString(),
      'experimentalAccounts': experimentalAccounts.toString(),
      'experimentalGitMerge': experimentalGitMerge.toString(),
      'experimentalGitOps': experimentalGitOps.toString(),
      'experimentalTagAutoCompletion': experimentalTagAutoCompletion.toString(),
      'experimentalHistory': experimentalHistory.toString(),
    };
  }

  Future<void> _setString(
    SharedPreferences pref,
    String key,
    String value,
    String defaultValue,
  ) async {
    if (value == defaultValue) {
      var _ = await pref.remove(key);
    } else {
      var _ = await pref.setString(key, value);
    }
  }

  Future<void> _setBool(
    SharedPreferences pref,
    String key,
    bool value,
    bool defaultValue,
  ) async {
    if (value == defaultValue) {
      var _ = await pref.remove(key);
    } else {
      var _ = await pref.setBool(key, value);
    }
  }

  Future<void> _setDateTime(
    SharedPreferences pref,
    String key,
    DateTime? value,
    DateTime? defaultValue,
  ) async {
    dynamic _;
    if (value == null || value == defaultValue) {
      _ = await pref.remove(key);
      return;
    }

    _ = await pref.setInt(key, value.millisecondsSinceEpoch ~/ 1000);
  }
}

extension Date on SharedPreferences {
  DateTime? getDateTime(String key) {
    try {
      var v = getInt(key);
      if (v == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(v * 1000);
    } catch (e, st) {
      Log.e("getDataTime", ex: e, stacktrace: st);
      return null;
    }
  }
}
