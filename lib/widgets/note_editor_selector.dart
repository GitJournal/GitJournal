// @dart=2.9

/*
Copyright 2020-2021 Vishesh Handa <me@vhanda.in>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/screens/note_editor.dart';

class NoteEditorSelector extends StatelessWidget {
  final EditorType currentEditor;
  final NoteFileFormat fileFormat;

  NoteEditorSelector(this.currentEditor, this.fileFormat);

  @override
  Widget build(BuildContext context) {
    var list = Column(
      children: <Widget>[
        if (fileFormat == NoteFileFormat.Markdown)
          _buildTile(
            context,
            EditorType.Markdown,
            tr('settings.editors.markdownEditor'),
            FontAwesomeIcons.markdown,
          ),
        _buildTile(
          context,
          EditorType.Raw,
          tr('settings.editors.rawEditor'),
          FontAwesomeIcons.dna,
        ),
        _buildTile(
          context,
          EditorType.Checklist,
          tr('settings.editors.checklistEditor'),
          FontAwesomeIcons.tasks,
        ),
        _buildTile(
          context,
          EditorType.Journal,
          tr('settings.editors.journalEditor'),
          FontAwesomeIcons.book,
        ),
        // FIXME: Do not show this editor, unless the file is an org file?
        _buildTile(
          context,
          EditorType.Org,
          tr('settings.editors.orgEditor'),
          FontAwesomeIcons.horseHead,
        )
      ],
      mainAxisSize: MainAxisSize.min,
    );

    return AlertDialog(
      title: Text(tr('settings.editors.choose')),
      content: list,
    );
  }

  ListTile _buildTile(
    BuildContext context,
    EditorType et,
    String text,
    IconData iconData,
  ) {
    var selected = et == currentEditor;
    var theme = Theme.of(context);
    var listTileTheme = ListTileTheme.of(context);
    var textStyle = theme.textTheme.bodyText2.copyWith(
      color: selected ? theme.primaryColor : listTileTheme.textColor,
    );

    return ListTile(
      title: Text(text),
      leading: FaIcon(iconData, color: textStyle.color),
      onTap: () => Navigator.of(context).pop(et),
      selected: selected,
    );
  }
}
