import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:gitjournal/app.dart';
import 'package:gitjournal/settings.dart';
import 'package:package_info/package_info.dart';
import 'package:sentry/sentry.dart';

import 'package:gitjournal/.env.dart';

SentryClient _sentryClient;
Future<SentryClient> _initSentry() async {
  return SentryClient(
    dsn: environment['sentry'],
    environmentAttributes: await _environmentEvent,
  );
}

Future<SentryClient> getSentryClient() async {
  return _sentryClient ??= await _initSentry();
}

Future<Event> get _environmentEvent async {
  final packageInfo = await PackageInfo.fromPlatform();
  final deviceInfoPlugin = DeviceInfoPlugin();
  OperatingSystem os;
  Device device;
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfoPlugin.androidInfo;
    os = OperatingSystem(
      name: 'android',
      version: androidInfo.version.release,
    );
    device = Device(
      model: androidInfo.model,
      manufacturer: androidInfo.manufacturer,
      modelId: androidInfo.product,
    );
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfoPlugin.iosInfo;
    os = OperatingSystem(
      name: iosInfo.systemName,
      version: iosInfo.systemVersion,
    );
    device = Device(
      model: iosInfo.utsname.machine,
      family: iosInfo.model,
      manufacturer: 'Apple',
    );
  }
  final environment = Event(
    release: '${packageInfo.version} (${packageInfo.buildNumber})',
    contexts: Contexts(
      operatingSystem: os,
      device: device,
      app: App(
        name: packageInfo.appName,
        version: packageInfo.version,
        build: packageInfo.buildNumber,
      ),
    ),
  );
  return environment;
}

void flutterOnErrorHandler(FlutterErrorDetails details) {
  if (reportCrashes == true) {
    // vHanda: This doesn't always call our zone error handler, why?
    // Zone.current.handleUncaughtError(details.exception, details.stack);
    reportError(details.exception, details.stack);
  } else {
    FlutterError.dumpErrorToConsole(details);
  }
}

bool get reportCrashes => _reportCrashes ??= _initReportCrashes();
bool _reportCrashes;
bool _initReportCrashes() {
  return !JournalApp.isInDebugMode && Settings.instance.collectCrashReports;
}

Future<FlutterCrashlytics> getCrashlyticsClient() async {
  return _crashlytics ??= await _initCrashlytics();
}

FlutterCrashlytics _crashlytics;
Future<FlutterCrashlytics> _initCrashlytics() async {
  await FlutterCrashlytics().initialize();
  return FlutterCrashlytics();
}

Future<void> reportError(Object error, StackTrace stackTrace) async {
  if (reportCrashes) {
    try {
      final sentry = await getSentryClient();
      sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    } catch (e) {
      print("Failed to report with Sentry: $e");
    }

    try {
      final crashlytics = await getCrashlyticsClient();
      crashlytics.reportCrash(error, stackTrace, forceCrash: false);
    } catch (e) {
      print("Failed to report with Crashlytics: $e");
    }
  }

  print("Uncaught Exception: $error");
  print(stackTrace);
}
