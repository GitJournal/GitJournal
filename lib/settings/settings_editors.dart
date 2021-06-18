import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/features.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/settings_screen.dart';
import 'package:gitjournal/settings/settings_widgets.dart';
import 'package:gitjournal/utils/utils.dart';
import 'package:gitjournal/widgets/folder_selection_dialog.dart';
import 'package:gitjournal/widgets/pro_overlay.dart';

class SettingsEditorsScreen extends StatefulWidget {
  @override
  SettingsEditorsScreenState createState() => SettingsEditorsScreenState();
}

class SettingsEditorsScreenState extends State<SettingsEditorsScreen> {
  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<Settings>(context);
    var defaultNewFolder = settings.journalEditordefaultNewNoteFolderSpec;
    if (defaultNewFolder.isEmpty) {
      defaultNewFolder = tr("rootFolder");
    } else {
      if (!folderWithSpecExists(context, defaultNewFolder)) {
        setState(() {
          defaultNewFolder = tr("rootFolder");

          settings.journalEditordefaultNewNoteFolderSpec = "";
          settings.save();
        });
      }
    }

    var body = ListView(children: <Widget>[
      ListPreference(
        title: tr("settings.editors.defaultEditor"),
        currentOption: settings.defaultEditor.toPublicString(),
        options:
            SettingsEditorType.options.map((f) => f.toPublicString()).toList(),
        onChange: (String publicStr) {
          var val = SettingsEditorType.fromPublicString(publicStr);
          settings.defaultEditor = val;
          settings.save();
          setState(() {});
        },
      ),
      //SettingsHeader(tr("settings.editors.markdownEditor")),
      ListPreference(
        title: tr("settings.editors.defaultState"),
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
      SettingsHeader(tr("settings.editors.journalEditor")),
      ProOverlay(
        feature: Feature.journalEditorDefaultFolder,
        child: ListTile(
          title: Text(tr("settings.editors.defaultFolder")),
          subtitle: Text(defaultNewFolder),
          onTap: () async {
            var destFolder = await showDialog<NotesFolderFS>(
              context: context,
              builder: (context) => FolderSelectionDialog(),
            );

            settings.journalEditordefaultNewNoteFolderSpec =
                destFolder != null ? destFolder.pathSpec() : "";
            settings.save();
            setState(() {});
          },
        ),
      ),
      ProOverlay(
        feature: Feature.singleJournalEntry,
        child: SwitchListTile(
          title: Text(tr("feature.singleJournalEntry")),
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
          title: tr('settings.note.newNoteFileName'),
          currentOption: settings.journalNoteFileNameFormat.toPublicString(),
          options: NoteFileNameFormat.options
              .map((f) => f.toPublicString())
              .toList(),
          onChange: (String publicStr) {
            var format = NoteFileNameFormat.fromPublicString(publicStr);
            settings.journalNoteFileNameFormat = format;
            settings.save();
            setState(() {});
          },
        ),
      ),
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr("settings.editors.title")),
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
