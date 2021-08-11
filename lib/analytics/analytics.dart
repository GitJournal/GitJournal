import 'package:fixnum/fixnum.dart';
import 'package:function_types/function_types.dart';
import 'package:recase/recase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:gitjournal/features.dart';
import 'package:gitjournal/logger/logger.dart';
import 'generated/analytics.pb.dart' as pb;
import 'storage.dart';

enum Event {
  NoteAdded,
  NoteUpdated,
  NoteDeleted,
  NoteUndoDeleted,
  NoteRenamed,
  NoteMoved,
  FileRenamed,
  FolderAdded,
  FolderDeleted,
  FolderRenamed,
  FolderConfigUpdated,
  RepoSynced,

  DrawerSetupGitHost,
  DrawerShare,
  DrawerRate,
  DrawerFeedback,
  DrawerBugReport,
  DrawerSettings,

  PurchaseScreenOpen,
  PurchaseScreenClose,
  PurchaseScreenThankYou,

  GitHostSetupError,
  GitHostSetupComplete,
  GitHostSetupGitCloneError,
  GitHostSetupButtonClick,

  Settings,
  FeatureTimelineGithubClicked,

  AppFirstOpen,
  AppUpdate,

  // FIXME: Add os_update

  /*
  Firebase Automatic Events:
    app_update:
      previous_app_version

    first_open
    in_app_purchase
    screen_view
    session_start
    user_engagement
  */
  ScreenView,
  AnalyticsLevelChanged,
  CrashReportingLevelChanged,
}

class Analytics {
  bool enabled = false;
  final Func2<String, Map<String, String>, void> analyticsCallback;
  final AnalyticsStorage storage;

  Analytics._({required this.storage, required this.analyticsCallback});

  static Analytics? _global;
  static Analytics init({
    required bool enable,
    required SharedPreferences pref,
    required Func2<String, Map<String, String>, void> analyticsCallback,
    required String storagePath,
  }) {
    if (!Features.newAnalytics) {
      enable = false;
    }

    _global = Analytics._(
      analyticsCallback: analyticsCallback,
      storage: AnalyticsStorage(storagePath),
    );
    _global!.enabled = enable;
    _global!._sessionId =
        DateTime.now().millisecondsSinceEpoch.toRadixString(16);

    var p = pref.getString("pseudoId");
    if (p == null) {
      _global!._pseudoId = const Uuid().v4();
      pref.setString("pseudoId", _global!._pseudoId);
    } else {
      _global!._pseudoId = p;
    }

    return _global!;
  }

  static Analytics? get instance => _global;

  late String _sessionId;
  late String _pseudoId;
  var userProps = <String, String>{};

  Future<void> log(
    Event e, [
    Map<String, String> parameters = const {},
  ]) async {
    String name = _eventToString(e);

    await storage.logEvent(_buildEvent(name, parameters));
    analyticsCallback(name, parameters);
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
}

void logEvent(Event event, {Map<String, String> parameters = const {}}) {
  Analytics.instance?.log(event, parameters);
  Log.d("$event", props: parameters);
}

String _eventToString(Event e) {
  var str = e.toString().substring('Event.'.length);
  return ReCase(str).snakeCase;
}
