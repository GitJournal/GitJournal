/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:gitjournal/app.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:gitjournal/utils/bloc_observer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_trace/stack_trace.dart';

void main() {
  Chain.capture(() async {
    await _main();
  });
}

Future<void> _main() async {
  BindingBase.debugZoneErrorsAreFatal = true;
  Bloc.observer = GlobalBlocObserver();

  WidgetsFlutterBinding.ensureInitialized();

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

  if (Platform.isIOS || Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }

  await JournalApp.main(pref);
}
