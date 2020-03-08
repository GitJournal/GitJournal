import 'package:flutter/material.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/widgets/journal_editor_header.dart';

class JournalEditor extends StatefulWidget implements Editor {
  final Note note;

  @override
  final NoteCallback noteDeletionSelected;
  @override
  final NoteCallback noteEditorChooserSelected;
  @override
  final NoteCallback exitEditorSelected;
  @override
  final NoteCallback renameNoteSelected;
  @override
  final NoteCallback moveNoteToFolderSelected;
  @override
  final NoteCallback discardChangesSelected;

  final bool autofocusOnEditor;

  JournalEditor({
    Key key,
    @required this.note,
    @required this.noteDeletionSelected,
    @required this.noteEditorChooserSelected,
    @required this.exitEditorSelected,
    @required this.renameNoteSelected,
    @required this.moveNoteToFolderSelected,
    @required this.discardChangesSelected,
    this.autofocusOnEditor = false,
  }) : super(key: key);

  @override
  JournalEditorState createState() {
    return JournalEditorState(note);
  }
}

class JournalEditorState extends State<JournalEditor> implements EditorState {
  Note note;
  TextEditingController _textController = TextEditingController();

  JournalEditorState(this.note) {
    _textController = TextEditingController(text: note.body);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var editor = Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            JournalEditorHeader(note),
            _NoteBodyEditor(
              _textController,
              autofocus: widget.autofocusOnEditor,
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: buildEditorAppBar(widget, this),
      body: editor,
    );
  }

  void _updateNote() {
    note.body = _textController.text.trim();
  }

  @override
  Note getNote() {
    _updateNote();
    return note;
  }
}

class _NoteBodyEditor extends StatelessWidget {
  final TextEditingController textController;
  final bool autofocus;

  _NoteBodyEditor(this.textController, {this.autofocus = false});

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.subhead;

    return TextField(
      autofocus: autofocus,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      style: style,
      decoration: const InputDecoration(
        hintText: 'Write here',
        border: InputBorder.none,
        isDense: true,
      ),
      controller: textController,
      textCapitalization: TextCapitalization.sentences,
      scrollPadding: const EdgeInsets.all(0.0),
    );
  }
}
