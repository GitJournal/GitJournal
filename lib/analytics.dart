import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:gitjournal/app.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/utils/logger.dart';

Analytics getAnalytics() {
  return JournalApp.analytics;
}

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

String _eventToString(Event e) {
  switch (e) {
    case Event.NoteAdded:
      return "note_added";
    case Event.NoteUpdated:
      return "note_updated";
    case Event.NoteDeleted:
      return "note_deleted";
    case Event.NoteUndoDeleted:
      return "note_undo_deleted";
    case Event.NoteRenamed:
      return "note_renamed";
    case Event.NoteMoved:
      return "note_moved";

    case Event.FileRenamed:
      return "file_renamed";

    case Event.FolderAdded:
      return "folder_added";
    case Event.FolderDeleted:
      return "folder_deleted";
    case Event.FolderRenamed:
      return "folder_renamed";
    case Event.FolderConfigUpdated:
      return "folder_config_updated";

    case Event.RepoSynced:
      return "repo_synced";

    case Event.DrawerSetupGitHost:
      return "drawer_setupGitHost";
    case Event.DrawerShare:
      return "drawer_share";
    case Event.DrawerRate:
      return "drawer_rate";
    case Event.DrawerFeedback:
      return "drawer_feedback";
    case Event.DrawerBugReport:
      return "drawer_bugreport";
    case Event.DrawerSettings:
      return "drawer_settings";

    case Event.PurchaseScreenOpen:
      return "purchase_screen_open";
    case Event.PurchaseScreenClose:
      return "purchase_screen_close";
    case Event.PurchaseScreenThankYou:
      return "purchase_screen_thank_you";

    case Event.GitHostSetupError:
      return "githostsetup_error";
    case Event.GitHostSetupComplete:
      return "onboarding_complete";
    case Event.GitHostSetupGitCloneError:
      return "onboarding_gitClone_error";
    case Event.GitHostSetupButtonClick:
      return "githostsetup_button_click";

    case Event.Settings:
      return "settings";

    case Event.FeatureTimelineGithubClicked:
      return "feature_timeline_github_clicked";

    case Event.AppFirstOpen:
      return "gj_first_open";
    case Event.AppUpdate:
      return "gj_app_update";
  }

  return "unknown_event";
}

class Analytics {
  var firebase = FirebaseAnalytics();
  bool enabled = false;

  Future<void> log({
    @required Event e,
    Map<String, String> parameters = const {},
  }) async {
    String name = _eventToString(e);
    await firebase.logEvent(name: name, parameters: parameters);
    captureErrorBreadcrumb(name: name, parameters: parameters);
  }

  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    this.enabled = enabled;
    return firebase.setAnalyticsCollectionEnabled(enabled);
  }

  Future<void> setCurrentScreen({@required String screenName}) async {
    await firebase.setCurrentScreen(screenName: screenName);
  }

  Future<void> setUserProperty(
      {@required String name, @required String value}) async {
    await firebase.setUserProperty(name: name, value: value);
  }
}

void logEvent(Event event, {Map<String, String> parameters = const {}}) {
  getAnalytics().log(e: event, parameters: parameters);
  Log.d("Event $event");
}

class AnalyticsRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  void _sendScreenView(PageRoute<dynamic> route) async {
    var screenName = route.settings.name;
    if (route.runtimeType.toString().startsWith("_SearchPageRoute")) {
      screenName = "/search";
    }

    if (screenName == null) {
      screenName = 'Unknown';
      return;
    }

    try {
      await getAnalytics().setCurrentScreen(screenName: screenName);
    } catch (e, stackTrace) {
      Log.e("AnalyticsRouteObserver", ex: e, stacktrace: stackTrace);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _sendScreenView(route);
    } else {
      // print("route in not a PageRoute! $route");
    }
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _sendScreenView(newRoute);
    } else {
      // print("newRoute in not a PageRoute! $newRoute");
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);
    } else {
      // print("previousRoute in not a PageRoute! $previousRoute");
      // print("route in not a PageRoute! $route");
    }
  }
}
