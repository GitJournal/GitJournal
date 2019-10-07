import 'package:gitjournal/app.dart';

import 'package:firebase_analytics/firebase_analytics.dart';

FirebaseAnalytics getAnalytics() {
  return JournalApp.analytics;
}
