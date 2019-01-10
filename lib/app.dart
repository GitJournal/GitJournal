import 'package:flutter/material.dart';
import 'package:journal/screens/home_screen.dart';
import 'package:journal/screens/onboarding_screens.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class JournalApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    var onBoardingDone = false;
    var home = onBoardingDone ? new HomeScreen() : new OnBoardingScreen();

    return new MaterialApp(
      title: 'Journal',
      home: home,
      theme: new ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.lightBlue[800],
        accentColor: Colors.cyan[600],
      ),
      navigatorObservers: <NavigatorObserver>[observer],
    );
  }
}
