import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:flutter_crashlytics/flutter_crashlytics.dart';

const _platform = MethodChannel('gitjournal.io/git');

bool shouldIgnorePlatformException(PlatformException ex) {
  var msg = ex.message.toLowerCase();
  if (msg.contains("failed to resolve address for")) {
    return true;
  }
  if (msg.contains("failed to connect to")) {
    return true;
  }
  if (msg.contains("no address associated with hostname")) {
    return true;
  }
  if (msg.contains("failed to connect to")) {
    return true;
  }
  if (msg.contains("unauthorized")) {
    return true;
  }
  if (msg.contains("invalid credentials")) {
    return true;
  }
  if (msg.contains("failed to start ssh session")) {
    return true;
  }
  return false;
}

Future invokePlatformMethod(String method, [dynamic arguments]) async {
  try {
    return await _platform.invokeMethod(method, arguments);
  } on PlatformException catch (e, stacktrace) {
    if (!shouldIgnorePlatformException(e)) {
      await FlutterCrashlytics().logException(e, stacktrace);
    }
    throw e;
  }
}

///
/// This gives us the directory where all the git repos will be stored
///
Future<Directory> getGitBaseDirectory() async {
  final String path = await invokePlatformMethod('getBaseDirectory');
  if (path == null) {
    return null;
  }
  return Directory(path);
}
