/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/features.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/settings_bottom_menu_bar.dart';
import 'package:gitjournal/settings/settings_display_images.dart';
import 'package:gitjournal/settings/settings_misc.dart';
import 'package:gitjournal/settings/settings_screen.dart';
import 'package:gitjournal/settings/settings_theme.dart';
import 'package:gitjournal/settings/widgets/language_selector.dart';
import 'package:gitjournal/settings/widgets/settings_header.dart';
import 'package:gitjournal/settings/widgets/settings_list_preference.dart';
import 'package:gitjournal/widgets/pro_overlay.dart';

const feature_themes = false;

class SettingsUIScreen extends StatelessWidget {
  static const routePath = '/settings/ui';

  const SettingsUIScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<Settings>(context);

    var list = ListView(
      children: [
        SettingsHeader(tr(LocaleKeys.settings_display_title)),
        ListPreference(
          title: tr(LocaleKeys.settings_display_theme),
          currentOption: settings.theme.toPublicString(),
          options:
              SettingsTheme.options.map((f) => f.toPublicString()).toList(),
          onChange: (String publicStr) {
            var s = SettingsTheme.fromPublicString(publicStr);
            settings.theme = s;
            settings.save();
          },
        ),
        if (feature_themes)
          SettingsTile(
            title: LocaleKeys.settings_theme_light.tr(),
            iconData: FontAwesomeIcons.sun,
            onTap: () {
              var route = MaterialPageRoute(
                builder: (context) =>
                    const SettingsThemeScreen(Brightness.light),
                settings:
                    const RouteSettings(name: SettingsThemeScreen.routePath),
              );
              var _ = Navigator.push(context, route);
            },
          ),
        const LanguageSelector(),
        ListTile(
          title: Text(tr(LocaleKeys.settings_display_images_title)),
          subtitle: Text(tr(LocaleKeys.settings_display_images_subtitle)),
          onTap: () {
            var route = MaterialPageRoute(
              builder: (context) => SettingsDisplayImagesScreen(),
              settings: const RouteSettings(
                name: SettingsDisplayImagesScreen.routePath,
              ),
            );
            var _ = Navigator.push(context, route);
          },
        ),
        ProOverlay(
          feature: Feature.customizeHomeScreen,
          child: ListPreference(
            title: tr(LocaleKeys.settings_display_homeScreen),
            currentOption: settings.homeScreen.toPublicString(),
            options: SettingsHomeScreen.options
                .map((f) => f.toPublicString())
                .toList(),
            onChange: (String publicStr) {
              var s = SettingsHomeScreen.fromPublicString(publicStr);
              settings.homeScreen = s;
              settings.save();
            },
          ),
        ),
        ProOverlay(
          feature: Feature.configureBottomMenuBar,
          child: ListTile(
            title: Text(tr(LocaleKeys.settings_bottomMenuBar_title)),
            subtitle: Text(tr(LocaleKeys.settings_bottomMenuBar_subtitle)),
            onTap: () {
              var route = MaterialPageRoute(
                builder: (context) => BottomMenuBarSettings(),
                settings:
                    const RouteSettings(name: BottomMenuBarSettings.routePath),
              );
              var _ = Navigator.push(context, route);
            },
          ),
        ),
        ListTile(
          title: Text(tr(LocaleKeys.settings_misc_title)),
          onTap: () {
            var route = MaterialPageRoute(
              builder: (context) => SettingsMisc(),
              settings: const RouteSettings(name: SettingsMisc.routePath),
            );
            var _ = Navigator.push(context, route);
          },
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.settings_list_userInterface_title.tr()),
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
