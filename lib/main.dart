import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';

import 'package:journal/app.dart';
import 'package:journal/state_container.dart';

void main() async {
  bool isInDebugMode = true;

  FlutterError.onError = (FlutterErrorDetails details) {
    if (isInDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  await FlutterCrashlytics().initialize();

  runZoned<Future<Null>>(() async {
    await runJournalApp();
  }, onError: (error, stackTrace) async {
    await FlutterCrashlytics()
        .reportCrash(error, stackTrace, forceCrash: false);
  });
}

Future runJournalApp() async {
  var pref = await SharedPreferences.getInstance();
  var onBoardingCompleted = pref.getBool("onBoardingCompleted") ?? false;

  runApp(new StateContainer(
    onBoardingCompleted: onBoardingCompleted,
    child: JournalApp(),
  ));
}
