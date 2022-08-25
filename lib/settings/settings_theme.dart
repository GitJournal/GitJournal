/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/screens/home_screen.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/themes.dart';

class SettingsThemeScreen extends StatefulWidget {
  static const routePath = '/settings/ui/theme';

  final Brightness brightness;

  const SettingsThemeScreen(this.brightness, {super.key});

  @override
  _SettingsThemeState createState() => _SettingsThemeState();
}

class _SettingsThemeState extends State<SettingsThemeScreen> {
  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context);

    var body = CarouselSlider(
      options: CarouselOptions(
        height: mq.size.height * 0.75,
        enlargeCenterPage: true,
        viewportFraction: 0.55,
        enableInfiniteScroll: false,
      ),
      items: [0, 1, 2, 3].map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              // decoration: BoxDecoration(color: Colors.amber),
              child: homeScreen(i),
            );
          },
        );
      }).toList(),
    );

    var title = widget.brightness == Brightness.light
        ? LocaleKeys.settings_theme_light.tr()
        : LocaleKeys.settings_theme_dark.tr();

    var settings = Provider.of<Settings>(context);
    var themeName = widget.brightness == Brightness.light
        ? settings.lightTheme
        : settings.darkTheme;

    return Theme(
      data: Themes.fromName(themeName),
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: body,
      ),
    );
  }

  Widget homeScreen(int i) {
    var themes = [
      GitJournalTheme.fromFlexLight(
        name: "Mandy Red",
        flexScheme: FlexScheme.mandyRed,
      ),
      GitJournalTheme.fromFlexLight(
        name: "Blue",
        flexScheme: FlexScheme.blue,
      ),
      GitJournalTheme.fromFlexLight(
        name: "Big Stone",
        flexScheme: FlexScheme.bigStone,
      ),
      GitJournalTheme.fromFlexLight(
        name: "Amber",
        flexScheme: FlexScheme.amber,
      ),
    ];

    return _GitJournalThemeView(gjTheme: themes[i]);
  }
}

class _GitJournalThemeView extends StatelessWidget {
  final GitJournalTheme gjTheme;

  const _GitJournalThemeView({required this.gjTheme});

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context);

    var homeScreen = Theme(
      data: gjTheme.themeData,
      child: SizedBox(
        width: mq.size.width,
        height: mq.size.height,
        child: IgnorePointer(
          child: HomeScreen(),
          ignoringSemantics: true,
        ),
      ),
    );

    var theme = Theme.of(context);

    return FittedBox(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              child: homeScreen,
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              gjTheme.name,
              style: Theme.of(context).textTheme.headline3!.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// 1. Improve the carrosuel
// 3. Show Telegram type animation when changing the theme
// 5. Hook it up so the theme is actually saved
//

class GitJournalTheme {
  final ThemeData themeData;
  final String name;

  GitJournalTheme({required this.name, required this.themeData});

  GitJournalTheme.fromFlexLight({
    required this.name,
    required FlexScheme flexScheme,
  }) : themeData = FlexColorScheme.light(scheme: flexScheme).toTheme;
}
