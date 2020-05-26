import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gitjournal/app.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
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
  FolderAdded,
  FolderDeleted,
  FolderRenamed,
  FolderConfigUpdated,
  RepoSynced,
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
  }

  return "unknown_event";
}

class Analytics {
  var firebase = FirebaseAnalytics();
  bool enabled = false;

  Future<void> logEvent({
    @required String name,
    Map<String, String> parameters,
  }) async {
    await firebase.logEvent(name: name, parameters: parameters);
    captureErrorBreadcrumb(name: name, parameters: parameters);
  }

  Future<void> log({
    @required Event e,
    Map<String, String> parameters,
  }) async {
    String name = _eventToString(e);
    await firebase.logEvent(name: name, parameters: parameters);
    captureErrorBreadcrumb(name: name, parameters: parameters);
  }

  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    this.enabled = enabled;
    return firebase.setAnalyticsCollectionEnabled(enabled);
  }
}

void logEvent(Event event, {Map<String, String> parameters}) {
  getAnalytics().log(e: event, parameters: parameters);
  Log.d("Event $event");
}

class CustomRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  void _sendScreenView(PageRoute<dynamic> route) {
    final String screenName = route.settings.name;
    assert(screenName != null, "Screen name is null $route");
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _sendScreenView(route);
    } else {
      print("route in not a PageRoute! $route");
    }
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _sendScreenView(newRoute);
    } else {
      print("newRoute in not a PageRoute! $newRoute");
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);
    } else {
      print("previousRoute in not a PageRoute! $previousRoute");
      print("route in not a PageRoute! $route");
    }
  }
}
