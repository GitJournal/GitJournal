import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:journal/screens/home_screen.dart';
import 'package:journal/screens/settings_screen.dart';
import 'package:journal/state_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/githostsetup_screens.dart';
import 'screens/onboarding_screens.dart';

class JournalApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  static bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  static SharedPreferences preferences;

  @override
  Widget build(BuildContext context) {
    var stateContainer = StateContainer.of(context);

    var initialRoute = '/';
    if (!stateContainer.appState.onBoardingCompleted) {
      initialRoute = '/onBoarding';
    }

    return MaterialApp(
      title: 'GitJournal',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF66bb6a),
        primaryColorLight: Color(0xFF98ee99),
        primaryColorDark: Color(0xFF338a3e),
        accentColor: Color(0xff6d4c41),
      ),
      navigatorObservers: <NavigatorObserver>[JournalApp.observer],
      initialRoute: initialRoute,
      routes: {
        '/': (context) => HomeScreen(),
        '/settings': (context) => SettingsScreen(),
        '/setupRemoteGit': (context) =>
            GitHostSetupScreen(stateContainer.completeGitHostSetup),
        '/onBoarding': (context) =>
            OnBoardingScreen(stateContainer.completeOnBoarding),
      },
      debugShowCheckedModeBanner: false,
      //debugShowMaterialGrid: true,
    );
  }
}
