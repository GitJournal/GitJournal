import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/app_settings.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/utils/logger.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget setupGitButton;
    var repo = Provider.of<Repository>(context);
    var appSettings = Provider.of<AppSettings>(context);
    var textStyle = Theme.of(context).textTheme.bodyText1;
    var currentRoute = ModalRoute.of(context).settings.name;

    if (!repo.remoteGitRepoConfigured) {
      setupGitButton = ListTile(
        leading: Icon(Icons.sync, color: textStyle.color),
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
          _AppDrawerHeader(),
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
              var versionText = await getVersionString();

              var platform = Platform.operatingSystem;
              var emailAddress = 'feedback@gitjournal.io';
              var subject = 'GitJournal Feedback';
              var body =
                  "Hey!\n\nHere are some ways to improve GitJournal - \n \n\nVersion: $versionText\nPlatform: $platform";

              subject = Uri.encodeComponent(subject);
              body = Uri.encodeComponent(body);

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
              var appLogsFilePath = Log.filePathForDate(DateTime.now());

              final Email email = Email(
                body:
                    "Hey!\n\nI found a bug in GitJournal - \n \n\nVersion: $versionText\nPlatform: $platform",
                subject: 'GitJournal Bug',
                recipients: ['bugs@gitjournal.io'],
                attachmentPaths: [appLogsFilePath],
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
    @required IconData icon,
    @required String title,
    @required Function onTap,
    bool isFontAwesome = false,
    bool selected = false,
  }) {
    var theme = Theme.of(context);
    var listTileTheme = ListTileTheme.of(context);
    var textStyle = theme.textTheme.bodyText1.copyWith(
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

void _navTopLevel(BuildContext context, String toRoute) {
  var fromRoute = ModalRoute.of(context).settings.name;
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

class _AppDrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appSettings = Provider.of<AppSettings>(context);

    return Stack(
      children: <Widget>[
        DrawerHeader(
          margin: const EdgeInsets.all(0.0),
          decoration: BoxDecoration(
            color: Theme.of(context).highlightColor,
          ),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/icon/icon.png'),
                ),
              ),
            ),
          ),
        ),
        /*
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              padding: const EdgeInsets.all(0),
              icon: Icon(Icons.arrow_left, size: 42.0),
              onPressed: () {},
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              padding: const EdgeInsets.all(0),
              icon: Icon(Icons.arrow_right, size: 42.0),
              onPressed: () {},
            ),
          ),
        ),
        */
        if (appSettings.proMode)
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomRight,
              child: ProButton(),
            ),
          ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topRight,
            child: SafeArea(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 16, 0),
              child: ThemeSwitcherButton(),
            )),
          ),
        ),
      ],
      fit: StackFit.passthrough,
    );
  }
}

class ProButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(color: theme.accentColor, spreadRadius: 0),
          ],
        ),
        padding: const EdgeInsets.all(8.0),
        child: Text('PRO', style: theme.textTheme.button),
      ),
    );
  }
}

class ThemeSwitcherButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: const FaIcon(FontAwesomeIcons.solidMoon),
      onTap: () {
        var dynamicTheme = DynamicTheme.of(context);
        var brightness = dynamicTheme.brightness;

        dynamicTheme.setBrightness(brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light);
      },
    );
  }
}
