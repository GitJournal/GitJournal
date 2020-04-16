import 'package:flutter/material.dart';
import 'package:gitjournal/screens/settings_screen.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/screens/settings_widgets.dart';

class SettingsEditorsScreen extends StatefulWidget {
  @override
  SettingsEditorsScreenState createState() => SettingsEditorsScreenState();
}

class SettingsEditorsScreenState extends State<SettingsEditorsScreen> {
  @override
  Widget build(BuildContext context) {
    var settings = Settings.instance;

    var body = ListView(children: <Widget>[
      ListPreference(
        title: "Default Editor",
        currentOption: settings.defaultEditor.toPublicString(),
        options:
            SettingsEditorType.options.map((f) => f.toPublicString()).toList(),
        onChange: (String publicStr) {
          var val = SettingsEditorType.fromPublicString(publicStr);
          Settings.instance.defaultEditor = val;
          Settings.instance.save();
          setState(() {});
        },
      ),
      SettingsHeader("Markdown Editor Settings"),
      ListPreference(
        title: "Default State",
        currentOption: settings.markdownDefaultView.toPublicString(),
        options: SettingsMarkdownDefaultView.options
            .map((f) => f.toPublicString())
            .toList(),
        onChange: (String publicStr) {
          var val = SettingsMarkdownDefaultView.fromPublicString(publicStr);
          Settings.instance.markdownDefaultView = val;
          Settings.instance.save();
          setState(() {});
        },
      ),
    ]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor Settings'),
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
