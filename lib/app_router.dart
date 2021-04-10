// @dart=2.9

import 'package:flutter/material.dart';

import 'package:meta/meta.dart';

import 'package:gitjournal/app_settings.dart';
import 'package:gitjournal/core/md_yaml_doc_codec.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/screens/filesystem_screen.dart';
import 'package:gitjournal/screens/folder_listing.dart';
import 'package:gitjournal/screens/graph_view.dart';
import 'package:gitjournal/screens/home_screen.dart';
import 'package:gitjournal/screens/login_screen.dart';
import 'package:gitjournal/screens/note_editor.dart';
import 'package:gitjournal/screens/onboarding_screens.dart';
import 'package:gitjournal/screens/purchase_screen.dart';
import 'package:gitjournal/screens/purchase_thankyou_screen.dart';
import 'package:gitjournal/screens/settings_screen.dart';
import 'package:gitjournal/screens/signup_screen.dart';
import 'package:gitjournal/screens/tag_listing.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/setup/screens.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/utils/logger.dart';

class AppRouter {
  final AppSettings appSettings;
  final Settings settings;

  AppRouter({@required this.appSettings, @required this.settings});

  String initialRoute() {
    var route = '/';
    if (!appSettings.onBoardingCompleted) {
      route = '/onBoarding';
    }
    if (settings.homeScreen == SettingsHomeScreen.AllFolders) {
      route = '/folders';
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
    var route = routeSettings.name;
    if (route == '/folders' || route == '/tags' || route == '/filesystem') {
      return PageRouteBuilder(
        settings: routeSettings,
        pageBuilder: (_, __, ___) => _screenForRoute(
          route,
          repository,
          settings,
          sharedText,
          sharedImages,
          callbackIfUsedShared,
        ),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      );
    }

    return MaterialPageRoute(
      settings: routeSettings,
      builder: (context) => _screenForRoute(
        route,
        repository,
        settings,
        sharedText,
        sharedImages,
        callbackIfUsedShared,
      ),
    );
  }

  Widget _screenForRoute(
    String route,
    GitJournalRepo repository,
    Settings settings,
    String sharedText,
    List<String> sharedImages,
    Function callbackIfUsedShared,
  ) {
    switch (route) {
      case '/':
        return HomeScreen();
      case '/folders':
        return FolderListingScreen();
      case '/filesystem':
        return FileSystemScreen();
      case '/tags':
        return TagListingScreen();
      case '/graph':
        return GraphViewScreen();
      case '/settings':
        return SettingsScreen();
      case '/login':
        return LoginPage();
      case '/register':
        return SignUpScreen();
      case '/setupRemoteGit':
        return GitHostSetupScreen(
          repoFolderName: settings.folderName,
          remoteName: "origin",
          onCompletedFunction: repository.completeGitHostSetup,
        );
      case '/onBoarding':
        return OnBoardingScreen();
      case '/purchase':
        return PurchaseScreen();
      case '/purchase_thank_you':
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

    assert(false, "Not found named route in _screenForRoute");
    return null;
  }
}
