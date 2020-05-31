import 'dart:io';
import 'package:flutter/material.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/widgets/editor_scroll_view.dart';
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
  final NoteCallback editTagsSelected;
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
    @required this.editTagsSelected,
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
  void didUpdateWidget(JournalEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.noteModified != widget.noteModified) {
      _noteModified = widget.noteModified;
    }
  }

  @override
  Widget build(BuildContext context) {
    var editor = EditorScrollView(
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
    );

    return EditorScaffold(
      editor: widget,
      editorState: this,
      noteModified: _noteModified,
      parentFolder: note.parent,
      body: editor,
    );
  }

  @override
  Note getNote() {
    note.body = _textController.text.trim();
    note.type = NoteType.Journal;
    return note;
  }

  void _noteTextChanged() {
    if (_noteModified && !widget.isNewNote) return;

    var newState = !(widget.isNewNote && _textController.text.trim().isEmpty);
    if (newState != _noteModified) {
      setState(() {
        _noteModified = newState;
      });
    }
  }

  @override
  Future<void> addImage(File file) async {
    await getNote().addImage(file);
    setState(() {
      _textController.text = note.body;
      _noteModified = true;
    });
  }

  @override
  bool get noteModified => _noteModified;
}

class _NoteBodyEditor extends StatelessWidget {
  final TextEditingController textController;
  final bool autofocus;
  final Function onChanged;

  _NoteBodyEditor({this.textController, this.autofocus, this.onChanged});

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.subtitle1;

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
