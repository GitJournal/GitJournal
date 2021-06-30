import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:time/time.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/features.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:gitjournal/settings/app_settings.dart';
import 'package:gitjournal/utils/logger.dart';
import 'package:gitjournal/utils/utils.dart';
import 'package:gitjournal/widgets/app_drawer_header.dart';
import 'package:gitjournal/widgets/pro_overlay.dart';

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
      curve: standardEasing,
    ));
    sizeAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: animController,
      curve: standardEasing,
    ));
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  Widget _buildRepoList() {
    var divider = Row(children: <Widget>[const Expanded(child: Divider())]);
    var repoManager = context.watch<RepositoryManager>();
    var repoIds = repoManager.repoIds;

    Widget w = Column(
      children: <Widget>[
        const SizedBox(height: 8),
        for (var id in repoIds) RepoTile(id),
        ProOverlay(
          feature: Feature.multiRepos,
          child: _buildDrawerTile(
            context,
            icon: Icons.add,
            title: tr('drawer.addRepo'),
            onTap: () {
              repoManager.addRepo();
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
    var repo = Provider.of<GitJournalRepo>(context);
    var appSettings = Provider.of<AppSettings>(context);
    var textStyle = Theme.of(context).textTheme.bodyText1;
    var currentRoute = ModalRoute.of(context)!.settings.name;

    if (!repo.remoteGitRepoConfigured) {
      setupGitButton = ListTile(
        leading: Icon(Icons.sync, color: textStyle!.color),
        title: Text(tr('drawer.setup'), style: textStyle),
        trailing: const Icon(
          Icons.info,
          color: Colors.red,
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, "/setupRemoteGit");

          logEvent(Event.DrawerSetupGitHost);
        },
      );
    }

    var divider = Row(children: <Widget>[const Expanded(child: Divider())]);

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
          if (!appSettings.proMode)
            _buildDrawerTile(
              context,
              icon: Icons.power,
              title: tr('drawer.pro'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/purchase");

                logEvent(
                  Event.PurchaseScreenOpen,
                  parameters: {"from": "drawer"},
                );
              },
            ),
          if (appSettings.experimentalAccounts)
            _buildDrawerTile(
              context,
              icon: Icons.account_circle,
              title: 'Login',
              onTap: () => _navTopLevel(context, '/login'),
              selected: currentRoute == '/login',
            ),
          if (!appSettings.proMode) divider,
          _buildDrawerTile(
            context,
            icon: Icons.note,
            title: tr('drawer.all'),
            onTap: () => _navTopLevel(context, '/'),
            selected: currentRoute == '/',
          ),
          _buildDrawerTile(
            context,
            icon: Icons.folder,
            title: tr('drawer.folders'),
            onTap: () => _navTopLevel(context, '/folders'),
            selected: currentRoute == "/folders",
          ),
          if (appSettings.experimentalFs)
            _buildDrawerTile(
              context,
              icon: FontAwesomeIcons.solidFolderOpen,
              isFontAwesome: true,
              title: tr('drawer.fs'),
              onTap: () => _navTopLevel(context, '/filesystem'),
              selected: currentRoute == "/filesystem",
            ),
          if (appSettings.experimentalGraphView)
            _buildDrawerTile(
              context,
              icon: FontAwesomeIcons.projectDiagram,
              isFontAwesome: true,
              title: tr('drawer.graph'),
              onTap: () => _navTopLevel(context, '/graph'),
              selected: currentRoute == "/graph",
            ),
          _buildDrawerTile(
            context,
            icon: FontAwesomeIcons.tag,
            isFontAwesome: true,
            title: tr('drawer.tags'),
            onTap: () => _navTopLevel(context, '/tags'),
            selected: currentRoute == "/tags",
          ),
          divider,
          _buildDrawerTile(
            context,
            icon: Icons.share,
            title: tr('drawer.share'),
            onTap: () {
              Navigator.pop(context);
              Share.share('Checkout GitJournal https://gitjournal.io/');

              logEvent(Event.DrawerShare);
            },
          ),
          _buildDrawerTile(
            context,
            icon: Icons.feedback,
            title: tr('drawer.rate'),
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
            title: tr('drawer.feedback'),
            onTap: () async {
              var platform = Platform.operatingSystem;
              var versionText = await getVersionString();
              var isPro = AppSettings.instance.proMode;

              var body =
                  "Hey!\n\nHere are some ways to improve GitJournal - \n \n\n";
              body += "Version: $versionText\n";
              body += "Platform: $platform\n";
              body += "isPro: $isPro\n";

              var exp = AppSettings.instance.proExpirationDate;
              if (exp.isNotEmpty) {
                body += "expiryDate: $exp";
              }

              body = Uri.encodeComponent(body);

              var subject = 'GitJournal Feedback';
              subject = Uri.encodeComponent(subject);

              var emailAddress = 'feedback@gitjournal.io';

              var url = 'mailto:$emailAddress?subject=$subject&body=$body';
              launch(url);

              Navigator.pop(context);
              logEvent(Event.DrawerFeedback);
            },
          ),
          _buildDrawerTile(
            context,
            icon: Icons.bug_report,
            title: tr('drawer.bug'),
            onTap: () async {
              var platform = Platform.operatingSystem;
              var versionText = await getVersionString();
              var isPro = AppSettings.instance.proMode;

              var body = "Hey!\n\nI found a bug in GitJournal - \n \n\n";
              body += "Version: $versionText\n";
              body += "Platform: $platform\n";
              body += "isPro: $isPro\n";

              var exp = AppSettings.instance.proExpirationDate;
              if (exp.isNotEmpty) {
                body += "expiryDate: $exp";
              }

              final Email email = Email(
                body: body,
                subject: 'GitJournal Bug',
                recipients: ['bugs@gitjournal.io'],
                attachmentPaths: Log.filePathsForDates(2),
              );

              await FlutterEmailSender.send(email);

              Navigator.pop(context);
              logEvent(Event.DrawerBugReport);
            },
          ),
          _buildDrawerTile(
            context,
            icon: Icons.settings,
            title: tr('settings.title'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/settings");

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
    var textStyle = theme.textTheme.bodyText1!.copyWith(
      color: selected ? theme.accentColor : listTileTheme.textColor,
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
      child: tile,
      color: selected ? theme.selectedRowColor : theme.scaffoldBackgroundColor,
    );
  }
}

class RepoTile extends StatelessWidget {
  const RepoTile(
    this.id, {
    Key? key,
  }) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var listTileTheme = ListTileTheme.of(context);
    var repoManager = context.watch<RepositoryManager>();

    // FIXME: Improve marking the selected repo
    var selected = repoManager.currentId == id;
    var textStyle = theme.textTheme.bodyText1!.copyWith(
      color: selected ? theme.accentColor : listTileTheme.textColor,
    );

    var icon = FaIcon(FontAwesomeIcons.book, color: textStyle.color);

    return ListTile(
      leading: icon,
      title: Text(repoManager.repoFolderName(id)),
      onTap: () {
        repoManager.setCurrentRepo(id);
        Navigator.pop(context);
      },
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
