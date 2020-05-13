import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/screens/folder_listing.dart';
import 'package:gitjournal/screens/note_editor.dart';
import 'package:gitjournal/screens/purchase_screen.dart';
import 'package:gitjournal/screens/purchase_thankyou_screen.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/utils/logger.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_runtime_env/flutter_runtime_env.dart' as runtime_env;

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';

import 'package:git_bindings/git_bindings.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'package:gitjournal/apis/git.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/appstate.dart';
import 'package:gitjournal/themes.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

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

    Log.i("Setting ${Settings.instance.toLoggableMap()}");

    if (Settings.instance.collectUsageStatistics) {
      _enableAnalyticsIfPossible();
    }

    if (appState.gitBaseDirectory.isEmpty) {
      var dir = await getGitBaseDirectory();
      appState.gitBaseDirectory = dir.path;
      appState.save(pref);
    }

    if (appState.localGitRepoConfigured == false) {
      // FIXME: What about exceptions!
      appState.localGitRepoFolderName = "journal_local";
      var repoPath = p.join(
        appState.gitBaseDirectory,
        appState.localGitRepoFolderName,
      );
      await GitRepo.init(repoPath);

      appState.localGitRepoConfigured = true;
      appState.save(pref);
    }

    var app = ChangeNotifierProvider(
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
    );

    runApp(EasyLocalization(
      child: app,
      supportedLocales: [const Locale('en', 'US')],
      path: 'assets/langs',
      useOnlyLangCode: true,
      assetLoader: YamlAssetLoader(),
    ));
  }

  static void _enableAnalyticsIfPossible() async {
    JournalApp.isInDebugMode = runtime_env.isInDebugMode();

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

    bool inFireBaseTestLab = await runtime_env.inFirebaseTestLab();
    bool enabled = !JournalApp.isInDebugMode && !inFireBaseTestLab;

    Log.d("Analytics Collection: $enabled");
    JournalApp.analytics.setAnalyticsCollectionEnabled(enabled);

    if (enabled) {
      JournalApp.analytics.logEvent(
        name: "settings",
        parameters: Settings.instance.toLoggableMap(),
      );
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
      ),
      ShortcutItem(
        type: 'Checklist',
        localizedTitle: tr('actions.newChecklist'),
      ),
      ShortcutItem(
        type: 'Journal',
        localizedTitle: tr('actions.newJournal'),
      ),
    ]);

    print("Nav key $_navigatorKey");

    _initShareSubscriptions();
  }

  void _afterBuild(BuildContext context) {
    print("_afterBuild $_pendingShortcut");
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

      var editor = Settings.instance.defaultEditor.toInternalString();
      _navigatorKey.currentState.pushNamed("/newNote/$editor");
    };

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      Log.d("Received Share $value");
      if (value == null) return;

      setState(() {
        _sharedImages = value.map((f) => f.path)?.toList();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => handleShare());
    }, onError: (err) {
      Log.e("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      Log.d("Received Share with App running $value");
      if (value == null) return;

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

    var initialRoute = '/';
    if (!stateContainer.appState.onBoardingCompleted) {
      initialRoute = '/onBoarding';
    }
    if (Settings.instance.homeScreen == SettingsHomeScreen.AllFolders) {
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
      navigatorObservers: <NavigatorObserver>[JournalApp.observer],
      initialRoute: initialRoute,
      debugShowCheckedModeBanner: false,
      //debugShowMaterialGrid: true,
      onGenerateRoute: (settings) {
        var route = settings.name;
        if (route == '/folders') {
          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (_, __, ___) => _screenForRoute(route, stateContainer),
            transitionsBuilder: (_, anim, __, child) {
              return FadeTransition(opacity: anim, child: child);
            },
          );
        }

        return MaterialPageRoute(
          settings: settings,
          builder: (context) => _screenForRoute(
            route,
            stateContainer,
          ),
        );
      },
    );
  }

  Widget _screenForRoute(String route, StateContainer stateContainer) {
    switch (route) {
      case '/':
        return HomeScreen();
      case '/folders':
        return FolderListingScreen();
      case '/settings':
        return SettingsScreen();
      case '/setupRemoteGit':
        return GitHostSetupScreen(stateContainer.completeGitHostSetup);
      case '/onBoarding':
        return OnBoardingScreen(stateContainer.completeOnBoarding);
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

      return NoteEditor.newNote(
        getFolderForEditor(rootFolder, et),
        et,
        existingText: sharedText,
        existingImages: sharedImages,
      );
    }

    assert(false, "Not found named route in _screenForRoute");
    return null;
  }
}
