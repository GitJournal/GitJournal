/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/settings/settings_screen.dart';
import 'package:gitjournal/settings/widgets/version_number_widgit.dart';

const _privacyUrl = "https://gitjournal.io/privacy";
const _termsUrl = "https://gitjournal.io/terms";

class SettingsAboutPage extends StatelessWidget {
  static const routePath = '/settings/about';

  const SettingsAboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var list = ListView(
      children: [
        const _AboutPageHeader(),
        const Divider(),
        const VersionNumberTile(),
        SettingsTile(
          iconData: FontAwesomeIcons.userShield,
          title: LocaleKeys.settings_privacy.tr(),
          subtitle: _privacyUrl.replaceAll('https://', ''),
          onTap: () {
            launch(_privacyUrl);
          },
        ),
        SettingsTile(
          iconData: FontAwesomeIcons.fileContract,
          title: LocaleKeys.settings_terms.tr(),
          subtitle: _termsUrl.replaceAll('https://', ''),
          onTap: () {
            launch(_termsUrl);
          },
        ),
        SettingsTile(
          iconData: FontAwesomeIcons.infoCircle,
          title: LocaleKeys.settings_license_title.tr(),
          subtitle: LocaleKeys.settings_license_subtitle.tr(),
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
        title: Text(tr(LocaleKeys.settings_project_about)),
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
  const _AboutPageHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const GitJournalLogo(width: 64 * 2, height: 64 * 2);
  }
}

class GitJournalLogo extends StatelessWidget {
  final int width;
  final int height;

  const GitJournalLogo({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

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
