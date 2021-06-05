import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

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

    var body = Column(
      children: <Widget>[
        SettingsHeader(tr('settings.misc.listView')),
        SwitchListTile(
          title: Text(tr('settings.misc.swipe')),
          value: settings.swipeToDelete,
          onChanged: (bool newVal) {
            settings.swipeToDelete = newVal;
            settings.save();
          },
        ),
        SwitchListTile(
          title: Text(tr('settings.misc.confirmDelete')),
          value: settings.confirmDelete,
          onChanged: (bool newVal) {
            settings.confirmDelete = newVal;
            settings.save();
          },
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(tr("settings.misc.title")),
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
