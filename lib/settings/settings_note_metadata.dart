/*
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:function_types/function_types.dart';
import 'package:gitjournal/core/file/file.dart';
import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/markdown/md_yaml_doc_codec.dart';
import 'package:gitjournal/core/markdown/md_yaml_note_serializer.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes/note.dart';
import 'package:gitjournal/editors/note_body_editor.dart';
import 'package:gitjournal/editors/note_title_editor.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/widgets/settings_list_preference.dart';
import 'package:gitjournal/widgets/pro_overlay.dart';
import 'package:provider/provider.dart';
import 'package:time/time.dart';

class NoteMetadataSettingsScreen extends StatefulWidget {
  static const routePath = '/settings/noteMetaData';

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

    var extraProps = <String, dynamic>{};
    if (settings.customMetaData != "") {
      var customMetaDataMap =
          MarkdownYAMLCodec.parseYamlText(settings.customMetaData);
      if (customMetaDataMap.isNotEmpty) {
        extraProps = customMetaDataMap.unlock;
      }
    }

    var repo = context.read<GitJournalRepo>();
    var parent = NotesFolderFS.root(folderConfig, repo.fileStorage);
    var note = Note.build(
      title: context.loc.settingsNoteMetaDataExampleTitle,
      body: context.loc.settingsNoteMetaDataExampleBody,
      parent: parent,
      fileFormat: NoteFileFormat.Markdown,
      noteType: NoteType.Unknown,
      file: File.virtual(
        created: created,
        modified: modified,
      ),
      created: created,
      modified: modified,
      extraProps: extraProps,
      tags: ISet<String>({
        context.loc.settingsNoteMetaDataExampleTag1,
        context.loc.settingsNoteMetaDataExampleTag2,
      }),
      propsList: extraProps.keys.toIList(),
      serializerSettings: NoteSerializationSettings.fromConfig(parent.config),
    );

    var body = Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            context.loc.settingsNoteMetaDataText,
            style: textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 16.0),
        NoteInputExample(note),
        const SizedBox(height: 16.0),
        NoteOutputExample(note),
        const SizedBox(height: 16.0),
        const Divider(),
        SwitchListTile(
          title: Text(context.loc.settingsNoteMetaDataEnableHeader),
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
            title: context.loc.settingsNoteMetaDataUnixTimestampMagnitude,
            options: NoteSerializationUnixTimestampMagnitude.options
                .map((m) => m.toPublicString(context))
                .toList(),
            currentOption:
                folderConfig.yamlUnixTimestampMagnitude.toPublicString(context),
            onChange: (String publicStr) {
              setState(() {
                var newVal =
                    NoteSerializationUnixTimestampMagnitude.fromPublicString(
                        context, publicStr);
                folderConfig.yamlUnixTimestampMagnitude = newVal;
                folderConfig.save();
              });
            }),
        ListPreference(
          title: context.loc.settingsNoteMetaDataModified,
          options: NoteSerializer.modifiedKeyOptions,
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
          title: context.loc.settingsNoteMetaDataModifiedFormat,
          options: NoteSerializationDateFormat.options
              .map((f) => f.toPublicString(context))
              .toList(),
          currentOption:
              folderConfig.yamlModifiedFormat.toPublicString(context),
          onChange: (String publicStr) {
            setState(() {
              var newVal = NoteSerializationDateFormat.fromPublicString(
                  context, publicStr);
              folderConfig.yamlModifiedFormat = newVal;
              folderConfig.save();
            });
          },
          enabled: folderConfig.yamlHeaderEnabled,
        ),
        ListPreference(
          title: context.loc.settingsNoteMetaDataCreated,
          options: NoteSerializer.createdKeyOptions,
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
          title: context.loc.settingsNoteMetaDataCreatedFormat,
          options: NoteSerializationDateFormat.options
              .map((f) => f.toPublicString(context))
              .toList(),
          currentOption: folderConfig.yamlCreatedFormat.toPublicString(context),
          onChange: (String publicStr) {
            setState(() {
              var newVal = NoteSerializationDateFormat.fromPublicString(
                  context, publicStr);
              folderConfig.yamlCreatedFormat = newVal;
              folderConfig.save();
            });
          },
          enabled: folderConfig.yamlHeaderEnabled,
        ),
        ListPreference(
          title: context.loc.settingsNoteMetaDataTags,
          options: NoteSerializer.tagKeyOptions,
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
          title: context.loc.settingsNoteMetaDataEditorType,
          options: NoteSerializer.editorTypeKeyOptions,
          currentOption: folderConfig.yamlEditorTypeKey,
          onChange: (String newVal) {
            setState(() {
              folderConfig.yamlEditorTypeKey = newVal;
              folderConfig.save();
            });
          },
          enabled: folderConfig.yamlHeaderEnabled,
        ),
        ListPreference(
          title: context.loc.settingsNoteMetaDataTitleMetaDataTitle,
          options: SettingsTitle.options
              .map((f) => f.toPublicString(context))
              .toList(),
          currentOption: folderConfig.titleSettings.toPublicString(context),
          onChange: (String publicStr) {
            var format = SettingsTitle.fromPublicString(context, publicStr);
            folderConfig.titleSettings = format;
            folderConfig.save();
            setState(() {});
          },
        ),
        ProOverlay(
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
        title: Text(context.loc.settingsNoteMetaDataTitle),
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

  const NoteOutputExample(this.note);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.titleMedium!;
    style = style.copyWith(fontFamily: "Roboto Mono");

    var folderConfig = Provider.of<NotesFolderConfig>(context);
    var serialSettings = NoteSerializationSettings.fromConfig(folderConfig);
    var doc = NoteSerializer.fromConfig(serialSettings).encode(note);

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
          _HeaderText(
            context.loc.settingsNoteMetaDataOutput,
            Alignment.topLeft,
          ),
        ],
      ),
    );
  }
}

class NoteInputExample extends StatelessWidget {
  final Note note;

  const NoteInputExample(this.note);

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  NoteTitleEditor(titleController, () {}),
                  NoteBodyEditor(
                    textController: bodyController,
                    autofocus: false,
                    onChanged: () {},
                  ),
                  Container(height: 8.0),
                  TagsWidget(note.tags.toSet()),
                ],
              ),
            ),
            _HeaderText(note.fileName, Alignment.topRight),
            _HeaderText(
              context.loc.settingsNoteMetaDataInput,
              Alignment.topLeft,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  final Alignment alignment;

  const _HeaderText(this.text, this.alignment);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(text, style: textTheme.bodySmall),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;

  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: theme.scaffoldBackgroundColor,
        boxShadow: const [
          BoxShadow(color: Colors.grey, spreadRadius: 1),
        ],
      ),
      padding: const EdgeInsets.all(8.0),
      child: Text(text, style: theme.textTheme.labelLarge),
    );
  }
}

class TagsWidget extends StatelessWidget {
  final Set<String> tags;

  const TagsWidget(this.tags);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        for (var tagText in tags) _Tag(tagText),
      ],
    );
  }
}

class CustomMetDataTile extends StatefulWidget {
  final String value;
  final Func1<String, void> onChange;

  const CustomMetDataTile({required this.value, required this.onChange});

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
    return ListTile(
      title: Text(context.loc.settingsNoteMetaDataCustomMetaDataTitle),
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
            return context.loc.settingsNoteMetaDataCustomMetaDataInvalid;
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
      title: Text(context.loc.settingsNoteMetaDataCustomMetaDataTitle),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(widget.value),
          child: Text(context.loc.settingsCancel),
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
          child: Text(context.loc.settingsOk),
        ),
      ],
      content: form,
    );
  }
}
