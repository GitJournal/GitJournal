/*
Copyright 2020-2021 Vishesh Handa <me@vhanda.in>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/notes_folder_config.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/settings_screen.dart';

class SettingsMisc extends StatefulWidget {
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
