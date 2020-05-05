import 'package:flutter/material.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/widgets/journal_editor_header.dart';

class JournalEditor extends StatefulWidget implements Editor {
  final Note note;
  final bool noteModified;

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

  final bool isNewNote;

  JournalEditor({
    Key key,
    @required this.note,
    @required this.noteModified,
    @required this.noteDeletionSelected,
    @required this.noteEditorChooserSelected,
    @required this.exitEditorSelected,
    @required this.renameNoteSelected,
    @required this.moveNoteToFolderSelected,
    @required this.discardChangesSelected,
    this.isNewNote = false,
  }) : super(key: key);

  @override
  JournalEditorState createState() {
    return JournalEditorState(note);
  }
}

class JournalEditorState extends State<JournalEditor> implements EditorState {
  Note note;
  TextEditingController _textController = TextEditingController();
  bool _noteModified;

  JournalEditorState(this.note) {
    _textController = TextEditingController(text: note.body);
  }

  @override
  void initState() {
    super.initState();
    _noteModified = widget.noteModified;
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
              textController: _textController,
              autofocus: widget.isNewNote,
              onChanged: _noteTextChanged,
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: buildEditorAppBar(widget, this, noteModified: _noteModified),
      body: editor,
      bottomNavigationBar: buildEditorBottonBar(context, widget, this, note),
    );
  }

  @override
  Note getNote() {
    note.body = _textController.text.trim();
    note.type = NoteType.Journal;
    return note;
  }

  void _noteTextChanged() {
    if (_noteModified) return;
    setState(() {
      _noteModified = true;
    });
  }
}

class _NoteBodyEditor extends StatelessWidget {
  final TextEditingController textController;
  final bool autofocus;
  final Function onChanged;

  _NoteBodyEditor({this.textController, this.autofocus, this.onChanged});

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
      onChanged: (_) => onChanged(),
    );
  }
}
