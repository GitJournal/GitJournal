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
import 'package:gitjournal/settings/settings_screen2.dart';

const _privacyUrl = "https://gitjournal.io/privacy";
const _termsUrl = "https://gitjournal.io/terms";

class SettingsAboutPage extends StatelessWidget {
  const SettingsAboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var list = ListView(
      children: [
        const VersionNumberTile(),
        SettingsTile(
          iconData: FontAwesomeIcons.userShield,
          title: LocaleKeys.settings_privacy.tr(),
          subtitle: _privacyUrl,
          onTap: () {
            launch(_privacyUrl);
          },
        ),
        SettingsTile(
          iconData: FontAwesomeIcons.fileContract,
          title: LocaleKeys.settings_terms.tr(),
          subtitle: _termsUrl,
          onTap: () {
            launch(_termsUrl);
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
