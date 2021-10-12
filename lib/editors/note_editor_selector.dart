/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/editors/common_types.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';

class NoteEditorSelector extends StatelessWidget {
  final EditorType currentEditor;
  final NoteFileFormat fileFormat;

  const NoteEditorSelector(this.currentEditor, this.fileFormat);

  @override
  Widget build(BuildContext context) {
    var list = Column(
      children: <Widget>[
        if (editorSupported(fileFormat, EditorType.Markdown))
          _buildTile(
            context,
            EditorType.Markdown,
            tr(LocaleKeys.settings_editors_markdownEditor),
            FontAwesomeIcons.markdown,
          ),
        if (editorSupported(fileFormat, EditorType.Raw))
          _buildTile(
            context,
            EditorType.Raw,
            tr(LocaleKeys.settings_editors_rawEditor),
            FontAwesomeIcons.dna,
          ),
        if (editorSupported(fileFormat, EditorType.Checklist))
          _buildTile(
            context,
            EditorType.Checklist,
            tr(LocaleKeys.settings_editors_checklistEditor),
            FontAwesomeIcons.tasks,
          ),
        if (editorSupported(fileFormat, EditorType.Journal))
          _buildTile(
            context,
            EditorType.Journal,
            tr(LocaleKeys.settings_editors_journalEditor),
            FontAwesomeIcons.book,
          ),
        if (editorSupported(fileFormat, EditorType.Org))
          _buildTile(
            context,
            EditorType.Org,
            tr(LocaleKeys.settings_editors_orgEditor),
            FontAwesomeIcons.horseHead,
          )
      ],
      mainAxisSize: MainAxisSize.min,
    );

    return AlertDialog(
      title: Text(tr(LocaleKeys.settings_editors_choose)),
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
    var textStyle = theme.textTheme.bodyText2!.copyWith(
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
