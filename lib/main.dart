import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:journal/apis/git.dart';
import 'package:journal/app.dart';
import 'package:journal/settings.dart';
import 'package:journal/state_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (JournalApp.isInDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  if (!JournalApp.isInDebugMode) {
    await FlutterCrashlytics().initialize();
  }

  runZoned<Future<void>>(() async {
    await runJournalApp();
  }, onError: (Object error, StackTrace stackTrace) async {
    await FlutterCrashlytics()
        .reportCrash(error, stackTrace, forceCrash: false);
  });
}

Future runJournalApp() async {
  var pref = await SharedPreferences.getInstance();
  JournalApp.preferences = pref;

  var localGitRepoConfigured = pref.getBool("localGitRepoConfigured") ?? false;
  var remoteGitRepoConfigured =
      pref.getBool("remoteGitRepoConfigured") ?? false;
  var localGitRepoPath = pref.getString("localGitRepoPath") ?? "";
  var remoteGitRepoFolderName = pref.getString("remoteGitRepoPath") ?? "";
  var remoteGitRepoSubFolder = pref.getString("remoteGitRepoSubFolder") ?? "";
  var onBoardingCompleted =
      true; //pref.getBool("onBoardingCompleted") ?? false;

  if (JournalApp.isInDebugMode) {
    if (JournalApp.analytics.android != null) {
      JournalApp.analytics.android.setAnalyticsCollectionEnabled(false);
    }
  }

  if (localGitRepoConfigured == false) {
    // FIXME: What about exceptions!
    localGitRepoPath = "journal_local";
    await gitInit(localGitRepoPath);

    localGitRepoConfigured = true;

    await pref.setBool("localGitRepoConfigured", localGitRepoConfigured);
    await pref.setString("localGitRepoPath", localGitRepoPath);
  }

  var dir = await getGitBaseDirectory();

  await Settings.instance.load();

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
