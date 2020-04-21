import 'package:flutter/foundation.dart';

import 'package:gitjournal/app.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

Analytics getAnalytics() {
  return JournalApp.analytics;
}

class Analytics {
  FirebaseAnalytics firebase;
  bool enabled = false;

  Future<void> logEvent({
    @required String name,
    Map<String, dynamic> parameters,
  }) async {
    await firebase.logEvent(name: name, parameters: parameters);
    captureErrorBreadcrumb(name: name, parameters: parameters);
  }

  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    this.enabled = enabled;
    return firebase.setAnalyticsCollectionEnabled(enabled);
  }
}
