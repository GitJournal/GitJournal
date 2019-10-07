import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/app.dart';
import 'package:gitjournal/settings.dart';

void main() async {
  var pref = await SharedPreferences.getInstance();
  Settings.instance.load(pref);

  var reportCrashes =
      !JournalApp.isInDebugMode && Settings.instance.collectCrashReports;

  FlutterError.onError = (FlutterErrorDetails details) {
    if (!reportCrashes) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  if (reportCrashes) {
    await FlutterCrashlytics().initialize();
  }

  runZoned<Future<void>>(() async {
    await JournalApp.main(pref);
  }, onError: (Object error, StackTrace stackTrace) async {
    print("Uncaught Exception: " + error.toString());
    print(stackTrace);
    await FlutterCrashlytics()
        .reportCrash(error, stackTrace, forceCrash: false);
  });
}
