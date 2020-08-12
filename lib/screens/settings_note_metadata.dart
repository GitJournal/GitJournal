import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/md_yaml_doc.dart';
import 'package:gitjournal/core/md_yaml_doc_codec.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/note_serializer.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/editors/note_body_editor.dart';
import 'package:gitjournal/editors/note_title_editor.dart';
import 'package:gitjournal/features.dart';
import 'package:gitjournal/screens/settings_widgets.dart';
import 'package:gitjournal/settings.dart';
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
    var settings = Provider.of<Settings>(context);

    var parent = NotesFolderFS(null, '');
    var note = Note(parent, "fileName.md");
    note.title = tr("settings.noteMetaData.exampleTitle");
    note.body = tr("settings.noteMetaData.exampleBody");
    note.created = DateTime.now().add(const Duration(days: -1));
    note.modified = DateTime.now();
    note.tags = {
      tr("settings.noteMetaData.exampleTag1"),
      tr("settings.noteMetaData.exampleTag2"),
    };

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
        NoteInputExample(note),
        const SizedBox(height: 16.0),
        NoteOutputExample(note),
        const SizedBox(height: 16.0),
        const Divider(),
        SwitchListTile(
          title: Text(tr("settings.noteMetaData.enableHeader")),
          value: settings.yamlHeaderEnabled,
          onChanged: (bool newVal) {
            setState(() {
              settings.yamlHeaderEnabled = newVal;
              if (newVal == false) {
                settings.saveTitleInH1 = true;
              }
              settings.save();
            });
          },
        ),
        ProOverlay(
          feature: Feature.yamlModifiedKey,
          child: ListPreference(
            title: tr("settings.noteMetaData.modified"),
            options: [
              "modified",
              "mod",
              "lastmodified",
              "lastmod",
            ],
            currentOption: settings.yamlModifiedKey,
            onChange: (String newVal) {
              setState(() {
                settings.yamlModifiedKey = newVal;
                settings.save();
              });
            },
            enabled: settings.yamlHeaderEnabled,
          ),
        ),
        ProOverlay(
          feature: Feature.yamlCreatedKey,
          child: ListPreference(
            title: tr("settings.noteMetaData.created"),
            options: [
              "created",
              "date",
            ],
            currentOption: settings.yamlCreatedKey,
            onChange: (String newVal) {
              setState(() {
                settings.yamlCreatedKey = newVal;
                settings.save();
              });
            },
            enabled: settings.yamlHeaderEnabled,
          ),
        ),
        ProOverlay(
          feature: Feature.yamlTagsKey,
          child: ListPreference(
            title: tr("settings.noteMetaData.tags"),
            options: [
              "tags",
              "categories",
            ],
            currentOption: settings.yamlTagsKey,
            onChange: (String newVal) {
              setState(() {
                settings.yamlTagsKey = newVal;
                settings.save();
              });
            },
            enabled: settings.yamlHeaderEnabled,
          ),
        ),
        ProOverlay(
          feature: Feature.metaDataTitle,
          child: ListPreference(
            title: tr("settings.noteMetaData.titleMetaData.title"),
            options: [
              tr("settings.noteMetaData.titleMetaData.fromH1"),
              if (settings.yamlHeaderEnabled)
                tr("settings.noteMetaData.titleMetaData.fromYaml"),
            ],
            currentOption: settings.saveTitleInH1
                ? tr("settings.noteMetaData.titleMetaData.fromH1")
                : tr("settings.noteMetaData.titleMetaData.fromYaml"),
            onChange: (String newVal) {
              setState(() {
                settings.saveTitleInH1 =
                    newVal == tr("settings.noteMetaData.titleMetaData.fromH1");
                settings.save();
              });
            },
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
      body: SingleChildScrollView(child: body),
    );
  }
}

class NoteOutputExample extends StatelessWidget {
  final Note note;

  NoteOutputExample(this.note);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.subtitle1;
    style = style.copyWith(fontFamily: "Roboto Mono");

    var doc = MdYamlDoc();
    var settings = Provider.of<Settings>(context);
    NoteSerializer.fromSettings(settings).encode(note, doc);

    var codec = MarkdownYAMLCodec();
    var noteStr = codec.encode(doc);

    return Container(
      color: theme.highlightColor,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(noteStr, style: style),
          ),
          _HeaderText(note.fileName, Alignment.topRight),
          _HeaderText("Output", Alignment.topLeft),
        ],
      ),
    );
  }
}

class NoteInputExample extends StatelessWidget {
  final Note note;

  NoteInputExample(this.note);

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController(text: note.title);
    final bodyController = TextEditingController(text: note.body);

    var theme = Theme.of(context);

    return IgnorePointer(
      child: Container(
        color: theme.highlightColor,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: <Widget>[
                  NoteTitleEditor(titleController, () {}),
                  NoteBodyEditor(
                    textController: bodyController,
                    autofocus: false,
                    onChanged: () {},
                  ),
                  Container(height: 8.0),
                  TagsWidget(note.tags),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
            _HeaderText(note.fileName, Alignment.topRight),
            _HeaderText("Input", Alignment.topLeft),
          ],
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  final Alignment alignment;

  _HeaderText(this.text, this.alignment);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(text, style: textTheme.caption),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;

  _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          const BoxShadow(color: Colors.grey, spreadRadius: 1),
        ],
      ),
      padding: const EdgeInsets.all(8.0),
      child: Text(text, style: theme.textTheme.button),
    );
  }
}

class TagsWidget extends StatelessWidget {
  final Set<String> tags;

  TagsWidget(this.tags);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        for (var tagText in tags) _Tag(tagText),
      ],
      alignment: WrapAlignment.start,
      spacing: 8.0,
      runSpacing: 8.0,
    );
  }
}
