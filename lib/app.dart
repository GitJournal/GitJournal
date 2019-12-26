import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:fimber/fimber.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_runtime_env/flutter_runtime_env.dart' as runtime_env;

import 'package:git_bindings/git_bindings.dart';

import 'package:gitjournal/apis/git.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/appstate.dart';
import 'package:gitjournal/themes.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

import 'screens/githostsetup_screens.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screens.dart';
import 'screens/settings_screen.dart';

class JournalApp extends StatelessWidget {
  static Future main(SharedPreferences pref) async {
    Fimber.plantTree(DebugTree.elapsed(useColors: true));

    var appState = AppState(pref);
    appState.dumpToLog();

    if (Settings.instance.collectUsageStatistics) {
      _enableAnalyticsIfPossible();
    }

    var dir = await getGitBaseDirectory();
    appState.gitBaseDirectory = dir.path;

    if (appState.localGitRepoConfigured == false) {
      // FIXME: What about exceptions!
      appState.localGitRepoFolderName = "journal_local";
      var repoPath = p.join(dir.path, appState.localGitRepoFolderName);
      await GitRepo.init(repoPath);

      appState.localGitRepoConfigured = true;
      appState.save(pref);
    }

    runApp(StateContainer(
      appState: appState,
      child: ChangeNotifierProvider(
        child: JournalApp(),
        create: (_) {
          assert(appState.notesFolder != null);
          return appState.notesFolder;
        },
      ),
    ));
  }

  static void _enableAnalyticsIfPossible() async {
    JournalApp.isInDebugMode = runtime_env.isInDebugMode();

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
      JournalApp.isInDebugMode = true;
    }

    bool should = (JournalApp.isInDebugMode == false);
    should = should && (await runtime_env.inFirebaseTestLab());

    Fimber.d("Analytics Collection: $should");
    JournalApp.analytics.setAnalyticsCollectionEnabled(should);

    if (should) {
      JournalApp.analytics.logEvent(
        name: "settings",
        parameters: Settings.instance.toLoggableMap(),
      );
    }
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
      key: const ValueKey("App"),
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
