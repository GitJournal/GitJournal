/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:function_types/function_types.dart';
import 'package:git_setup/screens.dart';
import 'package:gitjournal/account/account_screen.dart';
import 'package:gitjournal/account/login_screen.dart';
import 'package:gitjournal/core/markdown/md_yaml_doc_codec.dart';
import 'package:gitjournal/editors/note_editor.dart';
import 'package:gitjournal/folder_listing/view/folder_listing.dart';
import 'package:gitjournal/iap/purchase_screen.dart';
import 'package:gitjournal/iap/purchase_thankyou_screen.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/screens/error_screen.dart';
import 'package:gitjournal/screens/home_screen.dart';
import 'package:gitjournal/screens/onboarding_screens.dart';
import 'package:gitjournal/screens/tag_listing.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/settings_screen.dart';
import 'package:gitjournal/settings/storage_config.dart';
import 'package:gitjournal/utils/utils.dart';
import 'package:gitjournal/widgets/setup.dart';

class AppRoute {
  static const NewNotePrefix = '/newNote/';

  static const all = [
    OnBoardingScreen.routePath,
    FolderListingScreen.routePath,
    TagListingScreen.routePath,
    SettingsScreen.routePath,
    LoginPage.routePath,
    AccountScreen.routePath,
    GitHostSetupScreen.routePath,
    PurchaseScreen.routePath,
    PurchaseThankYouScreen.routePath,
    ErrorScreen.routePath,
  ];
}

class AppRouter {
  final AppConfig appConfig;
  final Settings settings;
  final StorageConfig storageConfig;

  AppRouter({
    required this.appConfig,
    required this.settings,
    required this.storageConfig,
  });

  String initialRoute() {
    var route = '/';
    if (!appConfig.onBoardingCompleted) {
      route = OnBoardingScreen.routePath;
    }
    if (settings.homeScreen == SettingsHomeScreen.AllFolders) {
      route = FolderListingScreen.routePath;
    }
    return route;
  }

  Route<dynamic> generateRoute(
    RouteSettings routeSettings,
    GitJournalRepo repository,
    String sharedText,
    List<String> sharedImages,
    Func0<void> callbackIfUsedShared,
  ) {
    var route = routeSettings.name ?? "";
    if (route == FolderListingScreen.routePath ||
        route == TagListingScreen.routePath ||
        route.startsWith(AppRoute.NewNotePrefix)) {
      return PageRouteBuilder(
        settings: routeSettings,
        pageBuilder: (_, __, ___) => screenForRoute(
          route,
          repository,
          storageConfig,
          sharedText,
          sharedImages,
          callbackIfUsedShared,
        )!,
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      );
    }

    return MaterialPageRoute(
      settings: routeSettings,
      builder: (context) => screenForRoute(
        route,
        repository,
        storageConfig,
        sharedText,
        sharedImages,
        callbackIfUsedShared,
      )!,
    );
  }

  Widget? screenForRoute(
    String route,
    GitJournalRepo repository,
    StorageConfig storageConfig,
    String sharedText,
    List<String> sharedImages,
    Func0<void> callbackIfUsedShared,
  ) {
    switch (route) {
      case HomeScreen.routePath:
        return HomeScreen();
      case FolderListingScreen.routePath:
        return FolderListingScreen();
      case TagListingScreen.routePath:
        return const TagListingScreen();
      case SettingsScreen.routePath:
        return SettingsScreen();
      case LoginPage.routePath:
        return const LoginPage();
      case AccountScreen.routePath:
        return const AccountScreen();
      case GitHostSetupScreen.routePath:
        return GitJournalGitSetupScreen(
          repoFolderName: storageConfig.folderName,
          onCompletedFunction: repository.completeGitHostSetup,
        );
      case OnBoardingScreen.routePath:
        return const OnBoardingScreen();
      case PurchaseScreen.routePath:
        return PurchaseScreen();
      case PurchaseThankYouScreen.routePath:
        return PurchaseThankYouScreen();
      case ErrorScreen.routePath:
        return const ErrorScreen();
    }

    if (route.startsWith(AppRoute.NewNotePrefix)) {
      var type = route.substring(AppRoute.NewNotePrefix.length);
      var et = SettingsEditorType.fromInternalString(type).toEditorType();

      Log.i("New Note - $route");
      Log.i("EditorType: $et");

      var rootFolder = repository.rootFolder;

      var extraProps = <String, dynamic>{};
      if (settings.customMetaData.isNotEmpty) {
        var map = MarkdownYAMLCodec.parseYamlText(settings.customMetaData);
        map.forEach((key, val) {
          extraProps[key] = val;
        });
      }

      callbackIfUsedShared();

      var folder = getFolderForEditor(settings, rootFolder, et);
      return NoteEditor.newNote(
        folder,
        folder,
        et,
        existingText: sharedText,
        existingImages: sharedImages,
        newNoteExtraProps: extraProps,
      );
    }

    assert(false, "Not found named route in screenForRoute");
    return null;
  }
}
