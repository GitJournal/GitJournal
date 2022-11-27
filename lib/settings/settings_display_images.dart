/*
 * SPDX-FileCopyrightText: 2020-2021 Roland Fredenhagen <important@van-fredenhagen.de>
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/settings/markdown_renderer_config.dart';
import 'package:gitjournal/settings/settings_display_images_caption.dart';
import 'package:gitjournal/settings/settings_display_images_theming.dart';
import 'package:gitjournal/settings/widgets/settings_header.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SettingsDisplayImagesScreen extends StatefulWidget {
  static const routePath = '/settings/display_images';

  @override
  SettingsDisplayImagesScreenState createState() =>
      SettingsDisplayImagesScreenState();
}

class SettingsDisplayImagesScreenState
    extends State<SettingsDisplayImagesScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<MarkdownRendererConfig>(context);
    final theme = Theme.of(context);

    final body = ListView(children: <Widget>[
      ListTile(
        title: Text(context.loc.settingsDisplayImagesThemingTitle),
        subtitle: Text(context.loc.settingsDisplayImagesThemingSubtitle),
        onTap: () {
          var route = MaterialPageRoute(
            builder: (context) => SettingsDisplayImagesThemingScreen(),
            settings:
                const RouteSettings(name: '/settings/display_images/theming'),
          );
          var _ = Navigator.push(context, route);
        },
      ),
      ListTile(
        title: Text(context.loc.settingsDisplayImagesCaptionsTitle),
        subtitle: Text(context.loc.settingsDisplayImagesCaptionsSubtitle),
        onTap: () {
          var route = MaterialPageRoute(
            builder: (context) => SettingsDisplayImagesCaptionScreen(),
            settings:
                const RouteSettings(name: '/settings/display_images/caption'),
          );
          var _ = Navigator.push(context, route);
        },
      ),
      SettingsHeader(context.loc.settingsDisplayImagesDetailsViewHeader),
      ListTile(
          title: Text(context.loc.settingsDisplayImagesDetailsViewMaxZoom),
          subtitle: Row(children: [
            Expanded(
                child: Slider.adaptive(
              value: min(settings.maxImageZoom, 30),
              onChanged: (v) {
                setState(() {
                  settings.maxImageZoom = v == 30 ? double.infinity : v;
                  settings.save();
                });
              },
              max: 30,
              min: 1,
              activeColor: theme.colorScheme.secondary,
              inactiveColor: theme.disabledColor,
            )),
            SizedBox(
              width: 40,
              child: settings.maxImageZoom == double.infinity
                  ? Icon(
                      Icons.all_inclusive,
                      color: theme.colorScheme.secondary,
                    )
                  : Text(
                      NumberFormat("##.0").format(settings.maxImageZoom),
                      style: theme.textTheme.subtitle2!
                          .copyWith(color: theme.colorScheme.secondary),
                      textAlign: TextAlign.center,
                    ),
            )
          ])),
      SwitchListTile(
        title: Text(
            context.loc.settingsDisplayImagesDetailsViewRotateGesturesTitle),
        subtitle: Text(
            context.loc.settingsDisplayImagesDetailsViewRotateGesturesSubtitle),
        value: settings.rotateImageGestures,
        onChanged: (bool newVal) {
          settings.rotateImageGestures = newVal;
          settings.save();
        },
      ),
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.settingsDisplayImagesTitle),
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
}
