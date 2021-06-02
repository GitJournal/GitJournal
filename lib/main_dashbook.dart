import 'package:flutter/material.dart';

import 'package:dashbook/dashbook.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/app_router.dart';
import 'package:gitjournal/app_settings.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:gitjournal/utils/logger.dart';

void main() async {
  //TestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  final dashbook = Dashbook();

  await EasyLocalization.ensureInitialized();

  // SharedPreferences.setMockInitialValues({});

  var pref = await SharedPreferences.getInstance();

  AppSettings.instance.load(pref);

  var appSettings = AppSettings.instance;
  Log.i("AppSetting ${appSettings.toMap()}");

  final gitBaseDirectory = (await getTemporaryDirectory()).path;
  final cacheDir = (await getTemporaryDirectory()).path;

  var repoManager = RepositoryManager(
    gitBaseDir: gitBaseDirectory,
    cacheDir: cacheDir,
    pref: pref,
  );
  await repoManager.buildActiveRepository();
  var repo = repoManager.currentRepo;
  var settings = repo.settings;
  var appRouter = AppRouter(settings: settings, appSettings: appSettings);

  for (var routeName in AppRoute.all) {
    dashbook.storiesOf(routeName).decorator(CenterDecorator()).add('all',
        (context) {
      return appRouter.screenForRoute(
          routeName, repo, settings, null, null, () {})!;
    });
  }

  runApp(dashbook);
}
