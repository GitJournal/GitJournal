import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils/logger.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/utils.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget setupGitButton;
    var appState = Provider.of<StateContainer>(context).appState;
    var textStyle = Theme.of(context).textTheme.bodyText1;
    var currentRoute = ModalRoute.of(context).settings.name;

    if (!appState.remoteGitRepoConfigured) {
      setupGitButton = ListTile(
        leading: Icon(Icons.sync, color: textStyle.color),
        title: Text('Setup Git Host', style: textStyle),
        trailing: Icon(
          Icons.info,
          color: Colors.red,
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, "/setupRemoteGit");

          getAnalytics().logEvent(
            name: "drawer_setupGitHost",
          );
        },
      );
    }

    var divider = Row(children: <Widget>[const Expanded(child: Divider())]);

    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
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
          if (setupGitButton != null) ...[setupGitButton, divider],
          if (!Settings.instance.proMode)
            _buildDrawerTile(
              context,
              icon: Icons.power,
              title: "Unlock Pro Version",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/purchase");

                getAnalytics().logEvent(
                  name: "purchase_screen_open",
                );
              },
            ),
          if (!Settings.instance.proMode) divider,
          _buildDrawerTile(
            context,
            icon: Icons.note,
            title: "All Notes",
            onTap: () => _navTopLevel(context, '/'),
            selected: currentRoute == '/',
          ),
          _buildDrawerTile(
            context,
            icon: Icons.folder,
            title: "Folders",
            onTap: () => _navTopLevel(context, '/folders'),
            selected: currentRoute == "/folders",
          ),
          _buildDrawerTile(
            context,
            icon: FontAwesomeIcons.tag,
            isFontAwesome: true,
            title: "Tags",
            onTap: () => _navTopLevel(context, '/tags'),
            selected: currentRoute == "/tags",
          ),
          divider,
          _buildDrawerTile(
            context,
            icon: Icons.share,
            title: 'Share App',
            onTap: () {
              Navigator.pop(context);
              Share.share('Checkout GitJournal https://gitjournal.io/');

              getAnalytics().logEvent(
                name: "drawer_share",
              );
            },
          ),
          _buildDrawerTile(
            context,
            icon: Icons.feedback,
            title: 'Rate Us',
            onTap: () {
              LaunchReview.launch(
                androidAppId: "io.gitjournal.gitjournal",
                iOSAppId: "1466519634",
              );
              Navigator.pop(context);

              getAnalytics().logEvent(
                name: "drawer_rate",
              );
            },
          ),
          _buildDrawerTile(
            context,
            icon: Icons.rate_review,
            title: 'Feedback',
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

              getAnalytics().logEvent(
                name: "drawer_feedback",
              );
            },
          ),
          _buildDrawerTile(
            context,
            icon: Icons.bug_report,
            title: 'Bug Report',
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

              getAnalytics().logEvent(
                name: "drawer_bugreport",
              );
            },
          ),
          _buildDrawerTile(
            context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/settings");

              getAnalytics().logEvent(
                name: "drawer_settings",
              );
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
