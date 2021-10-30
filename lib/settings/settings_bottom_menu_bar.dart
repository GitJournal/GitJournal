/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/screens/home_screen.dart';
import 'package:gitjournal/settings/settings.dart';

class BottomMenuBarSettings extends StatefulWidget {
  static const routePath = '/settings/bottom_menu_bar';

  @override
  _BottomMenuBarSettingsState createState() => _BottomMenuBarSettingsState();
}

class _BottomMenuBarSettingsState extends State<BottomMenuBarSettings> {
  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<Settings>(context);

    var body = Column(
      children: [
        const SizedBox(height: 16),
        bottomMenuBar(),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(tr("settings.bottomMenuBar.enable")),
          value: settings.bottomMenuBar,
          onChanged: (bool newVal) {
            setState(() {
              settings.bottomMenuBar = newVal;
              settings.save();
            });
          },
        ),
      ],
    );

    /*
    var createButton = FloatingActionButton(
      key: const ValueKey("FAB"),
      onPressed: () => _newPost(widget.notesFolder.config.defaultEditor),
      child: const Icon(Icons.add),
    );
    */

    return Scaffold(
      appBar: AppBar(
        title: Text(tr("settings.bottomMenuBar.title")),
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

  Widget bottomMenuBar() {
    var theme = Theme.of(context);
    var mq = MediaQuery.of(context);

    var homeScreen = Transform.scale(
      scale: 0.75,
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

    return ClipRect(
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 0.12,
        child: homeScreen,
      ),
    );
  }
}
