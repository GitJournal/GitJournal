/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/settings/widgets/settings_header.dart';

class SettingsTagsScreen extends StatefulWidget {
  static const routePath = '/settings/tags';

  const SettingsTagsScreen({Key? key}) : super(key: key);

  @override
  SettingsTagsScreenState createState() => SettingsTagsScreenState();
}

class SettingsTagsScreenState extends State<SettingsTagsScreen> {
  @override
  Widget build(BuildContext context) {
    var folderConfig = Provider.of<NotesFolderConfig>(context);

    var body = ListView(children: <Widget>[
      SettingsHeader(tr("settings.tags.prefixes")),
      SwitchListTile(
        title: const Text('#'),
        value: folderConfig.inlineTagPrefixes.contains('#'),
        onChanged: (bool newVal) {
          setState(() {
            if (newVal) {
              var _ = folderConfig.inlineTagPrefixes.add('#');
            } else {
              var _ = folderConfig.inlineTagPrefixes.remove('#');
            }
            folderConfig.save();
          });
        },
      ),
      SwitchListTile(
        title: const Text('@'),
        value: folderConfig.inlineTagPrefixes.contains('@'),
        onChanged: (bool newVal) {
          setState(() {
            if (newVal) {
              var _ = folderConfig.inlineTagPrefixes.add('@');
            } else {
              var _ = folderConfig.inlineTagPrefixes.remove('@');
            }
            folderConfig.save();
          });
        },
      ),
      SwitchListTile(
        title: const Text('+'),
        value: folderConfig.inlineTagPrefixes.contains('+'),
        onChanged: (bool newVal) {
          setState(() {
            if (newVal) {
              var _ = folderConfig.inlineTagPrefixes.add('+');
            } else {
              var _ = folderConfig.inlineTagPrefixes.remove('+');
            }
            folderConfig.save();
          });
        },
      ),
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr("settings.tags.title")),
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
