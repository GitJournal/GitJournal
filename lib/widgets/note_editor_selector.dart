import 'package:flutter/material.dart';
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
            "Markdown Editor",
            FontAwesomeIcons.markdown,
          ),
        _buildTile(
          context,
          EditorType.Raw,
          "Raw Editor",
          FontAwesomeIcons.dna,
        ),
        _buildTile(
          context,
          EditorType.Checklist,
          "Checklist Editor",
          FontAwesomeIcons.tasks,
        ),
        _buildTile(
          context,
          EditorType.Journal,
          "Journal Editor",
          FontAwesomeIcons.book,
        ),
      ],
      mainAxisSize: MainAxisSize.min,
    );

    return AlertDialog(
      title: const Text("Choose Editor"),
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
