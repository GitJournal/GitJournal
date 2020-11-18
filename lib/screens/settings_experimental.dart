import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/app_settings.dart';

class ExperimentalSettingsScreen extends StatefulWidget {
  @override
  _ExperimentalSettingsScreenState createState() =>
      _ExperimentalSettingsScreenState();
}

class _ExperimentalSettingsScreenState
    extends State<ExperimentalSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    var appSettings = Provider.of<AppSettings>(context);

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
              title: Text(tr('settings.experimental.fs')),
              value: appSettings.experimentalFs,
              onChanged: (bool newVal) {
                appSettings.experimentalFs = newVal;
                appSettings.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title: Text(tr('settings.experimental.graphView')),
              value: appSettings.experimentalGraphView,
              onChanged: (bool newVal) {
                appSettings.experimentalGraphView = newVal;
                appSettings.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title: Text(tr('settings.experimental.markdownToolbar')),
              value: appSettings.experimentalMarkdownToolbar,
              onChanged: (bool newVal) {
                appSettings.experimentalMarkdownToolbar = newVal;
                appSettings.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title: Text(tr('settings.experimental.accounts')),
              value: appSettings.experimentalAccounts,
              onChanged: (bool newVal) {
                appSettings.experimentalAccounts = newVal;
                appSettings.save();
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
