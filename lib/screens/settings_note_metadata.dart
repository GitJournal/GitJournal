import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:gitjournal/core/md_yaml_doc.dart';

import 'package:gitjournal/core/md_yaml_doc_codec.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/note_serializer.dart';
import 'package:gitjournal/editors/note_body_editor.dart';
import 'package:gitjournal/editors/note_title_editor.dart';
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

    var note = Note(null, "fileName.md");
    note.title = tr("settings.noteMetaData.exampleTitle");
    note.body = tr("settings.noteMetaData.exampleBody");
    note.created = DateTime.now().add(const Duration(days: -1));
    note.modified = DateTime.now();

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
          value: Settings.instance.yamlHeaderEnabled,
          onChanged: (bool newVal) {
            setState(() {
              Settings.instance.yamlHeaderEnabled = newVal;
              if (newVal == false) {
                Settings.instance.saveTitleInH1 = true;
              }
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
        ProOverlay(
          child: ListPreference(
            title: tr("settings.noteMetaData.titleMetaData.title"),
            options: [
              tr("settings.noteMetaData.titleMetaData.fromH1"),
              if (Settings.instance.yamlHeaderEnabled)
                tr("settings.noteMetaData.titleMetaData.fromYaml"),
            ],
            currentOption: Settings.instance.saveTitleInH1
                ? tr("settings.noteMetaData.titleMetaData.fromH1")
                : tr("settings.noteMetaData.titleMetaData.fromYaml"),
            onChange: (String newVal) {
              setState(() {
                Settings.instance.saveTitleInH1 =
                    newVal == tr("settings.noteMetaData.titleMetaData.fromH1");
                Settings.instance.save();
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
    NoteSerializer().encode(note, doc);

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
                ],
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
