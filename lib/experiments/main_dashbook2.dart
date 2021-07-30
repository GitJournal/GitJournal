import 'package:flutter/material.dart';

import 'package:dashbook/dashbook.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/settings/app_settings.dart';
import 'package:gitjournal/setup/fakes/clone_fake.dart';
import 'package:gitjournal/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

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

  runApp(dashbook);
}
