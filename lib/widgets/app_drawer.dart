/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:git_setup/screens.dart';
import 'package:gitjournal/account/login_screen.dart';
import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/folder_listing/view/folder_listing.dart';
import 'package:gitjournal/iap/purchase_screen.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:gitjournal/screens/error_screen.dart';
import 'package:gitjournal/screens/home_screen.dart';
import 'package:gitjournal/screens/tag_listing.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:gitjournal/settings/bug_report.dart';
import 'package:gitjournal/settings/settings_screen.dart';
import 'package:gitjournal/widgets/app_drawer_header.dart';
import 'package:gitjournal/widgets/pro_overlay.dart';
import 'package:launch_app_store/launch_app_store.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:time/time.dart';
import 'package:universal_io/io.dart' show Platform;

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController animController;

  late Animation<double> sizeAnimation;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();

    animController =
        AnimationController(duration: 250.milliseconds, vsync: this);

    slideAnimation = Tween(begin: const Offset(0.0, -0.5), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: animController,
      curve: Easing.legacy,
    ));
    sizeAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: animController,
      curve: Easing.legacy,
    ));
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  Widget _buildRepoList() {
    var divider = const Row(children: <Widget>[Expanded(child: Divider())]);
    var repoManager = context.watch<RepositoryManager>();
    var repoIds = repoManager.repoIds;

    Widget w = Column(
      children: <Widget>[
        const SizedBox(height: 8),
        for (var id in repoIds) RepoTile(id),
        ProOverlay(
          child: _buildDrawerTile(
            context,
            icon: Icons.add,
            title: context.loc.drawerAddRepo,
            onTap: () {
              repoManager.addRepoAndSwitch();
              Navigator.pop(context);
            },
            selected: false,
          ),
        ),
        divider,
      ],
    );

    w = SlideTransition(
      position: slideAnimation,
      transformHitTests: false,
      child: w,
    );

    return SizeTransition(
      sizeFactor: sizeAnimation,
      child: w,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? setupGitButton;
    var repoManager = context.watch<RepositoryManager>();
    var repo = repoManager.currentRepo;
    var appConfig = context.watch<AppConfig>();
    var textStyle = Theme.of(context).textTheme.bodyLarge;
    var currentRoute = ModalRoute.of(context)!.settings.name;

    if (repo?.remoteGitRepoConfigured == false) {
      setupGitButton = ListTile(
        leading: Icon(Icons.sync, color: textStyle!.color),
        title: Text(context.loc.drawerSetup, style: textStyle),
        trailing: const Icon(
          Icons.info,
          color: Colors.red,
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, GitHostSetupScreen.routePath);

          logEvent(Event.DrawerSetupGitHost);
        },
      );
    }

    var divider = const Row(children: <Widget>[Expanded(child: Divider())]);

    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          AppDrawerHeader(
            repoListToggled: () {
              if (animController.isCompleted) {
                animController.reverse(from: 1.0);
              } else {
                animController.forward(from: 0.0);
              }
            },
          ),
          // If they are multiple show the current one which a tick mark
          _buildRepoList(),
          if (setupGitButton != null) ...[setupGitButton, divider],
          if (!appConfig.proMode)
            _buildDrawerTile(
              context,
              icon: Icons.power,
              title: context.loc.drawerPro,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, PurchaseScreen.routePath);

                logEvent(
                  Event.PurchaseScreenOpen,
                  parameters: {"from": "drawer"},
                );
              },
            ),
          if (appConfig.experimentalAccounts)
            _buildDrawerTile(
              context,
              icon: Icons.account_circle,
              title: context.loc.drawerLogin,
              onTap: () => _navTopLevel(context, LoginPage.routePath),
              selected: currentRoute == LoginPage.routePath,
            ),
          if (!appConfig.proMode) divider,
          if (repo != null)
            _buildDrawerTile(
              context,
              icon: Icons.note,
              title: context.loc.drawerAll,
              onTap: () => _navTopLevel(context, HomeScreen.routePath),
              selected: currentRoute == HomeScreen.routePath,
            ),
          if (repo != null)
            _buildDrawerTile(
              context,
              icon: Icons.folder,
              title: context.loc.drawerFolders,
              onTap: () => _navTopLevel(context, FolderListingScreen.routePath),
              selected: currentRoute == FolderListingScreen.routePath,
            ),
          if (repo != null)
            _buildDrawerTile(
              context,
              icon: FontAwesomeIcons.tag,
              isFontAwesome: true,
              title: context.loc.drawerTags,
              onTap: () => _navTopLevel(context, TagListingScreen.routePath),
              selected: currentRoute == TagListingScreen.routePath,
            ),
          divider,
          _buildDrawerTile(
            context,
            icon: Icons.share,
            title: context.loc.drawerShare,
            onTap: () {
              Navigator.pop(context);
              Share.share('Checkout GitJournal https://gitjournal.io/');

              logEvent(Event.DrawerShare);
            },
          ),
          if (Platform.isAndroid || Platform.isIOS)
            _buildDrawerTile(
              context,
              icon: Icons.feedback,
              title: context.loc.drawerRate,
              onTap: () {
                LaunchReview.launch(
                  androidAppId: "io.gitjournal.gitjournal",
                  iOSAppId: "1466519634",
                );

                Navigator.pop(context);
                logEvent(Event.DrawerRate);
              },
            ),
          _buildDrawerTile(
            context,
            icon: Icons.rate_review,
            title: context.loc.drawerFeedback,
            onTap: () async {
              await createFeedback(context);
              Navigator.pop(context);
            },
          ),
          _buildDrawerTile(
            context,
            icon: Icons.bug_report,
            title: context.loc.drawerBug,
            onTap: () async {
              await createBugReport(context);
              Navigator.pop(context);
            },
          ),
          if (repo != null)
            _buildDrawerTile(
              context,
              icon: Icons.settings,
              title: context.loc.settingsTitle,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, SettingsScreen.routePath);

                logEvent(Event.DrawerSettings);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required void Function() onTap,
    bool isFontAwesome = false,
    bool selected = false,
  }) {
    var theme = Theme.of(context);
    var listTileTheme = ListTileTheme.of(context);
    var textStyle = theme.textTheme.bodyLarge!.copyWith(
      color: selected ? theme.colorScheme.secondary : listTileTheme.textColor,
    );

    var iconW = !isFontAwesome
        ? Icon(icon, color: textStyle.color)
        : FaIcon(icon, color: textStyle.color);

    var tile = ListTile(
      leading: iconW,
      title: Text(title, style: textStyle),
      onTap: onTap,
      selected: selected,
    );
    return Container(
      color: selected ? theme.highlightColor : theme.scaffoldBackgroundColor,
      child: tile,
    );
  }
}

class RepoTile extends StatelessWidget {
  const RepoTile(
    this.id, {
    super.key,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var listTileTheme = ListTileTheme.of(context);
    var repoManager = context.watch<RepositoryManager>();

    var selected = repoManager.currentId == id;
    var textStyle = theme.textTheme.bodyLarge!.copyWith(
      color: selected ? theme.colorScheme.secondary : listTileTheme.textColor,
    );

    var icon = FaIcon(FontAwesomeIcons.book, color: textStyle.color);

    var tile = ListTile(
      leading: icon,
      title: Text(repoManager.repoFolderName(id), style: textStyle),
      onTap: () async {
        Navigator.pop(context);

        try {
          await repoManager.setCurrentRepo(id);
        } catch (ex) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            ErrorScreen.routePath,
            (r) => true,
          );
          return;
        }

        Navigator.of(context).pushNamedAndRemoveUntil(
          HomeScreen.routePath,
          (r) => true,
        );
      },
    );

    return Container(
      color: selected ? theme.highlightColor : theme.scaffoldBackgroundColor,
      child: tile,
    );
  }
}

void _navTopLevel(BuildContext context, String toRoute) {
  var fromRoute = ModalRoute.of(context)!.settings.name;
  Log.i("Routing from $fromRoute -> $toRoute");

  // Always first pop the AppBar
  Navigator.pop(context);

  if (fromRoute == toRoute) {
    return;
  }

  var wasParent = false;
  Navigator.popUntil(
    context,
    (route) {
      if (route.isFirst) {
        return true;
      }
      wasParent = route.settings.name == toRoute;
      if (wasParent) {
        Log.i("Router popping ${route.settings.name}");
      }
      return wasParent;
    },
  );
  if (!wasParent) {
    Navigator.pushNamed(context, toRoute);
  }
}
