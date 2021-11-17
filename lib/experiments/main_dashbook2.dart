/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:dashbook/dashbook.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/logger/fakes/debug_screen_fake.dart';
import 'package:gitjournal/logger/fakes/fake_path_provider.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:gitjournal/setup/fakes/clone_fake.dart';

Future<void> main() async {
  dynamic _;
  _ = WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  PathProviderPlatform.instance = await FakePathProviderPlatform.init();
  await Log.init();

  final dashbook = Dashbook();

  var pref = await SharedPreferences.getInstance();

  AppConfig.instance.load(pref);

  var appConfig = AppConfig.instance;
  Log.i("AppConfig ${appConfig.toMap()}");

  _ = dashbook
      .storiesOf('Settings')
      .add('Debug Screen', (context) => const DebugScreenFake());

  _ = dashbook.storiesOf('Setup').decorator(CenterDecorator()).add(
    'clone',
    (context) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: FakeTransferProgress(),
      );
    },
  );

  var app = ChangeNotifierProvider.value(
    value: appConfig,
    child: dashbook,
  );

  runApp(app);
}
