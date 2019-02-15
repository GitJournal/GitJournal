import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:journal/app.dart';

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
    await JournalApp.main();
  }, onError: (Object error, StackTrace stackTrace) async {
    await FlutterCrashlytics()
        .reportCrash(error, stackTrace, forceCrash: false);
  });
}
