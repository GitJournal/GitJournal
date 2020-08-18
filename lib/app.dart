import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';

import 'package:dart_git/git.dart';
import 'package:device_info/device_info.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter_sentry/flutter_sentry.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/appstate.dart';
import 'package:gitjournal/core/md_yaml_doc_codec.dart';
import 'package:gitjournal/iap.dart';
import 'package:gitjournal/screens/filesystem_screen.dart';
import 'package:gitjournal/screens/folder_listing.dart';
import 'package:gitjournal/screens/note_editor.dart';
import 'package:gitjournal/screens/purchase_screen.dart';
import 'package:gitjournal/screens/purchase_thankyou_screen.dart';
import 'package:gitjournal/screens/tag_listing.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/themes.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/utils/logger.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screens.dart';
import 'screens/settings_screen.dart';
import 'setup/screens.dart';

class JournalApp extends StatefulWidget {
  final AppState appState;

  static Future main(SharedPreferences pref) async {
    await Log.init();

    var appState = AppState(pref);
    appState.dumpToLog();

    var settings = Settings.instance;
    Log.i("Setting ${settings.toLoggableMap()}");

    if (settings.collectUsageStatistics) {
      _enableAnalyticsIfPossible(settings);
    }

    if (appState.gitBaseDirectory.isEmpty) {
      var dir = await getApplicationDocumentsDirectory();
      appState.gitBaseDirectory = dir.path;
      appState.save(pref);
    }

    if (!Directory(appState.gitBaseDirectory).existsSync()) {
      Log.w("Applications Documents Directory no longer exists");
      var dir = await getApplicationDocumentsDirectory();
      appState.gitBaseDirectory = dir.path;
      appState.save(pref);
      Log.i("New Documents Directory Path ${dir.path}");
    }

    if (appState.localGitRepoConfigured == false) {
      // FIXME: What about exceptions!
      appState.localGitRepoFolderName = "journal_local";
      var repoPath = p.join(
        appState.gitBaseDirectory,
        appState.localGitRepoFolderName,
      );
      await GitRepository.init(repoPath);

      appState.localGitRepoConfigured = true;
      appState.save(pref);
    }

    var app = ChangeNotifierProvider.value(
      value: settings,
      child: ChangeNotifierProvider(
        create: (_) {
          return StateContainer(appState);
        },
        child: ChangeNotifierProvider(
          child: JournalApp(appState),
          create: (_) {
            assert(appState.notesFolder != null);
            return appState.notesFolder;
          },
        ),
      ),
    );

    InAppPurchases.confirmProPurchaseBoot();

    runApp(EasyLocalization(
      child: app,
      supportedLocales: [
        const Locale('en', 'US'),
      ], // Remember to update Info.plist
      path: 'assets/langs',
      useOnlyLangCode: true,
      assetLoader: YamlAssetLoader(),
    ));
  }

  static void _enableAnalyticsIfPossible(Settings settings) async {
    JournalApp.isInDebugMode = foundation.kDebugMode;

    var isPhysicalDevice = true;
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        var info = await deviceInfo.androidInfo;
        isPhysicalDevice = info.isPhysicalDevice;
        Log.d("Device Fingerprint: " + info.fingerprint);
      } else if (Platform.isIOS) {
        var info = await deviceInfo.iosInfo;
        isPhysicalDevice = info.isPhysicalDevice;
      }
    } catch (e) {
      Log.d(e);
    }

    if (isPhysicalDevice == false) {
      JournalApp.isInDebugMode = true;
    }

    bool inFireBaseTestLab = await FlutterSentry.isFirebaseTestLab();
    bool enabled = !JournalApp.isInDebugMode && !inFireBaseTestLab;

    Log.d("Analytics Collection: $enabled");
    JournalApp.analytics.setAnalyticsCollectionEnabled(enabled);

    if (enabled) {
      logEvent(Event.Settings, parameters: settings.toLoggableMap());
    }
  }

  static final analytics = Analytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics.firebase);

  static bool isInDebugMode = false;

  JournalApp(this.appState);

  @override
  _JournalAppState createState() => _JournalAppState();
}

class _JournalAppState extends State<JournalApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  String _pendingShortcut;

  StreamSubscription _intentDataStreamSubscription;
  String _sharedText;
  List<String> _sharedImages;

  @override
  void initState() {
    super.initState();
    final QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      Log.i("Quick Action Open: $shortcutType");
      if (_navigatorKey.currentState == null) {
        Log.i("Quick Action delegating for after build");
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _afterBuild(context));
        setState(() {
          _pendingShortcut = shortcutType;
        });
        return;
      }
      _navigatorKey.currentState.pushNamed("/newNote/$shortcutType");
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      ShortcutItem(
        type: 'Markdown',
        localizedTitle: tr('actions.newNote'),
        icon: "ic_markdown",
      ),
      ShortcutItem(
        type: 'Checklist',
        localizedTitle: tr('actions.newChecklist'),
        icon: "ic_tasks",
      ),
      ShortcutItem(
        type: 'Journal',
        localizedTitle: tr('actions.newJournal'),
        icon: "ic_book",
      ),
    ]);

    _initShareSubscriptions();
  }

  void _afterBuild(BuildContext context) {
    if (_pendingShortcut != null) {
      _navigatorKey.currentState.pushNamed("/newNote/$_pendingShortcut");
      _pendingShortcut = null;
    }
  }

  void _initShareSubscriptions() {
    var handleShare = () {
      if (_sharedText == null && _sharedImages == null) {
        return;
      }

      var settings = Provider.of<Settings>(context, listen: false);
      var editor = settings.defaultEditor.toInternalString();
      _navigatorKey.currentState.pushNamed("/newNote/$editor");
    };

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      if (value == null) return;
      Log.d("Received Share $value");

      setState(() {
        _sharedImages = value.map((f) => f.path)?.toList();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => handleShare());
    }, onError: (err) {
      Log.e("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value == null) return;
      Log.d("Received Share with App running $value");

      setState(() {
        _sharedImages = value.map((f) => f.path)?.toList();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => handleShare());
    });

    // For sharing or opening text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      Log.d("Received Share $value");
      setState(() {
        _sharedText = value;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => handleShare());
    }, onError: (err) {
      Log.e("getLinkStream error: $err");
    });

    // For sharing or opening text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      Log.d("Received Share with App running $value");
      setState(() {
        _sharedText = value;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => handleShare());
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (b) => b == Brightness.light ? Themes.light : Themes.dark,
      themedWidgetBuilder: buildApp,
    );
  }

  MaterialApp buildApp(BuildContext context, ThemeData themeData) {
    var stateContainer = Provider.of<StateContainer>(context);
    var settings = Provider.of<Settings>(context);

    var initialRoute = '/';
    if (!settings.onBoardingCompleted) {
      initialRoute = '/onBoarding';
    }
    if (settings.homeScreen == SettingsHomeScreen.AllFolders) {
      initialRoute = '/folders';
    }

    return MaterialApp(
      key: const ValueKey("App"),
      navigatorKey: _navigatorKey,
      title: 'GitJournal',

      localizationsDelegates: EasyLocalization.of(context).delegates,
      supportedLocales: EasyLocalization.of(context).supportedLocales,
      locale: EasyLocalization.of(context).locale,

      theme: themeData,
      navigatorObservers: <NavigatorObserver>[
        JournalApp.observer,
        CustomRouteObserver(),
      ],
      initialRoute: initialRoute,
      debugShowCheckedModeBanner: false,
      //debugShowMaterialGrid: true,
      onGenerateRoute: (routeSettings) {
        var route = routeSettings.name;
        if (route == '/folders' || route == '/tags' || route == '/filesystem') {
          return PageRouteBuilder(
            settings: routeSettings,
            pageBuilder: (_, __, ___) =>
                _screenForRoute(route, stateContainer, settings),
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
          ),
        );
      },
    );
  }

  Widget _screenForRoute(
    String route,
    StateContainer stateContainer,
    Settings settings,
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
      case '/settings':
        return SettingsScreen();
      case '/setupRemoteGit':
        return GitHostSetupScreen(
          "journal",
          stateContainer.completeGitHostSetup,
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

      var rootFolder = widget.appState.notesFolder;
      var sharedImages = _sharedImages;
      var sharedText = _sharedText;

      _sharedText = null;
      _sharedImages = null;

      Log.d("sharedText: $sharedText");
      Log.d("sharedImages: $sharedImages");

      var extraProps = <String, dynamic>{};
      if (settings.customMetaData.isNotEmpty) {
        var map = MarkdownYAMLCodec.parseYamlText(settings.customMetaData);
        map.forEach((key, val) {
          extraProps[key] = val;
        });
      }

      return NoteEditor.newNote(
        getFolderForEditor(settings, rootFolder, et),
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
