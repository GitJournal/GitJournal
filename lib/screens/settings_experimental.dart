import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:gitjournal/settings.dart';

class ExperimentalSettingsScreen extends StatefulWidget {
  @override
  _ExperimentalSettingsScreenState createState() =>
      _ExperimentalSettingsScreenState();
}

class _ExperimentalSettingsScreenState
    extends State<ExperimentalSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    var settings = Settings.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('settings.experimental.title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Scrollbar(
        child: ListView(
          children: <Widget>[
            SwitchListTile(
              title: Text(tr('settings.experimental.backlinks')),
              value: settings.experimentalBacklinks,
              onChanged: (bool newVal) {
                settings.experimentalBacklinks = newVal;
                settings.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title: Text(tr('settings.experimental.fs')),
              value: settings.experimentalFs,
              onChanged: (bool newVal) {
                settings.experimentalFs = newVal;
                settings.save();
                setState(() {});
              },
            ),
          ],
          padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
        ),
      ),
    );
  }
}
