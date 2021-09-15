/*
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:function_types/function_types.dart';
import 'package:provider/provider.dart';
import 'package:time/time.dart';

import 'package:gitjournal/core/md_yaml_doc.dart';
import 'package:gitjournal/core/md_yaml_doc_codec.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/note_serializer.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/editors/note_body_editor.dart';
import 'package:gitjournal/editors/note_title_editor.dart';
import 'package:gitjournal/features.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/settings_widgets.dart';
import 'package:gitjournal/widgets/pro_overlay.dart';

class NoteMetadataSettingsScreen extends StatefulWidget {
  @override
  _NoteMetadataSettingsScreenState createState() =>
      _NoteMetadataSettingsScreenState();
}

class _NoteMetadataSettingsScreenState
    extends State<NoteMetadataSettingsScreen> {
  late DateTime created;
  late DateTime modified;

  @override
  void initState() {
    super.initState();

    created = DateTime.now().subtract(1.days);
    modified = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var settings = Provider.of<Settings>(context);
    var folderConfig = Provider.of<NotesFolderConfig>(context);

    var parent = NotesFolderFS(null, '', folderConfig);
    var note = Note(parent, "fileName.md", DateTime.now());
    note.title = tr("settings.noteMetaData.exampleTitle");
    note.body = tr("settings.noteMetaData.exampleBody");
    note.created = created;
    note.modified = modified;
    note.tags = {
      tr("settings.noteMetaData.exampleTag1"),
      tr("settings.noteMetaData.exampleTag2"),
    };

    if (settings.customMetaData != "") {
      var customMetaDataMap =
          MarkdownYAMLCodec.parseYamlText(settings.customMetaData);
      if (customMetaDataMap.isNotEmpty) {
        note.extraProps = customMetaDataMap;
      }
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
        NoteInputExample(note),
        const SizedBox(height: 16.0),
        NoteOutputExample(note),
        const SizedBox(height: 16.0),
        const Divider(),
        SwitchListTile(
          title: Text(tr("settings.noteMetaData.enableHeader")),
          value: folderConfig.yamlHeaderEnabled,
          onChanged: (bool newVal) {
            setState(() {
              folderConfig.yamlHeaderEnabled = newVal;
              var titleInYaml =
                  folderConfig.titleSettings == SettingsTitle.InYaml;
              if (newVal == false && titleInYaml) {
                folderConfig.titleSettings = SettingsTitle.Default;
              }
              folderConfig.save();
            });
          },
        ),
        ListPreference(
          title: tr("settings.noteMetaData.modified"),
          options: [
            "modified",
            "mod",
            "lastmodified",
            "lastmod",
            "updated",
          ],
          currentOption: folderConfig.yamlModifiedKey,
          onChange: (String newVal) {
            setState(() {
              folderConfig.yamlModifiedKey = newVal;
              folderConfig.save();
            });
          },
          enabled: folderConfig.yamlHeaderEnabled,
        ),
        ListPreference(
          title: tr("settings.noteMetaData.created"),
          options: [
            "created",
            "date",
          ],
          currentOption: folderConfig.yamlCreatedKey,
          onChange: (String newVal) {
            setState(() {
              folderConfig.yamlCreatedKey = newVal;
              folderConfig.save();
            });
          },
          enabled: folderConfig.yamlHeaderEnabled,
        ),
        ListPreference(
          title: tr("settings.noteMetaData.tags"),
          options: [
            "tags",
            "categories",
            "keywords",
          ],
          currentOption: folderConfig.yamlTagsKey,
          onChange: (String newVal) {
            setState(() {
              folderConfig.yamlTagsKey = newVal;
              folderConfig.save();
            });
          },
          enabled: folderConfig.yamlHeaderEnabled,
        ),
        ListPreference(
          title: tr("settings.noteMetaData.titleMetaData.title"),
          options:
              SettingsTitle.options.map((f) => f.toPublicString()).toList(),
          currentOption: folderConfig.titleSettings.toPublicString(),
          onChange: (String publicStr) {
            var format = SettingsTitle.fromPublicString(publicStr);
            folderConfig.titleSettings = format;
            folderConfig.save();
            setState(() {});
          },
        ),
        ProOverlay(
          feature: Feature.customMetaData,
          child: CustomMetDataTile(
            value: settings.customMetaData,
            onChange: (String newVal) {
              setState(() {
                settings.customMetaData = newVal;
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
    var style = theme.textTheme.subtitle1!;
    style = style.copyWith(fontFamily: "Roboto Mono");

    var doc = MdYamlDoc();
    var folderConfig = Provider.of<NotesFolderConfig>(context);
    var serialSettings = NoteSerializationSettings.fromConfig(folderConfig);
    NoteSerializer.fromConfig(serialSettings).encode(note, doc);

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

class CustomMetDataTile extends StatefulWidget {
  final String value;
  final Func1<String, void> onChange;

  CustomMetDataTile({required this.value, required this.onChange});

  @override
  _CustomMetDataTileState createState() => _CustomMetDataTileState();
}

class _CustomMetDataTileState extends State<CustomMetDataTile> {
  TextEditingController? _textController;

  @override
  void initState() {
    _textController = TextEditingController(text: widget.value);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /*
    var settings = Provider.of<Settings>(context);
    settings.customMetaData = "draft: true";
    settings.save();
    */

    return ListTile(
      title: Text(tr("settings.noteMetaData.customMetaData.title")),
      subtitle: Text(widget.value),
      onTap: () async {
        var val =
            await showDialog<String>(context: context, builder: _buildDialog);

        val ??= "";
        if (val != widget.value) {
          widget.onChange(val);
        }
      },
    );
  }

  Widget _buildDialog(BuildContext context) {
    var form = Form(
      child: TextFormField(
        validator: (value) {
          value = value!.trim();
          if (value.isEmpty) {
            return "";
          }

          var map = MarkdownYAMLCodec.parseYamlText(value);
          if (map.isEmpty) {
            return tr("settings.noteMetaData.customMetaData.invalid");
          }
          return "";
        },
        autofocus: true,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.words,
        controller: _textController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        maxLines: null,
        minLines: null,
      ),
    );

    return AlertDialog(
      title: Text(tr("settings.noteMetaData.customMetaData.title")),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(widget.value),
          child: Text(tr("settings.cancel")),
        ),
        TextButton(
          onPressed: () {
            var text = _textController!.text.trim();
            var map = MarkdownYAMLCodec.parseYamlText(text);
            if (map.isEmpty) {
              return Navigator.of(context).pop();
            }

            return Navigator.of(context).pop(text);
          },
          child: Text(tr("settings.ok")),
        ),
      ],
      content: form,
    );
  }
}
