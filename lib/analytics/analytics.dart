import 'package:fixnum/fixnum.dart';
import 'package:function_types/function_types.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:gitjournal/logger/logger.dart';
import 'device_info.dart';
import 'events.dart';
import 'generated/analytics.pb.dart' as pb;
import 'network.dart';
import 'package_info.dart';
import 'storage.dart';

export 'events.dart';

const defaultAnalyticsEnabled = true;

class Analytics {
  bool enabled = defaultAnalyticsEnabled;
  bool collectUsageStatistics = defaultAnalyticsEnabled;

  final Func2<String, Map<String, String>, void> analyticsCallback;
  final AnalyticsStorage storage;
  final SharedPreferences pref;

  Analytics._({
    required this.storage,
    required this.analyticsCallback,
    required this.enabled,
    required this.pref,
    required String pseudoId,
  }) {
    collectUsageStatistics =
        pref.getBool("collectUsageStatistics") ?? collectUsageStatistics;

    _sessionId = DateTime.now().millisecondsSinceEpoch.toRadixString(16);
  }

  static Analytics? _global;
  static Analytics init({
    required bool enable,
    required SharedPreferences pref,
    required Func2<String, Map<String, String>, void> analyticsCallback,
    required String storagePath,
  }) {
    var pseudoId = pref.getString("pseudoId");
    if (pseudoId == null) {
      pseudoId = const Uuid().v4();
      pref.setString("pseudoId", _global!._pseudoId);
    }

    _global = Analytics._(
      analyticsCallback: analyticsCallback,
      storage: AnalyticsStorage(storagePath),
      enabled: enable,
      pseudoId: pseudoId,
      pref: pref,
    );

    return _global!;
  }

  Future<void> save() async {
    _setBool(pref, "collectUsageStatistics", collectUsageStatistics,
        defaultAnalyticsEnabled);
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

  static Analytics? get instance => _global;

  late String _sessionId;
  late String _pseudoId;
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
      pseudoId: _pseudoId,
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
}


// FIXME: Discard the old analytics, if there are way too many!
// TODO: Take network connectivity into account
// TODO: Take connection type (wifi vs mobile) into account
