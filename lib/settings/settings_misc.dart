/*
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/widgets/settings_header.dart';

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
        SettingsHeader(tr(LocaleKeys.settings_misc_listView)),
        SwitchListTile(
          title: Text(tr(LocaleKeys.settings_misc_swipe)),
          value: settings.swipeToDelete,
          onChanged: (bool newVal) {
            settings.swipeToDelete = newVal;
            settings.save();
          },
        ),
        SwitchListTile(
          title: Text(tr(LocaleKeys.settings_misc_confirmDelete)),
          value: settings.confirmDelete,
          onChanged: (bool newVal) {
            settings.confirmDelete = newVal;
            settings.save();
          },
        ),
        SwitchListTile(
          title: Text(tr(LocaleKeys.settings_misc_hardWrap)),
          value: settings.hardWrap,
          onChanged: (bool newVal) {
            settings.hardWrap = newVal;
            settings.save();
          },
        ),
        SwitchListTile(
          title: Text(tr(LocaleKeys.settings_misc_emoji)),
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
        title: Text(tr(LocaleKeys.settings_misc_title)),
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
