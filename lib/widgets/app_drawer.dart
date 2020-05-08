import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:gitjournal/features.dart';
import 'package:gitjournal/settings.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:page_transition/page_transition.dart';
import 'package:fetch_app_logs/fetch_app_logs.dart';

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/screens/folder_listing.dart';

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
          if (Features.purchaseProModeAvailable && !Settings.instance.proMode)
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
          if (Features.purchaseProModeAvailable && !Settings.instance.proMode)
            divider,
          _buildDrawerTile(
            context,
            icon: Icons.note,
            title: "All Notes",
            onTap: () {
              var m = ModalRoute.of(context);
              if (m.settings.name == "/") {
                Navigator.pop(context);
              } else {
                Navigator.popUntil(
                    context, (route) => route.settings.name == '/');
              }
            },
            selected: currentRoute == '/',
          ),
          _buildDrawerTile(
            context,
            icon: Icons.folder,
            title: "Folders",
            onTap: () {
              var m = ModalRoute.of(context);
              if (m.settings.name == '/') {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: FolderListingScreen(),
                    settings: const RouteSettings(name: '/folders'),
                  ),
                );
              } else if (m.settings.name == '/folders') {
                Navigator.pop(context);
              } else {
                // Check if '/folders' is a parent
                var wasParent = false;
                Navigator.popUntil(
                  context,
                  (route) {
                    wasParent = route.settings.name == '/folders';
                    return wasParent;
                  },
                );
                if (!wasParent) {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: FolderListingScreen(),
                      settings: const RouteSettings(name: '/folders'),
                    ),
                  );
                }
              }
            },
            selected: currentRoute == "/folders",
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
              String appLogsFilePath;
              try {
                appLogsFilePath = await FetchAppLogs.dumpAppLogsToFile();
              } catch (e) {
                print(e);
              }

              final Email email = Email(
                body:
                    "Hey!\n\nI found a bug in GitJournal - \n \n\nVersion: $versionText\nPlatform: $platform",
                subject: 'GitJournal Bug',
                recipients: ['bugs@gitjournal.io'],
                attachmentPath: appLogsFilePath,
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
    bool selected = false,
  }) {
    var theme = Theme.of(context);
    var listTileTheme = ListTileTheme.of(context);
    var textStyle = theme.textTheme.bodyText1.copyWith(
      color: selected ? theme.accentColor : listTileTheme.textColor,
    );

    var tile = ListTile(
      leading: Icon(icon, color: textStyle.color),
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
