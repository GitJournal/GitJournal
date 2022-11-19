/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:gitjournal/app_localizations_context.dart';

import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/notes/note.dart';
import 'package:gitjournal/editors/common_types.dart';
import 'package:gitjournal/features.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/settings_storage.dart';
import 'package:gitjournal/settings/widgets/settings_header.dart';
import 'package:gitjournal/settings/widgets/settings_list_preference.dart';
import 'package:gitjournal/utils/utils.dart';
import 'package:gitjournal/widgets/folder_selection_dialog.dart';
import 'package:gitjournal/widgets/pro_overlay.dart';

class SettingsEditorsScreen extends StatefulWidget {
  static const routePath = '/settings/editors';

  @override
  SettingsEditorsScreenState createState() => SettingsEditorsScreenState();
}

class SettingsEditorsScreenState extends State<SettingsEditorsScreen> {
  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<Settings>(context);
    var folderConfig = Provider.of<NotesFolderConfig>(context);
    var defaultNewFolder = settings.journalEditordefaultNewNoteFolderSpec;
    if (defaultNewFolder.isEmpty) {
      defaultNewFolder = LocaleKeys.none.tr();
    } else {
      if (!folderWithSpecExists(context, defaultNewFolder)) {
        setState(() {
          defaultNewFolder = context.loc.rootFolder;

          settings.journalEditordefaultNewNoteFolderSpec = "";
          settings.save();
        });
      }
    }

    var body = ListView(children: <Widget>[
      const DefaultEditorTile(),
      const DefaultFileFormatTile(),
      //SettingsHeader(tr("settings.editors.markdownEditor")),
      ListPreference(
        title: context.loc.settingsEditorsDefaultState,
        currentOption: settings.markdownDefaultView.toPublicString(),
        options: SettingsMarkdownDefaultView.options
            .map((f) => f.toPublicString())
            .toList(),
        onChange: (String publicStr) {
          var val = SettingsMarkdownDefaultView.fromPublicString(publicStr);
          settings.markdownDefaultView = val;
          settings.save();
          setState(() {});
        },
      ),
      SettingsHeader(context.loc.settingsEditorsJournalEditor),
      ProOverlay(
        feature: Feature.journalEditorDefaultFolder,
        child: ListTile(
          title: Text(context.loc.settingsEditorsDefaultFolder),
          subtitle: Text(defaultNewFolder),
          onTap: () async {
            var destFolder = await showDialog<NotesFolderFS>(
              context: context,
              builder: (context) => FolderSelectionDialog(),
            );

            settings.journalEditordefaultNewNoteFolderSpec =
                destFolder != null ? destFolder.folderPath : "";
            settings.save();
            setState(() {});
          },
        ),
      ),
      ProOverlay(
        feature: Feature.singleJournalEntry,
        child: SwitchListTile(
          title: Text(context.loc.featureSingleJournalEntry),
          value: settings.journalEditorSingleNote,
          onChanged: (bool newVal) {
            settings.journalEditorSingleNote = newVal;
            settings.save();
            setState(() {});
          },
        ),
      ),
      ProOverlay(
        feature: Feature.singleJournalEntry,
        child: ListPreference(
          title: context.loc.settingsNoteNewNoteFileName,
          currentOption: folderConfig.journalFileNameFormat.toPublicString(),
          options: NoteFileNameFormat.options
              .map((f) => f.toPublicString())
              .toList(),
          onChange: (String publicStr) {
            var format = NoteFileNameFormat.fromPublicString(publicStr);
            folderConfig.journalFileNameFormat = format;
            folderConfig.save();
            setState(() {});
          },
        ),
      ),
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.settingsEditorsTitle),
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

class DefaultEditorTile extends StatelessWidget {
  const DefaultEditorTile({super.key});

  @override
  Widget build(BuildContext context) {
    var folderConfig = Provider.of<NotesFolderConfig>(context);
    var fileFormat = folderConfig.defaultFileFormat.toFileFormat();

    var options = SettingsEditorType.options
        .where((e) => editorSupported(fileFormat, e.toEditorType()))
        .toList();

    var defaultEditor = folderConfig.defaultEditor;
    if (!editorSupported(fileFormat, defaultEditor.toEditorType())) {
      var editor = NoteFileFormatInfo.defaultEditor(fileFormat);
      defaultEditor = SettingsEditorType.fromEditorType(editor);
    }

    return ListPreference(
      title: context.loc.settingsEditorsDefaultEditor,
      currentOption: defaultEditor.toPublicString(),
      options: options.map((f) => f.toPublicString()).toList(),
      onChange: (String publicStr) {
        var val = SettingsEditorType.fromPublicString(publicStr);
        folderConfig.defaultEditor = val;
        folderConfig.save();
      },
    );
  }
}
