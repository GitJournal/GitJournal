/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:hive/hive.dart';
import 'package:nested/nested.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart' show Directory, Platform;

import 'package:gitjournal/account/init.dart';
import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/analytics/route_observer.dart';
import 'package:gitjournal/app_router.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/link.dart';
import 'package:gitjournal/core/views/inline_tags_view.dart';
import 'package:gitjournal/core/views/note_links_view.dart';
import 'package:gitjournal/core/views/summary_view.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/iap/iap.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:gitjournal/settings/git_config.dart';
import 'package:gitjournal/settings/markdown_renderer_config.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/storage_config.dart';
import 'package:gitjournal/themes.dart';

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

    initSupabase();

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
        appConfig: appConfig,
        pref: pref,
        child: const JournalApp(),
      ),
      supportedLocales: const [
        // Arranged Alphabetically
        Locale('de'),
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('hu'),
        Locale('id'),
        Locale('it'),
        Locale('ja'),
        Locale('ko'),
        Locale('pl'),
        Locale('pt'),
        Locale('ru'),
        Locale('sv'),
        Locale('vi'),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      ], // Remember to update Info.plist
      fallbackLocale: const Locale('en'),
      useFallbackTranslations: true,
      path: 'assets/langs',
      useOnlyLangCode: true,
      assetLoader: YamlAssetLoader(),
    ));
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

    analytics.setUserProperty(
      name: 'proExpirationDate',
      value: appConfig.proExpirationDate.toString(),
    );
  }

  const JournalApp({Key? key}) : super(key: key);

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

    const quickActions = QuickActions();
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
      _navigatorKey.currentState!
          .pushNamed(AppRoute.NewNotePrefix + shortcutType);

      quickActions.setShortcutItems(<ShortcutItem>[
        ShortcutItem(
          type: 'Markdown',
          localizedTitle: tr(LocaleKeys.actions_newNote),
          icon: "ic_markdown",
        ),
        ShortcutItem(
          type: 'Checklist',
          localizedTitle: tr(LocaleKeys.actions_newChecklist),
          icon: "ic_tasks",
        ),
        ShortcutItem(
          type: 'Journal',
          localizedTitle: tr(LocaleKeys.actions_newJournal),
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

    var folderConfig = Provider.of<NotesFolderConfig>(context, listen: false);
    var editor = folderConfig.defaultEditor.toInternalString();
    _navigatorKey.currentState!.pushNamed(AppRoute.NewNotePrefix + editor);
  }

  void _initShareSubscriptions() {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      Log.d("Received Media Share $value");

      _sharedImages = value.map((f) => f.path).toList();
      WidgetsBinding.instance!.addPostFrameCallback(_handleShare);
    }, onError: (err) {
      Log.e("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      Log.d("Received MediaFile Share with App (media): $value");

      _sharedImages = value.map((f) => f.path).toList();
      WidgetsBinding.instance!.addPostFrameCallback(_handleShare);
    });

    // For sharing or opening text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      Log.d("Received Text Share: ${value.length}");
      if (value.startsWith('gitjournal-identity://')) {
        return;
      }
      _sharedText = value;
      WidgetsBinding.instance!.addPostFrameCallback(_handleShare);
    }, onError: (err) {
      Log.e("getLinkStream error: $err");
    });

    // For sharing or opening text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      if (value == null) return;
      Log.d("Received Share with App (text): ${value.length}");
      _sharedText = value;
      WidgetsBinding.instance!.addPostFrameCallback(_handleShare);
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
    var appConfig = Provider.of<AppConfig>(context);
    var storageConfig = Provider.of<StorageConfig>(context);
    var router = AppRouter(
      settings: settings,
      appConfig: appConfig,
      storageConfig: storageConfig,
    );

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
  final AppConfig appConfig;
  final SharedPreferences pref;
  final Widget child;

  const GitJournalChangeNotifiers({
    required this.repoManager,
    required this.appConfig,
    required this.pref,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var app = ChangeNotifierProvider.value(
      value: repoManager,
      child: Consumer<RepositoryManager>(
        builder: (_, repoManager, __) => _buildMarkdownSettings(
          child: ChangeNotifierProvider.value(
            value: repoManager.currentRepo,
            child: Consumer<GitJournalRepo>(
              builder: (_, repo, __) => _buildRepoDependentProviders(repo),
            ),
          ),
        ),
      ),
    );

    return ChangeNotifierProvider.value(
      value: appConfig,
      child: app,
    );
  }

  Widget _buildRepoDependentProviders(GitJournalRepo repo) {
    var folderConfig = repo.folderConfig;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GitConfig>.value(value: repo.gitConfig),
        ChangeNotifierProvider<StorageConfig>.value(value: repo.storageConfig),
        ChangeNotifierProvider<Settings>.value(value: repo.settings),
        ChangeNotifierProvider<NotesFolderConfig>.value(value: folderConfig),
      ],
      child: _buildNoteMaterializedViews(
        repo,
        ChangeNotifierProvider<NotesFolderFS>.value(
          value: repo.notesFolder,
          child: child,
        ),
      ),
    );
  }

  Widget _buildNoteMaterializedViews(GitJournalRepo repo, Widget child) {
    var repoPath = repo.repoPath;
    return Nested(
      children: [
        NoteSummaryProvider(repoPath: repoPath),
        InlineTagsProvider(repoPath: repoPath),
        NoteLinksProvider(repoPath: repoPath),
      ],
      child: child,
    );
  }

  Widget _buildMarkdownSettings({required Widget child}) {
    return Consumer<RepositoryManager>(
      builder: (_, repoManager, __) {
        var markdown = MarkdownRendererConfig(repoManager.currentId, pref);
        markdown.load();

        return ChangeNotifierProvider.value(value: markdown, child: child);
      },
    );
  }
}
