import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';

import 'package:device_info/device_info.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:flutter_sentry/flutter_sentry.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/app_router.dart';
import 'package:gitjournal/app_settings.dart';
import 'package:gitjournal/iap.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/themes.dart';
import 'package:gitjournal/utils/logger.dart';

class JournalApp extends StatefulWidget {
  static Future main(SharedPreferences pref) async {
    await Log.init();

    var appSettings = AppSettings.instance;
    Log.i("AppSetting ${appSettings.toMap()}");

    if (appSettings.collectUsageStatistics) {
      _enableAnalyticsIfPossible(appSettings);
    }
    _sendAppUpdateEvent(appSettings);

    final gitBaseDirectory = (await getApplicationDocumentsDirectory()).path;
    final cacheDir = (await getApplicationSupportDirectory()).path;

    var repo = await Repository.load(
      gitBaseDir: gitBaseDirectory,
      cacheDir: cacheDir,
      pref: pref,
      id: DEFAULT_ID,
    );

    Widget app = ChangeNotifierProvider.value(
      value: repo,
      child: ChangeNotifierProvider.value(
        value: repo.settings,
        child: ChangeNotifierProvider.value(
          child: JournalApp(),
          value: repo.notesFolder,
        ),
      ),
    );

    app = ChangeNotifierProvider.value(
      value: appSettings,
      child: app,
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

  static void _enableAnalyticsIfPossible(AppSettings appSettings) async {
    JournalApp.isInDebugMode = foundation.kDebugMode;

    var isPhysicalDevice = true;
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        var info = await deviceInfo.androidInfo;
        isPhysicalDevice = info.isPhysicalDevice;
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
      getAnalytics().firebase.setUserProperty(
            name: 'proMode',
            value: appSettings.proMode.toString(),
          );

      getAnalytics().firebase.setUserProperty(
            name: 'proExpirationDate',
            value: appSettings.proExpirationDate.toString(),
          );
    }
  }

  static Future<void> _sendAppUpdateEvent(AppSettings appSettings) async {
    var info = await PackageInfo.fromPlatform();
    var version = info.version;

    if (appSettings.appVersion == version) {
      return;
    }

    logEvent(Event.AppUpdate, parameters: {
      "version": version,
      "previous_app_version": appSettings.appVersion,
      "app_name": info.appName,
      "package_name": info.packageName,
      "build_number": info.buildNumber,
    });

    appSettings.appVersion = version;
    appSettings.save();
  }

  static final analytics = Analytics();
  static bool isInDebugMode = false;

  JournalApp();

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
    var stateContainer = Provider.of<Repository>(context);
    var settings = Provider.of<Settings>(context);
    var appSettings = Provider.of<AppSettings>(context);
    var router = AppRouter(settings: settings, appSettings: appSettings);

    return MaterialApp(
      key: const ValueKey("App"),
      navigatorKey: _navigatorKey,
      title: 'GitJournal',

      localizationsDelegates: EasyLocalization.of(context).delegates,
      supportedLocales: EasyLocalization.of(context).supportedLocales,
      locale: EasyLocalization.of(context).locale,

      theme: themeData,
      navigatorObservers: <NavigatorObserver>[
        AnalyticsRouteObserver(),
      ],
      initialRoute: router.initialRoute(),
      debugShowCheckedModeBanner: false,
      //debugShowMaterialGrid: true,
      onGenerateRoute: (rs) =>
          router.generateRoute(rs, stateContainer, _sharedText, _sharedImages),
    );
  }
}
