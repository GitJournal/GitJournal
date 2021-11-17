/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:dashbook/dashbook.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/app_router.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:gitjournal/settings/app_config.dart';

Future<void> main() async {
  //TestWidgetsFlutterBinding.ensureInitialized();
  var _ = WidgetsFlutterBinding.ensureInitialized();

  final dashbook = Dashbook();

  await EasyLocalization.ensureInitialized();

  // SharedPreferences.setMockInitialValues({});

  var pref = await SharedPreferences.getInstance();

  AppConfig.instance.load(pref);

  var appConfig = AppConfig.instance;
  Log.i("AppConfig ${appConfig.toMap()}");

  final gitBaseDirectory = (await getTemporaryDirectory()).path;
  final cacheDir = (await getTemporaryDirectory()).path;

  var repoManager = RepositoryManager(
    gitBaseDir: gitBaseDirectory,
    cacheDir: cacheDir,
    pref: pref,
  );
  var repo = await repoManager.buildActiveRepository();
  var settings = repo.settings;
  var storageConfig = repo.storageConfig;
  var appRouter = AppRouter(
      settings: settings, appConfig: appConfig, storageConfig: storageConfig);

  for (var routeName in AppRoute.all) {
    var _ = dashbook
        .storiesOf(routeName)
        .decorator(CenterDecorator())
        .add('all', (context) {
      return appRouter.screenForRoute(
          routeName, repo, storageConfig, "", [], () {})!;
    });
  }

  runApp(dashbook);
}
