import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:device_info/device_info.dart';
import 'package:package_info/package_info.dart';
import 'package:sentry/sentry.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:stack_trace/stack_trace.dart';

import 'package:gitjournal/.env.dart';
import 'package:gitjournal/app.dart';
import 'package:gitjournal/settings/app_settings.dart';
import 'package:gitjournal/utils/logger.dart';

Future<void> initSentry() async {
  if (Sentry.isEnabled) {
    return;
  }
  await SentryFlutter.init(
    (options) {
      options.dsn = environment['sentry'];
    },
  );
}

Future<SentryEvent> get _environmentEvent async {
  final packageInfo = await PackageInfo.fromPlatform();
  final deviceInfoPlugin = DeviceInfoPlugin();
  SentryOperatingSystem? os;
  SentryDevice? device;
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfoPlugin.androidInfo;
    os = SentryOperatingSystem(
      name: 'android',
      version: androidInfo.version.release,
    );
    device = SentryDevice(
      model: androidInfo.model,
      manufacturer: androidInfo.manufacturer,
      modelId: androidInfo.product,
    );
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfoPlugin.iosInfo;
    os = SentryOperatingSystem(
      name: iosInfo.systemName,
      version: iosInfo.systemVersion,
    );
    device = SentryDevice(
      model: iosInfo.utsname.machine,
      family: iosInfo.model,
      manufacturer: 'Apple',
    );
  }
  final environment = SentryEvent(
    release: '${packageInfo.version} (${packageInfo.buildNumber})',
    contexts: Contexts(
      operatingSystem: os,
      device: device,
      app: SentryApp(
        name: packageInfo.appName,
        version: packageInfo.version,
        build: packageInfo.buildNumber,
      ),
    ),
    user: SentryUser(
      id: AppSettings.instance.pseudoId,
    ),
  );
  return environment;
}

void flutterOnErrorHandler(FlutterErrorDetails details) {
  if (reportCrashes == true) {
    // vHanda: This doesn't always call our zone error handler, why?
    // Zone.current.handleUncaughtError(details.exception, details.stack);
    reportError(details.exception, details.stack ?? StackTrace.current);
  } else {
    FlutterError.dumpErrorToConsole(details);
  }
}

bool get reportCrashes => _reportCrashes ??= _initReportCrashes();
bool? _reportCrashes;
bool _initReportCrashes() {
  return !JournalApp.isInDebugMode && AppSettings.instance.collectCrashReports;
}

Future<void> reportError(dynamic error, StackTrace stackTrace) async {
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

  await captureSentryException(e, stackTrace, level: SentryLevel.warning);
}

List<Breadcrumb> breadcrumbs = [];

void captureErrorBreadcrumb({
  required String name,
  required Map<String, String> parameters,
}) {
  if (!reportCrashes) {
    return;
  }

  var b = Breadcrumb(
    message: name,
    timestamp: DateTime.now(),
    data: parameters,
  );
  breadcrumbs.add(b);
}

Future<void> captureSentryException(
  dynamic exception,
  StackTrace stackTrace, {
  SentryLevel level = SentryLevel.error,
}) async {
  try {
    await initSentry();
    final event = (await _environmentEvent).copyWith(
      throwable: exception,
      breadcrumbs: breadcrumbs,
      level: level,
    );

    await Sentry.captureEvent(event, stackTrace: Trace.from(stackTrace).terse);
    return;
  } catch (e) {
    print("Failed to report with Sentry: $e");
  }
}
