import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';

import 'package:device_info/device_info.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:flutter_runtime_env/flutter_runtime_env.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/app_router.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/iap/iap.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:gitjournal/settings/app_settings.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/themes.dart';
import 'package:gitjournal/utils/logger.dart';

class JournalApp extends StatefulWidget {
  static Future main(SharedPreferences pref) async {
    await Log.init();

    Log.i("--------------------------------");
    Log.i("--------------------------------");
    Log.i("--------------------------------");
    Log.i("--------- App Launched ---------");
    Log.i("--------------------------------");
    Log.i("--------------------------------");
    Log.i("--------------------------------");

    var appSettings = AppSettings.instance;
    Log.i("AppSetting ${appSettings.toMap()}");

    if (appSettings.collectUsageStatistics) {
      _enableAnalyticsIfPossible(appSettings);
    }
    _sendAppUpdateEvent(appSettings);

    final gitBaseDirectory = (await getApplicationDocumentsDirectory()).path;
    final cacheDir = (await getApplicationSupportDirectory()).path;

    var repoManager = RepositoryManager(
      gitBaseDir: gitBaseDirectory,
      cacheDir: cacheDir,
      pref: pref,
    );
    await repoManager.buildActiveRepository();

    InAppPurchases.confirmProPurchaseBoot();

    runApp(EasyLocalization(
      child: GitJournalChangeNotifiers(
        repoManager: repoManager,
        appSettings: appSettings,
        child: JournalApp(),
      ),
      supportedLocales: [
        // Arranged Alphabetically
        const Locale('de'),
        const Locale('es'),
        const Locale('en', 'US'),
        const Locale('fr'),
        const Locale('hu'),
        const Locale('id'),
        const Locale('it'),
        const Locale('ja'),
        const Locale('ko'),
        const Locale('pl'),
        const Locale('pt', 'BR'),
        const Locale('ru'),
        const Locale('sv'),
        const Locale('vi'),
        const Locale('zh'),
      ], // Remember to update Info.plist
      fallbackLocale: const Locale('en', 'US'),
      useFallbackTranslations: true,
      path: 'assets/langs',
      useOnlyLangCode: true,
      assetLoader: YamlAssetLoader(),
    ));
  }

  static void _enableAnalyticsIfPossible(AppSettings appSettings) async {
    JournalApp.isInDebugMode = foundation.kDebugMode;

    var isPhysicalDevice = true;
    try {
      var deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        var info = await deviceInfo.androidInfo;
        isPhysicalDevice = info.isPhysicalDevice;

        Log.i("Running on Android", props: readAndroidBuildData(info));
      } else if (Platform.isIOS) {
        var info = await deviceInfo.iosInfo;
        isPhysicalDevice = info.isPhysicalDevice;

        Log.i("Running on ios", props: readIosDeviceInfo(info));
      }
    } catch (e) {
      Log.d(e.toString());
    }

    if (isPhysicalDevice == false) {
      JournalApp.isInDebugMode = true;
    }

    bool inFireBaseTestLab = await inFirebaseTestLab();
    bool enabled = !JournalApp.isInDebugMode && !inFireBaseTestLab;

    Log.d("Analytics Collection: $enabled");
    JournalApp.analytics.setAnalyticsCollectionEnabled(enabled);

    if (enabled) {
      getAnalytics().setUserProperty(
        name: 'proMode',
        value: appSettings.proMode.toString(),
      );

      getAnalytics().setUserProperty(
        name: 'proExpirationDate',
        value: appSettings.proExpirationDate.toString(),
      );
    }
  }

  static Future<void> _sendAppUpdateEvent(AppSettings appSettings) async {
    var info = await PackageInfo.fromPlatform();
    var version = info.version;

    Log.i("App Version: $version");
    Log.i("App Build Number: ${info.buildNumber}");

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
  String? _pendingShortcut;

  StreamSubscription? _intentDataStreamSubscription;
  var _sharedText = "";
  var _sharedImages = <String>[];

  @override
  void initState() {
    super.initState();

    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    final QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      Log.i("Quick Action Open: $shortcutType");
      if (_navigatorKey.currentState == null) {
        Log.i("Quick Action delegating for after build");
        WidgetsBinding.instance!
            .addPostFrameCallback((_) => _afterBuild(context));
        setState(() {
          _pendingShortcut = shortcutType;
        });
        return;
      }
      _navigatorKey.currentState!.pushNamed("/newNote/$shortcutType");

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
    });

    _initShareSubscriptions();
  }

  void _afterBuild(BuildContext context) {
    if (_pendingShortcut != null) {
      _navigatorKey.currentState!.pushNamed("/newNote/$_pendingShortcut");
      _pendingShortcut = null;
    }
  }

  void _initShareSubscriptions() {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    var handleShare = () {
      var noText = _sharedText.isEmpty;
      var noImages = _sharedImages.isEmpty;
      if (noText && noImages) {
        return;
      }

      var settings = Provider.of<Settings>(context, listen: false);
      var editor = settings.defaultEditor.toInternalString();
      _navigatorKey.currentState!.pushNamed("/newNote/$editor");
    };

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      Log.d("Received Share $value");

      _sharedImages = value.map((f) => f.path).toList();
      WidgetsBinding.instance!.addPostFrameCallback((_) => handleShare());
    }, onError: (err) {
      Log.e("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      Log.d("Received Share with App (media): $value");

      _sharedImages = value.map((f) => f.path).toList();
      WidgetsBinding.instance!.addPostFrameCallback((_) => handleShare());
    });

    // For sharing or opening text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      Log.d("Received Share $value");
      _sharedText = value;
      WidgetsBinding.instance!.addPostFrameCallback((_) => handleShare());
    }, onError: (err) {
      Log.e("getLinkStream error: $err");
    });

    // For sharing or opening text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      if (value == null) return;
      Log.d("Received Share with App (text): $value");
      _sharedText = value;
      WidgetsBinding.instance!.addPostFrameCallback((_) => handleShare());
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var stateContainer = Provider.of<GitJournalRepo>(context);
    var settings = Provider.of<Settings>(context);
    var appSettings = Provider.of<AppSettings>(context);
    var router = AppRouter(settings: settings, appSettings: appSettings);

    /*
    const FlexSchemeData customFlexScheme = FlexSchemeData(
      name: 'Toledo purple',
      description: 'Purple theme created from custom defined colors.',
      light: FlexSchemeColor(
        primary: Color(0xFF66bb6a),
        primaryVariant: Color(0xFF338a3e),
        secondary: Color(0xff6d4c41),
        secondaryVariant: Color(0xFF338a3e),
      ),
      dark: FlexSchemeColor(
        primary: Color(0xff212121),
        primaryVariant: Color(0xffc8635f),
        secondary: Color(0xff689f38),
        secondaryVariant: Color(0xff00be00),
      ),
    );
    */

    return MaterialApp(
      key: const ValueKey("App"),
      navigatorKey: _navigatorKey,
      title: 'GitJournal',

      localizationsDelegates: EasyLocalization.of(context)!.delegates,
      supportedLocales: EasyLocalization.of(context)!.supportedLocales,
      locale: EasyLocalization.of(context)!.locale,

      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: settings.theme.toThemeMode(),

      navigatorObservers: <NavigatorObserver>[
        AnalyticsRouteObserver(),
        SentryNavigatorObserver(),
      ],
      initialRoute: router.initialRoute(),
      debugShowCheckedModeBanner: false,
      //debugShowMaterialGrid: true,
      onGenerateRoute: (rs) {
        var r = router
            .generateRoute(rs, stateContainer, _sharedText, _sharedImages, () {
          _sharedText = "";
          _sharedImages = [];
        });

        return r;
      },
    );
  }
}

class GitJournalChangeNotifiers extends StatelessWidget {
  final RepositoryManager repoManager;
  final AppSettings appSettings;
  final Widget child;

  GitJournalChangeNotifiers({
    required this.repoManager,
    required this.appSettings,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var app = ChangeNotifierProvider.value(
      value: repoManager,
      child: Consumer<RepositoryManager>(
        builder: (_, repoManager, __) => ChangeNotifierProvider.value(
          value: repoManager.currentRepo,
          child: Consumer<GitJournalRepo>(
            builder: (_, repo, __) => ChangeNotifierProvider<Settings>.value(
              value: repo.settings,
              child: Consumer<GitJournalRepo>(
                builder: (_, repo, __) =>
                    ChangeNotifierProvider<NotesFolderFS>.value(
                  value: repo.notesFolder,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return ChangeNotifierProvider.value(
      value: appSettings,
      child: app,
    );
  }
}
