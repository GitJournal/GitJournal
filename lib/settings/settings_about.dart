/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/settings/settings_screen.dart';
import 'package:gitjournal/settings/widgets/version_number_widgit.dart';
import 'package:url_launcher/url_launcher.dart';

const _privacyUrl = "https://gitjournal.io/privacy";
const _termsUrl = "https://gitjournal.io/terms";

class SettingsAboutPage extends StatelessWidget {
  static const routePath = '/settings/about';

  const SettingsAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    var list = ListView(
      children: [
        const _AboutPageHeader(),
        const Divider(),
        const VersionNumberTile(),
        SettingsTile(
          iconData: FontAwesomeIcons.userShield,
          title: context.loc.settingsPrivacy,
          subtitle: _privacyUrl.replaceAll('https://', ''),
          onTap: () {
            var _ = launchUrl(
              Uri.parse(_privacyUrl),
              mode: LaunchMode.externalApplication,
            );
          },
        ),
        SettingsTile(
          iconData: FontAwesomeIcons.fileContract,
          title: context.loc.settingsTerms,
          subtitle: _termsUrl.replaceAll('https://', ''),
          onTap: () {
            var _ = launchUrl(
              Uri.parse(_termsUrl),
              mode: LaunchMode.externalApplication,
            );
          },
        ),
        SettingsTile(
          iconData: FontAwesomeIcons.circleInfo,
          title: context.loc.settingsLicenseTitle,
          subtitle: context.loc.settingsLicenseSubtitle,
          onTap: () {
            showLicensePage(
              context: context,
              applicationIcon: const GitJournalLogo(height: 32, width: 32),
            );
          },
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.settingsProjectAbout),
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

class _AboutPageHeader extends StatelessWidget {
  const _AboutPageHeader();

  @override
  Widget build(BuildContext context) {
    return const GitJournalLogo(width: 64 * 2, height: 64 * 2);
  }
}

class GitJournalLogo extends StatelessWidget {
  final int width;
  final int height;

  const GitJournalLogo({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/icon/icon.png'),
          ),
        ),
        child: SizedBox(width: 64 * 2, height: 64 * 2),
      ),
    );
  }
}
