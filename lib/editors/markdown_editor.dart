import 'package:flutter/material.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/widgets/note_viewer.dart';

class MarkdownEditor extends StatefulWidget implements Editor {
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

  MarkdownEditor({
    Key key,
    @required this.note,
    @required this.noteDeletionSelected,
    @required this.noteEditorChooserSelected,
    @required this.exitEditorSelected,
    @required this.renameNoteSelected,
    @required this.moveNoteToFolderSelected,
    @required this.discardChangesSelected,
    @required this.autofocusOnEditor,
  }) : super(key: key);

  @override
  MarkdownEditorState createState() {
    return MarkdownEditorState(note);
  }
}

class MarkdownEditorState extends State<MarkdownEditor> implements EditorState {
  Note note;
  TextEditingController _textController = TextEditingController();
  TextEditingController _titleTextController = TextEditingController();

  bool editingMode = true;

  MarkdownEditorState(this.note) {
    _textController = TextEditingController(text: note.body);
    _titleTextController = TextEditingController(text: note.title);
  }

  @override
  void dispose() {
    _textController.dispose();
    _titleTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var editor = Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _NoteTitleEditor(_titleTextController),
            _NoteBodyEditor(
              _textController,
              autofocus: widget.autofocusOnEditor,
            ),
          ],
        ),
      ),
    );

    Widget body = editingMode ? editor : NoteViewer(note: note);

    var extraButton = IconButton(
      icon: editingMode
          ? const Icon(Icons.remove_red_eye)
          : const Icon(Icons.edit),
      onPressed: _switchMode,
    );

    return Scaffold(
      appBar: buildEditorAppBar(widget, this, extraButtons: [extraButton]),
      floatingActionButton: buildFAB(widget, this),
      body: body,
    );
  }

  void _switchMode() {
    setState(() {
      editingMode = !editingMode;
      _updateNote();
    });
  }

  void _updateNote() {
    note.title = _titleTextController.text.trim();
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
      autocorrect: false,
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

class _NoteTitleEditor extends StatelessWidget {
  final TextEditingController textController;

  _NoteTitleEditor(this.textController);

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.title;

    return TextField(
      keyboardType: TextInputType.text,
      maxLines: 1,
      style: style,
      decoration: const InputDecoration(
        hintText: 'Title',
        border: InputBorder.none,
        isDense: true,
      ),
      controller: textController,
      textCapitalization: TextCapitalization.sentences,
    );
  }
}
