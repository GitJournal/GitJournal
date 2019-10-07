import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:fimber/fimber.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';

import 'package:journal/apis/git.dart';
import 'package:journal/screens/home_screen.dart';
import 'package:journal/screens/settings_screen.dart';
import 'package:journal/settings.dart';
import 'package:journal/state_container.dart';
import 'package:journal/utils.dart';
import 'package:journal/appstate.dart';
import 'package:journal/themes.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

import 'screens/githostsetup_screens.dart';
import 'screens/onboarding_screens.dart';

class JournalApp extends StatelessWidget {
  static Future main(SharedPreferences pref) async {
    Fimber.plantTree(DebugTree.elapsed(useColors: true));

    var appState = AppState(pref);
    appState.dumpToLog();

    if (Settings.instance.collectUsageStatistics) {
      _enableAnalyticsIfPossible();
    }

    if (appState.localGitRepoConfigured == false) {
      // FIXME: What about exceptions!
      appState.localGitRepoPath = "journal_local";
      await GitRepo.init(appState.localGitRepoPath);

      appState.localGitRepoConfigured = true;
      appState.save(pref);
    }

    var dir = await getGitBaseDirectory();
    appState.gitBaseDirectory = dir.path;

    runApp(StateContainer(
      appState: appState,
      child: JournalApp(),
    ));
  }

  static void _enableAnalyticsIfPossible() async {
    //
    // Check if in debugMode or not a real device
    //
    assert(JournalApp.isInDebugMode = true);

    var isPhysicalDevice = true;
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        var info = await deviceInfo.androidInfo;
        isPhysicalDevice = info.isPhysicalDevice;
      } else if (Platform.isIOS) {
        var info = await deviceInfo.iosInfo;
        isPhysicalDevice = info.isPhysicalDevice;
      }
    } catch (e) {
      Fimber.d(e);
    }

    if (isPhysicalDevice == false) {
      Fimber.d("Not running in a physcial device");
      JournalApp.isInDebugMode = true;
    }

    bool should = (JournalApp.isInDebugMode == false);
    should = should && (await shouldEnableAnalytics());

    Fimber.d("Analytics Collection: $should");
    JournalApp.analytics.setAnalyticsCollectionEnabled(should);
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  static bool isInDebugMode = false;

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (b) => b == Brightness.light ? Themes.light : Themes.dark,
      themedWidgetBuilder: buildApp,
    );
  }

  MaterialApp buildApp(BuildContext context, ThemeData themeData) {
    var stateContainer = StateContainer.of(context);

    var initialRoute = '/';
    if (!stateContainer.appState.onBoardingCompleted) {
      initialRoute = '/onBoarding';
    }

    return MaterialApp(
      key: ValueKey("App"),
      title: 'GitJournal',
      theme: themeData,
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
