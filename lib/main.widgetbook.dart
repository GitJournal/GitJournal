/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:gitjournal/app_router.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/themes.dart';
import 'package:gitjournal/utils/result.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widgetbook/widgetbook.dart';

Future<void> main() async {
  //TestWidgetsFlutterBinding.ensureInitialized();
  var _ = WidgetsFlutterBinding.ensureInitialized();

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
  await repoManager.buildActiveRepository().getOrThrow();
  var repo = repoManager.currentRepo!;
  var settings = repo.settings;
  var storageConfig = repo.storageConfig;
  var appRouter = AppRouter(
    settings: settings,
    appConfig: appConfig,
    storageConfig: storageConfig,
  );

  var widgetBook = Widgetbook(
    localizationsDelegates: gitJournalLocalizationDelegates,
    supportedLocales: gitJournalSupportedLocales,
    categories: [
      WidgetbookCategory(
        name: 'Screens',
        widgets: [
          WidgetbookComponent(
            name: "All Components",
            isExpanded: true,
            useCases: [
              for (var routeName in AppRoute.all)
                WidgetbookUseCase(
                    name: routeName,
                    builder: (_) => appRouter.screenForRoute(
                        routeName, repo, storageConfig, "", [], () {})!),
            ],
          ),
        ],
      ),
    ],
    appInfo: AppInfo(name: 'GitJournal'),
    themes: [
      WidgetbookTheme(
        name: 'Light',
        data: Themes.fromName(DEFAULT_LIGHT_THEME_NAME),
      ),
      WidgetbookTheme(
        name: 'Dark',
        data: Themes.fromName(DEFAULT_DARK_THEME_NAME),
      ),
    ],
    devices: const [
      Apple.iPhone13Mini,
      Apple.iPhone11,
      Apple.iPhone8Plus,
      Samsung.s21ultra,
    ],
  );

  runApp(widgetBook);
}
