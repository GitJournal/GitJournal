/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_logger/easy_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_trace/stack_trace.dart';

import 'package:gitjournal/app.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/settings/app_config.dart';

Future<void> main() async {
  var _ = WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableLevels = [
    LevelMessages.error,
    LevelMessages.warning,
  ];

  var pref = await SharedPreferences.getInstance();
  AppConfig.instance.load(pref);

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
