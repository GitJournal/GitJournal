/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/analytics/route_observer.dart';
import 'package:gitjournal/app_router.dart';
import 'package:gitjournal/change_notifiers.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/link.dart';
import 'package:gitjournal/core/views/note_links_view.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/iap/iap.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:gitjournal/screens/error_screen.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/storage_config.dart';
import 'package:gitjournal/themes.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart' show Directory, Platform;

class JournalApp extends StatefulWidget {
  static Future<void> main(SharedPreferences pref) async {
    await Log.init();

    Log.i("--------------------------------");
    Log.i("--------------------------------");
    Log.i("--------------------------------");
    Log.i("--------- App Launched ---------");
    Log.i("--------------------------------");
    Log.i("--------------------------------");
    Log.i("--------------------------------");

    var appConfig = AppConfig.instance;
    Log.i("AppConfig", props: appConfig.toMap());

    _enableAnalyticsIfPossible(appConfig, pref);

    final gitBaseDirectory = (await getApplicationDocumentsDirectory()).path;
    final cacheDir = (await getApplicationSupportDirectory()).path;

    Hive.init(cacheDir);
    Hive.registerAdapter(LinkAdapter());
    Hive.registerAdapter(LinksListAdapter());

    var repoManager = RepositoryManager(
      gitBaseDir: gitBaseDirectory,
      cacheDir: cacheDir,
      pref: pref,
    );

    // Ignore the error, the router will show an error screen
    await repoManager.buildActiveRepository();

    GitJournalInAppPurchases.confirmProPurchaseBoot();

    runApp(
      GitJournalChangeNotifiers(
        repoManager: repoManager,
        appConfig: appConfig,
        pref: pref,
        child: JournalApp(repoManager: repoManager),
      ),
    );
  }

  // TODO: All this logic should go inside the analytics package
  static Future<void> _enableAnalyticsIfPossible(
    AppConfig appConfig,
    SharedPreferences pref,
  ) async {
    var supportDir = await getApplicationSupportDirectory();
    var analyticsStorage = p.join(supportDir.path, 'analytics');
    await Directory(analyticsStorage).create(recursive: true);

    var analytics = await Analytics.init(
      pref: pref,
      analyticsCallback: captureErrorBreadcrumb,
      storagePath: analyticsStorage,
    );

    analytics.setUserProperty(
      name: 'proMode',
      value: appConfig.proMode.toString(),
    );
  }

  final RepositoryManager repoManager;

  const JournalApp({super.key, required this.repoManager});

  @override
  JournalAppState createState() => JournalAppState();
}

class JournalAppState extends State<JournalApp> {
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

    const quickActions = QuickActions();
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
      _navigatorKey.currentState!
          .pushNamed(AppRoute.NewNotePrefix + shortcutType);

      quickActions.setShortcutItems(<ShortcutItem>[
        ShortcutItem(
          type: 'Markdown',
          localizedTitle: context.loc.actionsNewNote,
          icon: "ic_markdown",
        ),
        ShortcutItem(
          type: 'Checklist',
          localizedTitle: context.loc.actionsNewChecklist,
          icon: "ic_tasks",
        ),
        ShortcutItem(
          type: 'Journal',
          localizedTitle: context.loc.actionsNewJournal,
          icon: "ic_book",
        ),
      ]);
    });

    _initShareSubscriptions();
  }

  void _afterBuild(BuildContext context) {
    if (_pendingShortcut != null) {
      var routeName = AppRoute.NewNotePrefix + _pendingShortcut!;
      _navigatorKey.currentState!.pushNamed(routeName);
      _pendingShortcut = null;
    }
  }

  void _handleShare(Duration _) {
    var noText = _sharedText.isEmpty;
    var noImages = _sharedImages.isEmpty;
    if (noText && noImages) {
      return;
    }

    var folderConfig = context.read<NotesFolderConfig>();
    var editor = folderConfig.defaultEditor.toInternalString();
    _navigatorKey.currentState!.pushNamed(AppRoute.NewNotePrefix + editor);
  }

  @visibleForTesting
  void handleSharedMedia(Iterable<SharedMediaFile> media) {
    _sharedImages = [];
    _sharedText = "";

    // if (value.startsWith('gitjournal-identity://')) return;

    for (var m in media) {
      switch (m.type) {
        case SharedMediaType.image:
          Log.d("Received Image Share $m");
          _sharedImages.add(m.path);
          break;
        case SharedMediaType.video:
          Log.d("Received Video Share $m");
          Log.d("Video sharing is not supported");
          break;
        case SharedMediaType.url:
          Log.d("Received URL Share $m");
          _sharedText =
              _sharedText.isEmpty ? m.path : "$_sharedText\n${m.path}";
          break;
        case SharedMediaType.text:
          Log.d("Received Text Share $m");
          _sharedText =
              _sharedText.isEmpty ? m.path : "$_sharedText\n${m.path}";
          break;
        case SharedMediaType.file:
          Log.d("Received File Share $m");
          Log.d("File sharing is not supported");
          break;
      }
      Log.d("Received Media Share $m");
    }
    WidgetsBinding.instance.addPostFrameCallback(_handleShare);
  }

  void _initShareSubscriptions() {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    // For sharing text and images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedMediaFile> value) {
      Log.d("Received Media Share $value");
      handleSharedMedia(value);
    }, onError: (err) {
      Log.e("getIntentDataStream error: $err");
    });

    // For sharing text and images coming from outside the app while the app is closed
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> value) {
      Log.d("Received MediaFile Share with App (media): $value");

      handleSharedMedia(value);
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var repo = widget.repoManager.currentRepo;

    // Repository.load can be quite slow, especially because of the 'git commit'
    // on booting
    // FIXME: Make Settings not depend on Repository
    late Settings settings;
    try {
      settings = context.watch<Settings>();
    } catch (_) {
      return const SizedBox();
    }

    // FIXME: Settings can be null in this case!

    AppRouter? router;
    var themeMode = ThemeMode.system;

    if (repo != null) {
      var appConfig = context.watch<AppConfig>();
      var storageConfig = context.watch<StorageConfig>();

      router = AppRouter(
        settings: settings,
        appConfig: appConfig,
        storageConfig: storageConfig,
      );

      themeMode = settings.theme.toThemeMode();
    }
    var initialRoute =
        router != null ? router.initialRoute() : ErrorScreen.routePath;

    /*

    Also use -
    * https://github.com/bernaferrari/RandomColorScheme
    * https://pub.dev/packages/color_blindness

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

    var locale = Locale(settings.locale);
    var lSplit = settings.locale.split("_");
    if (lSplit.length > 1) {
      locale = Locale(lSplit[0], lSplit[1]);
    }

    return MaterialApp(
      key: const ValueKey("App"),
      navigatorKey: _navigatorKey,
      title: 'GitJournal',

      localizationsDelegates: gitJournalLocalizationDelegates,
      supportedLocales: gitJournalSupportedLocales,
      locale: locale,

      theme: Themes.fromName(settings.lightTheme),
      darkTheme: Themes.fromName(settings.darkTheme),
      themeMode: themeMode,
      navigatorObservers: <NavigatorObserver>[
        AnalyticsRouteObserver(),
        SentryNavigatorObserver(),
      ],
      initialRoute: initialRoute,
      debugShowCheckedModeBanner: false,
      //debugShowMaterialGrid: true,
      onGenerateRoute: (rs) {
        if (router == null || repo == null) {
          return MaterialPageRoute(
            settings: rs,
            builder: (context) => const ErrorScreen(),
          );
        }

        var r = router.generateRoute(rs, repo, _sharedText, _sharedImages, () {
          _sharedText = "";
          _sharedImages = [];
        });

        return r;
      },
    );
  }
}
