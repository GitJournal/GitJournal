import 'package:flutter/material.dart';

import 'package:meta/meta.dart';

import 'package:gitjournal/app_settings.dart';
import 'package:gitjournal/core/md_yaml_doc_codec.dart';
import 'package:gitjournal/screens/filesystem_screen.dart';
import 'package:gitjournal/screens/folder_listing.dart';
import 'package:gitjournal/screens/graph_view.dart';
import 'package:gitjournal/screens/home_screen.dart';
import 'package:gitjournal/screens/note_editor.dart';
import 'package:gitjournal/screens/onboarding_screens.dart';
import 'package:gitjournal/screens/purchase_screen.dart';
import 'package:gitjournal/screens/purchase_thankyou_screen.dart';
import 'package:gitjournal/screens/settings_screen.dart';
import 'package:gitjournal/screens/tag_listing.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/setup/screens.dart';
import 'package:gitjournal/state_container.dart';
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
    StateContainer stateContainer,
    String sharedText,
    List<String> sharedImages,
  ) {
    var route = routeSettings.name;
    if (route == '/folders' || route == '/tags' || route == '/filesystem') {
      return PageRouteBuilder(
        settings: routeSettings,
        pageBuilder: (_, __, ___) => _screenForRoute(
          route,
          stateContainer,
          settings,
          sharedText,
          sharedImages,
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
        stateContainer,
        settings,
        sharedText,
        sharedImages,
      ),
    );
  }

  Widget _screenForRoute(
    String route,
    StateContainer stateContainer,
    Settings settings,
    String sharedText,
    List<String> sharedImages,
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
      case '/setupRemoteGit':
        return GitHostSetupScreen(
          repoFolderName: settings.folderName,
          remoteName: "origin",
          onCompletedFunction: stateContainer.completeGitHostSetup,
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

      var rootFolder = stateContainer.appState.notesFolder;

      sharedText = null;
      sharedImages = null;

      Log.d("sharedText: $sharedText");
      Log.d("sharedImages: $sharedImages");

      var extraProps = <String, dynamic>{};
      if (settings.customMetaData.isNotEmpty) {
        var map = MarkdownYAMLCodec.parseYamlText(settings.customMetaData);
        map.forEach((key, val) {
          extraProps[key] = val;
        });
      }

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
