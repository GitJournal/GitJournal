/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/foundation.dart';
import 'package:gitjournal/.env.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:universal_io/io.dart' show Platform;

Future<void> initSentry() async {
  if (Sentry.isEnabled) {
    return;
  }
  await SentryFlutter.init(
    (options) {
      options.dsn = Env.sentry;
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
  return !foundation.kDebugMode && AppConfig.instance.collectCrashReports;
}

Future<void> reportError(Object error, StackTrace stackTrace) async {
  assert(error is Exception || error is Error);
  Log.e("Uncaught Exception", ex: error, stacktrace: stackTrace);

  if (reportCrashes) {
    if (error is! Exception) {
      error = Exception("Error: $error");
    }
    _captureSentryException(error, stackTrace);
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

  await _captureSentryException(e, stackTrace);
}

Future<void> logExceptionWarning(Object e, StackTrace stackTrace) async {
  assert(e is Exception || e is Error);
  Log.e("Got Exception", ex: e, stacktrace: stackTrace);

  if (!reportCrashes) {
    return;
  }

  await _captureSentryException(e, stackTrace, level: SentryLevel.warning);
}

List<Breadcrumb> breadcrumbs = [];

void captureErrorBreadcrumb(String name, Map<String, String> parameters) {
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

Future<void> _captureSentryException(
  dynamic exception,
  StackTrace stackTrace, {
  SentryLevel level = SentryLevel.error,
}) async {
  if (exception == null) {
    return;
  }
  try {
    await initSentry();
    final event = (await _environmentEvent).copyWith(
      throwable: exception,
      breadcrumbs: breadcrumbs,
      level: level,
    );

    await Sentry.captureEvent(event, stackTrace: Trace.from(stackTrace).terse);
    return;
  } catch (e, st) {
    Log.e("Failed to report with Sentry:", ex: e, stacktrace: st);
  }
}
