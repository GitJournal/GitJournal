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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

import 'screens/githostsetup_screens.dart';
import 'screens/onboarding_screens.dart';

class JournalApp extends StatelessWidget {
  static Future main() async {
    Fimber.plantTree(DebugTree.elapsed(useColors: true));

    var pref = await SharedPreferences.getInstance();
    JournalApp.preferences = pref;

    var localGitRepoConfigured =
        pref.getBool("localGitRepoConfigured") ?? false;
    var remoteGitRepoConfigured =
        pref.getBool("remoteGitRepoConfigured") ?? false;
    var localGitRepoPath = pref.getString("localGitRepoPath") ?? "";
    var remoteGitRepoFolderName = pref.getString("remoteGitRepoPath") ?? "";
    var remoteGitRepoSubFolder = pref.getString("remoteGitRepoSubFolder") ?? "";
    var onBoardingCompleted = pref.getBool("onBoardingCompleted") ?? false;

    Fimber.d(" ---- Settings ---- ");
    Fimber.d("localGitRepoConfigured: $localGitRepoConfigured");
    Fimber.d("remoteGitRepoConfigured: $remoteGitRepoConfigured");
    Fimber.d("localGitRepoPath: $localGitRepoPath");
    Fimber.d("remoteGitRepoFolderName: $remoteGitRepoFolderName");
    Fimber.d("remoteGitRepoSubFolder: $remoteGitRepoSubFolder");
    Fimber.d("onBoardingCompleted: $onBoardingCompleted");
    Fimber.d(" ------------------ ");

    _enableAnalyticsIfPossible();

    if (localGitRepoConfigured == false) {
      // FIXME: What about exceptions!
      localGitRepoPath = "journal_local";
      await GitRepo.init(localGitRepoPath);

      localGitRepoConfigured = true;

      pref.setBool("localGitRepoConfigured", localGitRepoConfigured);
      pref.setString("localGitRepoPath", localGitRepoPath);
    }

    var dir = await getGitBaseDirectory();

    Settings.instance.load(pref);

    runApp(StateContainer(
      localGitRepoConfigured: localGitRepoConfigured,
      remoteGitRepoConfigured: remoteGitRepoConfigured,
      localGitRepoPath: localGitRepoPath,
      remoteGitRepoFolderName: remoteGitRepoFolderName,
      remoteGitRepoSubFolder: remoteGitRepoSubFolder,
      gitBaseDirectory: dir.path,
      onBoardingCompleted: onBoardingCompleted,
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
  static SharedPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) {
        if (brightness == Brightness.light) {
          return ThemeData(
            brightness: Brightness.light,
            primaryColor: Color(0xFF66bb6a),
            primaryColorLight: Color(0xFF98ee99),
            primaryColorDark: Color(0xFF338a3e),
            accentColor: Color(0xff6d4c41),
          );
        } else {
          return ThemeData(
            brightness: Brightness.dark,
            primaryColor: Color(0xFF66bb6a),
            primaryColorLight: Color(0xFF98ee99),
            primaryColorDark: Color(0xFF338a3e),
            accentColor: Color(0xff6d4c41),
          );
        }
      },
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
