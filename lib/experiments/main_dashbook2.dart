import 'package:flutter/material.dart';

import 'package:dashbook/dashbook.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/logger/fakes/debug_screen_fake.dart';
import 'package:gitjournal/logger/fakes/fake_path_provider.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/app_settings.dart';
import 'package:gitjournal/setup/fakes/clone_fake.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Log.init();

  PathProviderPlatform.instance = await FakePathProviderPlatform.init();

  final dashbook = Dashbook();

  var pref = await SharedPreferences.getInstance();

  AppSettings.instance.load(pref);

  var appSettings = AppSettings.instance;
  Log.i("AppSetting ${appSettings.toMap()}");

  dashbook.storiesOf('Setup').decorator(CenterDecorator()).add(
    'clone',
    (context) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: FakeTransferProgress(),
      );
    },
  );

  dashbook.storiesOf('Settings').decorator(CenterDecorator()).add(
        'Debug Screen',
        (context) => const DebugScreenFake(),
      );

  runApp(dashbook);
}
