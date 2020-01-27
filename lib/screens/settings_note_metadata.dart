import 'package:flutter/material.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils/datetime.dart';
import 'package:gitjournal/screens/settings_widgets.dart';
import 'package:gitjournal/core/note_data_serializers.dart';

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

    var body = Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Every note has some metadata which is stored in a YAML Header as follows -",
            style: textTheme.body2,
          ),
        ),
        const SizedBox(height: 16.0),
        NoteMetaDataExample(_buildMap()),
        const SizedBox(height: 16.0),
        const Divider(),
        ListPreference(
          title: "Modified Field",
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
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Metadata Settings'),
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
      'title': 'Example Title',
    };
  }
}

class NoteMetaDataExample extends StatelessWidget {
  final String yamlHeader;

  NoteMetaDataExample(Map<String, dynamic> data)
      : yamlHeader = MarkdownYAMLSerializer.toYamlHeader(data);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.subhead;
    style = style.copyWith(fontFamily: "Roboto Mono");

    return Container(
      color: theme.highlightColor,
      child: Text(yamlHeader, style: style),
      padding: const EdgeInsets.all(0),
    );
  }
}
