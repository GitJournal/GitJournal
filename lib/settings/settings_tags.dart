import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/settings_screen.dart';

class SettingsTagsScreen extends StatefulWidget {
  @override
  SettingsTagsScreenState createState() => SettingsTagsScreenState();
}

class SettingsTagsScreenState extends State<SettingsTagsScreen> {
  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<Settings>(context);

    var body = ListView(children: <Widget>[
      SettingsHeader(tr("settings.tags.prefixes")),
      SwitchListTile(
        title: const Text('#'),
        value: settings.inlineTagPrefixes.contains('#'),
        onChanged: (bool newVal) {
          setState(() {
            if (newVal) {
              settings.inlineTagPrefixes.add('#');
            } else {
              settings.inlineTagPrefixes.remove('#');
            }
            settings.save();
          });
        },
      ),
      SwitchListTile(
        title: const Text('@'),
        value: settings.inlineTagPrefixes.contains('@'),
        onChanged: (bool newVal) {
          setState(() {
            if (newVal) {
              settings.inlineTagPrefixes.add('@');
            } else {
              settings.inlineTagPrefixes.remove('@');
            }
            settings.save();
          });
        },
      ),
      SwitchListTile(
        title: const Text('+'),
        value: settings.inlineTagPrefixes.contains('+'),
        onChanged: (bool newVal) {
          setState(() {
            if (newVal) {
              settings.inlineTagPrefixes.add('+');
            } else {
              settings.inlineTagPrefixes.remove('+');
            }
            settings.save();
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
