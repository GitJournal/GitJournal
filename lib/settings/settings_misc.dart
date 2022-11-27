/*
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/widgets/settings_header.dart';
import 'package:provider/provider.dart';

class SettingsMisc extends StatefulWidget {
  static const routePath = '/settings/misc';

  @override
  _SettingsMiscState createState() => _SettingsMiscState();
}

class _SettingsMiscState extends State<SettingsMisc> {
  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<Settings>(context);
    var folderConfig = Provider.of<NotesFolderConfig>(context);

    var body = Column(
      children: <Widget>[
        SettingsHeader(context.loc.settingsMiscListView),
        SwitchListTile(
          title: Text(context.loc.settingsMiscSwipe),
          value: settings.swipeToDelete,
          onChanged: (bool newVal) {
            settings.swipeToDelete = newVal;
            settings.save();
          },
        ),
        SwitchListTile(
          title: Text(context.loc.settingsMiscConfirmDelete),
          value: settings.confirmDelete,
          onChanged: (bool newVal) {
            settings.confirmDelete = newVal;
            settings.save();
          },
        ),
        SwitchListTile(
          title: Text(context.loc.settingsMiscHardWrap),
          value: settings.hardWrap,
          onChanged: (bool newVal) {
            settings.hardWrap = newVal;
            settings.save();
          },
        ),
        SwitchListTile(
          title: Text(context.loc.settingsMiscEmoji),
          value: folderConfig.emojify,
          onChanged: (bool newVal) {
            folderConfig.emojify = newVal;
            folderConfig.save();
          },
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.settingsMiscTitle),
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
