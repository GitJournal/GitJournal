/*
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:function_types/function_types.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/logger/debug_screen.dart';
import 'package:gitjournal/settings/bug_report.dart';
import 'package:gitjournal/settings/settings_about.dart';
import 'package:gitjournal/settings/settings_analyatics.dart';
import 'package:gitjournal/settings/settings_editors.dart';
import 'package:gitjournal/settings/settings_experimental.dart';
import 'package:gitjournal/settings/settings_git.dart';
import 'package:gitjournal/settings/settings_storage.dart';
import 'package:gitjournal/settings/settings_ui.dart';
import 'package:gitjournal/settings/widgets/settings_header.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  static const routePath = '/settings';

  @override
  Widget build(BuildContext context) {
    var list = ListView(
      children: [
        SettingsTile(
          iconData: FontAwesomeIcons.paintbrush,
          title: context.loc.settingsListUserInterfaceTitle,
          subtitle: context.loc.settingsListUserInterfaceSubtitle,
          onTap: () {
            var route = MaterialPageRoute(
              builder: (context) => const SettingsUIScreen(),
              settings: const RouteSettings(
                name: SettingsUIScreen.routePath,
              ),
            );
            var _ = Navigator.push(context, route);
          },
        ),
        SettingsTile(
          iconData: FontAwesomeIcons.git,
          title: context.loc.settingsListGitTitle,
          subtitle: context.loc.settingsListGitSubtitle,
          onTap: () {
            var route = MaterialPageRoute(
              builder: (context) => const SettingsGit(),
              settings: const RouteSettings(
                name: SettingsGit.routePath,
              ),
            );
            var _ = Navigator.push(context, route);
          },
        ),
        SettingsTile(
          iconData: FontAwesomeIcons.penToSquare,
          title: context.loc.settingsListEditorTitle,
          subtitle: context.loc.settingsListEditorSubtitle,
          onTap: () {
            var route = MaterialPageRoute(
              builder: (context) => SettingsEditorsScreen(),
              settings: const RouteSettings(
                name: SettingsEditorsScreen.routePath,
              ),
            );
            var _ = Navigator.push(context, route);
          },
        ),
        SettingsTile(
          iconData: FontAwesomeIcons.hardDrive,
          title: context.loc.settingsListStorageTitle,
          subtitle: context.loc.settingsListStorageSubtitle,
          onTap: () {
            var route = MaterialPageRoute(
              builder: (context) => const SettingsStorageScreen(),
              settings: const RouteSettings(
                name: SettingsStorageScreen.routePath,
              ),
            );
            var _ = Navigator.push(context, route);
          },
        ),
        SettingsTile(
          iconData: FontAwesomeIcons.chartArea,
          title: context.loc.settingsListAnalyticsTitle,
          subtitle: context.loc.settingsListAnalyticsSubtitle,
          onTap: () {
            var route = MaterialPageRoute(
              builder: (context) => const SettingsAnalytics(),
              settings: const RouteSettings(name: SettingsAnalytics.routePath),
            );
            var _ = Navigator.push(context, route);
          },
        ),
        SettingsTile(
          iconData: FontAwesomeIcons.wrench,
          title: context.loc.settingsListDebugTitle,
          subtitle: context.loc.settingsListDebugSubtitle,
          onTap: () {
            var route = MaterialPageRoute(
              builder: (context) => const DebugScreen(),
              settings: const RouteSettings(name: DebugScreen.routePath),
            );
            var _ = Navigator.push(context, route);
          },
        ),
        SettingsTile(
          iconData: FontAwesomeIcons.flask,
          title: context.loc.settingsListExperimentsTitle,
          subtitle: context.loc.settingsListExperimentsSubtitle,
          onTap: () {
            var route = MaterialPageRoute(
              builder: (context) => ExperimentalSettingsScreen(),
              settings: const RouteSettings(
                name: ExperimentalSettingsScreen.routePath,
              ),
            );
            var _ = Navigator.push(context, route);
          },
        ),
        const Divider(),
        SettingsHeader(context.loc.settingsProjectHeader),
        SettingsTile(
          iconData: Icons.question_answer_outlined,
          title: context.loc.settingsProjectDocs,
          onTap: () {
            var _ = launchUrl(
              Uri.parse('https://gitjournal.io/docs'),
              mode: LaunchMode.externalApplication,
            );
          },
        ),
        SettingsTile(
          iconData: FontAwesomeIcons.bug,
          title: context.loc.drawerBug,
          onTap: () => createBugReport(context),
        ),
        SettingsTile(
          iconData: FontAwesomeIcons.message,
          title: context.loc.drawerFeedback,
          onTap: () => createFeedback(context),
        ),
        SettingsTile(
          iconData: FontAwesomeIcons.heart,
          title: context.loc.settingsProjectContribute,
        ),
        SettingsTile(
          iconData: Icons.info_outline,
          title: context.loc.settingsProjectAbout,
          onTap: () {
            var route = MaterialPageRoute(
              builder: (context) => const SettingsAboutPage(),
              settings: const RouteSettings(name: SettingsAboutPage.routePath),
            );
            var _ = Navigator.push(context, route);
          },
        ),
      ],
      padding: const EdgeInsets.symmetric(vertical: 16.0),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: list,
    );
  }
}

// ignore: unused_element
class _SettingsSearchBar extends StatelessWidget {
  const _SettingsSearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 1.0,
        borderRadius: BorderRadius.circular(25.0),
        child: TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            hintText: "Search",
            fillColor: Colors.white70,
            prefixIcon: const Icon(Icons.search),
            // This content padding has no effect if 'prefixIcon' is set!!
            contentPadding: const EdgeInsets.fromLTRB(205.0, 15.0, 20.0, 15.0),
          ),
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData iconData;
  final String title;
  final String? subtitle;
  final Func0<void>? onTap;

  const SettingsTile({
    super.key,
    required this.iconData,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var listTileTheme = ListTileTheme.of(context);

    var textStyle = theme.textTheme.subtitle1!.copyWith(
      color: listTileTheme.textColor,
    );

    var icon = iconData is FontAwesomeIcons
        ? Icon(iconData, color: textStyle.color)
        : FaIcon(iconData, color: textStyle.color);

    return ListTile(
      leading: icon,
      title: Text(title, style: textStyle),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      onTap: onTap ?? onTap,
    );
  }
}
