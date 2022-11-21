/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/app_localizations_context.dart';

class AppDrawerSettings extends StatefulWidget {
  @override
  _AppDrawerSettingsState createState() => _AppDrawerSettingsState();
}

class _AppDrawerSettingsState extends State<AppDrawerSettings> {
  @override
  Widget build(BuildContext context) {
    var body = Container();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.settingsDrawerTitle),
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
