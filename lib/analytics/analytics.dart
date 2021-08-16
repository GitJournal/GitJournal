import 'package:flutter/foundation.dart' as foundation;

import 'package:fixnum/fixnum.dart';
import 'package:flutter_runtime_env/flutter_runtime_env.dart';
import 'package:function_types/function_types.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:gitjournal/analytics/config.dart';
import 'package:gitjournal/logger/logger.dart';
import 'device_info.dart';
import 'events.dart';
import 'generated/analytics.pb.dart' as pb;
import 'network.dart';
import 'package_info.dart';
import 'storage.dart';

export 'events.dart';

class Analytics {
  late bool enabled;

  final Func2<String, Map<String, String>, void> analyticsCallback;
  final AnalyticsStorage storage;
  final SharedPreferences pref;
  final AnalyticsConfig config;

  Analytics._({
    required this.storage,
    required this.analyticsCallback,
    required this.enabled,
    required this.pref,
    required this.pseudoId,
    required this.config,
  }) {
    _sessionId = DateTime.now().millisecondsSinceEpoch.toRadixString(16);
  }

  static Analytics? _global;
  static Future<Analytics> init({
    required SharedPreferences pref,
    required Func2<String, Map<String, String>, void> analyticsCallback,
    required String storagePath,
  }) async {
    bool inFireBaseTestLab = await inFirebaseTestLab();
    bool canBeEnabled = !foundation.kDebugMode && !inFireBaseTestLab;

    var pseudoId = pref.getString("pseudoId");
    if (pseudoId == null) {
      pseudoId = const Uuid().v4();
      pref.setString("pseudoId", pseudoId);
    }

    var config = AnalyticsConfig("", pref);
    config.load(pref);

    var enabled = canBeEnabled && config.enabled;

    _global = Analytics._(
      analyticsCallback: analyticsCallback,
      storage: AnalyticsStorage(storagePath),
      enabled: enabled,
      pseudoId: pseudoId,
      pref: pref,
      config: config,
    );

    Log.d("Analytics Collection: $enabled");
    Log.d("Analytics Storage: $storagePath");

    _global!._sendAppUpdateEvent();

    return _global!;
  }

  static Analytics? get instance => _global;

  late String _sessionId;
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
      userFirstTouchTimestamp: null,
    );
  }

  Future<void> _sendAnalytics() async {
    if (!enabled) {
      return;
    }

    var oldestEvent = await storage.oldestEvent();
    if (DateTime.now().difference(oldestEvent) < const Duration(hours: 1)) {
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
      var result = await sendAnalytics(msg);
      if (result.isFailure) {
        Log.e(
          "Failed to send Analytics",
          ex: result.error,
          stacktrace: result.stackTrace,
        );
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

    if (config.appVersion == version) {
      return;
    }

    logEvent(Event.AppUpdate, parameters: {
      "version": version,
      "previous_app_version": config.appVersion,
      "app_name": info.appName,
      "package_name": info.packageName,
      "build_number": info.buildNumber,
    });

    config.appVersion = version;
    config.save();
  }
}


// FIXME: Discard the old analytics, if there are way too many!
// TODO: Take network connectivity into account
// TODO: Take connection type (wifi vs mobile) into account
