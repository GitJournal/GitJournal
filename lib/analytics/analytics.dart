import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:recase/recase.dart';

import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/logger/logger.dart';
import 'generated/analytics.pb.dart' as pb;

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
}
const int _intMaxValue = 9007199254740991;

class Analytics {
  bool enabled = false;

  static Analytics? _global;
  static Analytics init({required bool enable}) {
    _global = Analytics();
    _global!.enabled = enable;
    _global!.sessionId = Random().nextInt(_intMaxValue).toRadixString(16);

    return _global!;
  }

  static Analytics? get instance => _global!;

  late String sessionId;
  var userProps = <String, String>{};

  Future<void> log({
    required Event e,
    Map<String, String> parameters = const {},
  }) async {
    String name = _eventToString(e);
    if (enabled) {
      var event = _buildEvent(name, parameters);
      print(event);
      // await firebase.logEvent(name: name, parameters: parameters);
    }
    captureErrorBreadcrumb(name: name, parameters: parameters);
  }

  Future<void> setCurrentScreen({required String screenName}) async {
    if (!enabled) {
      return;
    }
    // await firebase.setCurrentScreen(screenName: screenName);
  }

  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    if (!enabled) {
      return;
    }
    userProps[name] = value;
  }

  pb.Event _buildEvent(String name, Map<String, String> params) {
    return pb.Event(
      name: name,
      date: Int64(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      params: params,
      psuedoId: null,
      userProperties: userProps,
      sessionID: sessionId,
      userFirstTouchTimestamp: null,
    );
  }
}

void logEvent(Event event, {Map<String, String> parameters = const {}}) {
  Analytics.instance?.log(e: event, parameters: parameters);
  Log.d("$event", props: parameters);
}

String _eventToString(Event e) {
  var str = e.toString().substring('Event.'.length);
  return ReCase(str).snakeCase;
}
