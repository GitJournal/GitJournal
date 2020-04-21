import 'package:flutter/foundation.dart';

import 'package:gitjournal/app.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

Analytics getAnalytics() {
  return JournalApp.analytics;
}

class Analytics {
  FirebaseAnalytics firebase;

  Future<void> logEvent({
    @required String name,
    Map<String, dynamic> parameters,
  }) async {
    return firebase.logEvent(name: name, parameters: parameters);
  }

  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    return firebase.setAnalyticsCollectionEnabled(enabled);
  }
}
