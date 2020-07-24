import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:gitjournal/core/md_yaml_doc_codec.dart';
import 'package:gitjournal/screens/settings_widgets.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils/datetime.dart';
import 'package:gitjournal/widgets/pro_overlay.dart';

class NoteMetadataSettingsScreen extends StatefulWidget {
  @override
  _NoteMetadataSettingsScreenState createState() =>
      _NoteMetadataSettingsScreenState();
}

class _NoteMetadataSettingsScreenState
    extends State<NoteMetadataSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    String yamlHeader = "                                      \n";
    if (Settings.instance.yamlHeaderEnabled) {
      var map = _buildMap();
      yamlHeader = MarkdownYAMLCodec.toYamlHeader(map).trim();
    }

    var body = Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            tr("settings.noteMetaData.text"),
            style: textTheme.bodyText1,
          ),
        ),
        const SizedBox(height: 16.0),
        NoteMetaDataExample(yamlHeader),
        const SizedBox(height: 16.0),
        const Divider(),
        SwitchListTile(
          title: Text(tr("settings.noteMetaData.enableHeader")),
          value: Settings.instance.yamlHeaderEnabled,
          onChanged: (bool newVal) {
            setState(() {
              Settings.instance.yamlHeaderEnabled = newVal;
              Settings.instance.save();
            });
          },
        ),
        ProOverlay(
          child: ListPreference(
            title: tr("settings.noteMetaData.modified"),
            options: [
              "modified",
              "mod",
              "lastmodified",
              "lastmod",
            ],
            currentOption: Settings.instance.yamlModifiedKey,
            onChange: (String newVal) {
              setState(() {
                Settings.instance.yamlModifiedKey = newVal;
                Settings.instance.save();
              });
            },
            enabled: Settings.instance.yamlHeaderEnabled,
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(tr("settings.noteMetaData.title")),
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

  Map<String, dynamic> _buildMap() {
    var created = DateTime.now();
    return {
      'created': toIso8601WithTimezone(created),
      Settings.instance.yamlModifiedKey: toIso8601WithTimezone(created),
      'title': tr("settings.noteMetaData.example.title"),
    };
  }
}

class NoteMetaDataExample extends StatelessWidget {
  final String yamlHeader;

  NoteMetaDataExample(this.yamlHeader);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.subtitle1;
    style = style.copyWith(fontFamily: "Roboto Mono");

    return Container(
      color: theme.highlightColor,
      child: Text(yamlHeader, style: style),
      padding: const EdgeInsets.all(0),
    );
  }
}
