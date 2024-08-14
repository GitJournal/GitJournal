/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:function_types/function_types.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'config.dart';
import 'controller.dart';
import 'device_info.dart';
import 'events.dart';
import 'generated/analytics.pb.dart' as pb;
import 'network.dart';
import 'package_info.dart';
import 'storage.dart';

export 'events.dart';

class Analytics {
  final bool canBeEnabled;

  final Func2<String, Map<String, String>, void> analyticsCallback;
  final AnalyticsStorage storage;
  final SharedPreferences pref;
  final AnalyticsConfig _config;
  late final AnalyticsController _controller;

  Analytics._({
    required this.storage,
    required this.analyticsCallback,
    required this.canBeEnabled,
    required this.pref,
    required this.pseudoId,
    required AnalyticsConfig config,
  }) : _config = config {
    _sessionId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    _controller = AnalyticsController(
      storage: storage,
      isEnabled: () => enabled,
    );
  }

  static Analytics? _global;
  static Future<Analytics> init({
    required SharedPreferences pref,
    required Func2<String, Map<String, String>, void> analyticsCallback,
    required String storagePath,
  }) async {
    bool inFireBaseTestLab =
        false; // FIXME: We need to disable analytics in Firebase Test Lab
    bool canBeEnabled = !foundation.kDebugMode && !inFireBaseTestLab;

    var pseudoId = pref.getString("pseudoId");
    if (pseudoId == null) {
      pseudoId = const Uuid().v4();
      pref.setString("pseudoId", pseudoId);
    }

    var config = AnalyticsConfig("", pref);
    config.load(pref);

    _global = Analytics._(
      analyticsCallback: analyticsCallback,
      storage: AnalyticsStorage(storagePath),
      canBeEnabled: canBeEnabled,
      pseudoId: pseudoId,
      pref: pref,
      config: config,
    );

    Log.d("Analytics Collection: ${_global!.enabled}");
    Log.d("Analytics Storage: $storagePath");

    _global!._sendAppUpdateEvent();

    return _global!;
  }

  bool get enabled {
    return canBeEnabled && _config.enabled;
  }

  set enabled(bool newVal) {
    if (enabled != newVal) {
      _config.enabled = newVal;
      _config.save();

      logEvent(
        Event.AnalyticsLevelChanged,
        parameters: {"state": newVal.toString()},
      );
    }
  }

  static Analytics? get instance => _global;

  late int _sessionId;
  late String pseudoId;
  var userProps = <String, String>{};

  Future<void> log(
    Event e, [
    Map<String, String> parameters = const {},
  ]) async {
    String name = eventToString(e);

    await storage.logEvent(_buildEvent(name, parameters));
    analyticsCallback(name, parameters);

    await _sendAnalytics();
  }

  Future<void> setCurrentScreen({required String screenName}) async {
    return log(Event.ScreenView, {'screen_name': screenName});
  }

  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    userProps[name] = value;
  }

  pb.Event _buildEvent(String name, Map<String, String> params) {
    return pb.Event(
      name: name,
      date: Int64(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      params: params,
      pseudoId: pseudoId,
      userProperties: userProps,
      sessionID: _sessionId,
    );
  }

  // FIXME: Send the backlog events when disabled
  Future<void> _sendAnalytics() async {
    var shouldSend = await _controller.shouldSend();
    if (!shouldSend) {
      return;
    }

    await storage.fetchAll((events) async {
      var msg = pb.AnalyticsMessage(
        appId: 'io.gitjournal',
        deviceInfo: await buildDeviceInfo(),
        packageInfo: await buildPackageInfo(),
        events: events,
      );
      Log.i("Sending ${events.length} events");
      try {
        await sendAnalytics(msg);
      } catch (ex, st) {
        Log.e("Failed to send Analytics", ex: ex, stacktrace: st);
        return false;
      }

      Log.i("Sent ${events.length} Analytics Events");
      return true;
    });
  }

  Future<void> _sendAppUpdateEvent() async {
    var info = await PackageInfo.fromPlatform();
    var version = info.version;

    Log.i("App Version: $version");
    Log.i("App Build Number: ${info.buildNumber}");

    if (_config.appVersion == version) {
      return;
    }

    logEvent(Event.AppUpdate, parameters: {
      "version": version,
      "previous_app_version": _config.appVersion,
      "app_name": info.appName,
      "package_name": info.packageName,
      "build_number": info.buildNumber,
    });

    _config.appVersion = version;
    _config.save();
  }
}
