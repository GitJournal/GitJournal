import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:device_info/device_info.dart';
import 'package:package_info/package_info.dart';
import 'package:sentry/sentry.dart';

import 'package:gitjournal/.env.dart';
import 'package:gitjournal/app.dart';
import 'package:gitjournal/app_settings.dart';
import 'package:gitjournal/utils/logger.dart';

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
    userContext: User(
      id: AppSettings.instance.pseudoId,
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
  return !JournalApp.isInDebugMode && AppSettings.instance.collectCrashReports;
}

Future<void> reportError(Object error, StackTrace stackTrace) async {
  Log.e("Uncaught Exception", ex: error, stacktrace: stackTrace);

  if (reportCrashes) {
    captureSentryException(error, stackTrace);
  }
}

// Dart makes a distiction between Errors and Exceptions
// so we need to use dynamic
Future<void> logException(Object e, StackTrace stackTrace) async {
  assert(e is Exception || e is Error);
  Log.e("Got Exception", ex: e, stacktrace: stackTrace);

  if (!reportCrashes) {
    return;
  }

  await captureSentryException(e, stackTrace);
}

Future<void> logExceptionWarning(Object e, StackTrace stackTrace) async {
  assert(e is Exception || e is Error);
  Log.e("Got Exception", ex: e, stacktrace: stackTrace);

  if (!reportCrashes) {
    return;
  }

  await captureSentryException(e, stackTrace, level: SeverityLevel.warning);
}

List<Breadcrumb> breadcrumbs = [];

void captureErrorBreadcrumb({
  @required String name,
  Map<String, String> parameters,
}) {
  var b = Breadcrumb(name, DateTime.now(), data: parameters);
  breadcrumbs.add(b);
}

Future<void> captureSentryException(
  Object exception,
  StackTrace stackTrace, {
  SeverityLevel level = SeverityLevel.error,
}) async {
  try {
    final sentry = await getSentryClient();
    final Event event = Event(
      exception: exception,
      stackTrace: stackTrace,
      breadcrumbs: breadcrumbs,
      level: level,
    );

    return sentry.capture(event: event);
  } catch (e) {
    print("Failed to report with Sentry: $e");
  }
}
