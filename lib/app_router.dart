import 'package:flutter/material.dart';

import 'package:gitjournal/core/md_yaml_doc_codec.dart';
import 'package:gitjournal/iap/purchase_screen.dart';
import 'package:gitjournal/iap/purchase_thankyou_screen.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/screens/filesystem_screen.dart';
import 'package:gitjournal/screens/folder_listing.dart';
import 'package:gitjournal/screens/graph_view.dart';
import 'package:gitjournal/screens/home_screen.dart';
import 'package:gitjournal/screens/login_screen.dart';
import 'package:gitjournal/screens/note_editor.dart';
import 'package:gitjournal/screens/onboarding_screens.dart';
import 'package:gitjournal/screens/signup_screen.dart';
import 'package:gitjournal/screens/tag_listing.dart';
import 'package:gitjournal/settings/app_settings.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/settings_screen.dart';
import 'package:gitjournal/settings/storage_config.dart';
import 'package:gitjournal/setup/screens.dart';
import 'package:gitjournal/utils/logger.dart';
import 'package:gitjournal/utils/utils.dart';

class AppRoute {
  static const OnBoarding = '/onBoarding';
  static const AllFolders = '/folders';
  static const AllTags = '/tags';
  static const FileSystem = '/filesystem';
  static const Graph = '/graph';
  static const Settings = '/settings';
  static const Login = '/login';
  static const Register = '/register';
  static const SetupRemoteGit = '/setupRemoteGit';
  static const Purchase = '/purchase';
  static const PurchaseThank = '/purchase_thank_you';

  static const all = [
    OnBoarding,
    AllFolders,
    AllTags,
    FileSystem,
    Graph,
    Settings,
    Login,
    Register,
    SetupRemoteGit,
    Purchase,
    PurchaseThank,
  ];
}

class AppRouter {
  final AppSettings appSettings;
  final Settings settings;
  final StorageConfig storageConfig;

  AppRouter({
    required this.appSettings,
    required this.settings,
    required this.storageConfig,
  });

  String initialRoute() {
    var route = '/';
    if (!appSettings.onBoardingCompleted) {
      route = AppRoute.OnBoarding;
    }
    if (settings.homeScreen == SettingsHomeScreen.AllFolders) {
      route = AppRoute.AllFolders;
    }
    return route;
  }

  Route<dynamic> generateRoute(
    RouteSettings routeSettings,
    GitJournalRepo repository,
    String sharedText,
    List<String> sharedImages,
    Function callbackIfUsedShared,
  ) {
    var route = routeSettings.name ?? "";
    if (route == AppRoute.AllFolders ||
        route == AppRoute.AllTags ||
        route == AppRoute.FileSystem) {
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
    Function callbackIfUsedShared,
  ) {
    switch (route) {
      case '/':
        return HomeScreen();
      case AppRoute.AllFolders:
        return FolderListingScreen();
      case AppRoute.FileSystem:
        return FileSystemScreen();
      case AppRoute.AllTags:
        return TagListingScreen();
      case AppRoute.Graph:
        return GraphViewScreen();
      case AppRoute.Settings:
        return SettingsScreen();
      case AppRoute.Login:
        return LoginPage();
      case AppRoute.Register:
        return SignUpScreen();
      case AppRoute.SetupRemoteGit:
        return GitHostSetupScreen(
          repoFolderName: storageConfig.folderName,
          remoteName: "origin",
          onCompletedFunction: repository.completeGitHostSetup,
        );
      case AppRoute.OnBoarding:
        return OnBoardingScreen();
      case AppRoute.Purchase:
        return PurchaseScreen();
      case AppRoute.PurchaseThank:
        return PurchaseThankYouScreen();
    }

    if (route.startsWith('/newNote/')) {
      var type = route.substring('/newNote/'.length);
      var et = SettingsEditorType.fromInternalString(type).toEditorType();

      Log.i("New Note - $route");
      Log.i("EditorType: $et");

      var rootFolder = repository.notesFolder;

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
