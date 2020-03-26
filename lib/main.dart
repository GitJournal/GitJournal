import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;

import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:sentry/sentry.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/app.dart';
import 'package:gitjournal/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var pref = await SharedPreferences.getInstance();
  Settings.instance.load(pref);

  JournalApp.isInDebugMode = foundation.kDebugMode;
  var reportCrashes =
      !JournalApp.isInDebugMode && Settings.instance.collectCrashReports;

  FlutterError.onError = (FlutterErrorDetails details) {
    if (!reportCrashes) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  print("Report Crashes: $reportCrashes");
  if (reportCrashes) {
    await FlutterCrashlytics().initialize();
  }

  var sentry = SentryClient(
    dsn: 'https://35f34dbec289435fbe16483faacf49a5@sentry.io/5168082',
  );

  runZoned<Future<void>>(() async {
    await JournalApp.main(pref);
  }, onError: (Object error, StackTrace stackTrace) async {
    print("Uncaught Exception: " + error.toString());
    print(stackTrace);
    FlutterCrashlytics().reportCrash(error, stackTrace, forceCrash: false);
    sentry.captureException(
      exception: error,
      stackTrace: stackTrace,
    );
  });
}
