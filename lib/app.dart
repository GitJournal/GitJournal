import 'package:flutter/material.dart';
import 'package:journal/state_container.dart';
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
    final stateContainer = StateContainer.of(context);

    var onBoardingDone = stateContainer.appState.onBoardingCompleted;
    var markOnBoardingCompleted = () {
      stateContainer.completeOnBoarding();
      analytics.logEvent(name: "onboarding_complete");
    };
    var home = onBoardingDone
        ? new HomeScreen()
        : new OnBoardingScreen(markOnBoardingCompleted);

    return new MaterialApp(
      title: 'GitJournal',
      home: home,
      theme: new ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF66bb6a),
        primaryColorLight: Color(0xFF98ee99),
        primaryColorDark: Color(0xFF338a3e),
        accentColor: Color(0xff6d4c41),
      ),
      navigatorObservers: <NavigatorObserver>[observer],
    );
  }
}
