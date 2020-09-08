import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/fa_icon.dart';
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
        if (fileFormat != NoteFileFormat.Txt)
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
