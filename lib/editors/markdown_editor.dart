import 'package:flutter/material.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/widgets/note_viewer.dart';

typedef NoteCallback = void Function(Note);
enum DropDownChoices { Rename }

class MarkdownEditor extends StatefulWidget {
  final Note note;
  final NoteCallback noteDeletionSelected;
  final NoteCallback noteEditorChooserSelected;
  final NoteCallback exitEditorSelected;
  final NoteCallback renameNoteSelected;
  final bool autofocusOnEditor;

  MarkdownEditor({
    Key key,
    @required this.note,
    @required this.noteDeletionSelected,
    @required this.noteEditorChooserSelected,
    @required this.exitEditorSelected,
    @required this.renameNoteSelected,
    this.autofocusOnEditor = false,
  }) : super(key: key);

  @override
  MarkdownEditorState createState() {
    return MarkdownEditorState(note);
  }
}

class MarkdownEditorState extends State<MarkdownEditor> {
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
    var fab = FloatingActionButton(
      child: const Icon(Icons.check),
      onPressed: () {
        _updateNote();
        widget.exitEditorSelected(note);
      },
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const ValueKey("NewEntry"),
          icon: const Icon(Icons.check),
          onPressed: () {
            _updateNote();
            widget.exitEditorSelected(note);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: editingMode
                ? const Icon(Icons.remove_red_eye)
                : const Icon(Icons.edit),
            onPressed: _switchMode,
          ),
          IconButton(
            icon: const Icon(Icons.library_books),
            onPressed: () {
              _updateNote();
              widget.noteEditorChooserSelected(note);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _updateNote();
              widget.noteDeletionSelected(note);
            },
          ),
          PopupMenuButton<DropDownChoices>(
            onSelected: (DropDownChoices choice) {
              _updateNote();
              widget.renameNoteSelected(note);
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<DropDownChoices>>[
              const PopupMenuItem<DropDownChoices>(
                value: DropDownChoices.Rename,
                child: Text('Edit File Name'),
              ),
            ],
          ),
        ],
      ),
      body: body,
      floatingActionButton: fab,
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
      decoration: InputDecoration(
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
      decoration: InputDecoration(
        hintText: 'Title',
        border: InputBorder.none,
        isDense: true,
      ),
      controller: textController,
      textCapitalization: TextCapitalization.sentences,
    );
  }
}
