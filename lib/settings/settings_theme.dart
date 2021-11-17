/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/screens/home_screen.dart';

class SettingsThemeScreen extends StatefulWidget {
  static const routePath = '/settings/ui/theme';

  final Brightness brightness;

  const SettingsThemeScreen(this.brightness, {Key? key}) : super(key: key);

  @override
  _SettingsThemeState createState() => _SettingsThemeState();
}

class _SettingsThemeState extends State<SettingsThemeScreen> {
  @override
  Widget build(BuildContext context) {
    var body = CarouselSlider(
      options: CarouselOptions(height: 400.0),
      items: [0, 1, 2, 3, 4, 5].map((i) {
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

    return Scaffold(
      appBar: AppBar(
        // FIXME: Change this title
        title: Text(tr(LocaleKeys.settings_fileTypes_title)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: body,
    );
  }

  Widget homeScreen(int i) {
    var themes = [
      FlexScheme.mandyRed,
      FlexScheme.blue,
      FlexScheme.bigStone,
      FlexScheme.brandBlue,
      FlexScheme.amber,
      FlexScheme.greyLaw,
    ];
    var theme = Theme.of(context);
    var mq = MediaQuery.of(context);

    var homeScreen = Transform.scale(
      scale: 0.85,
      child: Container(
        padding: const EdgeInsets.all(2.0),
        color: theme.colorScheme.secondary.withAlpha(256 ~/ 10),
        child: SizedBox(
          width: mq.size.width,
          height: mq.size.height,
          child: IgnorePointer(child: HomeScreen()),
        ),
      ),
      alignment: Alignment.bottomCenter,
    );

    return Theme(
      data: FlexColorScheme.light(scheme: themes[i]).toTheme,
      child: homeScreen,
    );
  }
}

// 1. Improve the carrosuel
// 2. Add a name of it
// 3. Show Telegram type animation when changing the theme
// 4. Make the 'home screen' view bigger
// 5. Hook it up so the theme is actually saved
//
// Have a class called GitJournalTheme
