import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_trace/stack_trace.dart';

import 'package:gitjournal/app.dart';
import 'package:gitjournal/app_settings.dart';
import 'package:gitjournal/error_reporting.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  var pref = await SharedPreferences.getInstance();
  AppSettings.instance.load(pref);

  JournalApp.isInDebugMode = foundation.kDebugMode;
  FlutterError.onError = flutterOnErrorHandler;

  Isolate.current.addErrorListener(RawReceivePort((dynamic pair) async {
    var isolateError = pair as List<dynamic>;
    assert(isolateError.length == 2);
    assert(isolateError.first.runtimeType == Error);
    assert(isolateError.last.runtimeType == StackTrace);

    await reportError(isolateError.first, isolateError.last);
  }).sendPort);

  runZonedGuarded(() async {
    await Chain.capture(() async {
      await JournalApp.main(pref);
    });
  }, reportError);
}
