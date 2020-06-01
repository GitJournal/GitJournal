import 'dart:io';
import 'package:flutter/material.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/editors/note_title_editor.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/widgets/editor_scroll_view.dart';
import 'package:gitjournal/widgets/note_viewer.dart';

class MarkdownEditor extends StatefulWidget implements Editor {
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

  MarkdownEditor({
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
    @required this.isNewNote,
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

  int _textLength;

  bool editingMode = true;
  bool _noteModified;

  MarkdownEditorState(this.note) {
    _textController = TextEditingController(text: note.body);
    _titleTextController = TextEditingController(text: note.title);
    _textLength = note.body.length;

    editingMode = Settings.instance.markdownDefaultView ==
        SettingsMarkdownDefaultView.Edit;
  }

  @override
  void initState() {
    super.initState();
    _noteModified = widget.noteModified;
    if (widget.isNewNote) {
      editingMode = true;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _titleTextController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MarkdownEditor oldWidget) {
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
          if (note.canHaveMetadata)
            NoteTitleEditor(
              _titleTextController,
              _noteTextChanged,
            ),
          _NoteBodyEditor(
            textController: _textController,
            autofocus: widget.isNewNote,
            onChanged: _noteTextChanged,
          ),
        ],
      ),
    );

    Widget body = editingMode ? editor : NoteViewer(note: note);

    var extraButton = IconButton(
      icon: editingMode
          ? const Icon(Icons.remove_red_eye)
          : const Icon(Icons.edit),
      onPressed: _switchMode,
    );

    return EditorScaffold(
      editor: widget,
      editorState: this,
      extraButton: extraButton,
      noteModified: _noteModified,
      parentFolder: note.parent,
      allowEdits: editingMode,
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
    note.type = NoteType.Unknown;
  }

  @override
  Note getNote() {
    _updateNote();
    return note;
  }

  void _noteTextChanged() {
    _insertExtraCharactersOnEnter();
    if (_noteModified && !widget.isNewNote) return;

    var newState = !(widget.isNewNote && _textController.text.trim().isEmpty);
    if (newState != _noteModified) {
      setState(() {
        _noteModified = newState;
      });
    }
  }

  void _insertExtraCharactersOnEnter() {
    var text = _textController.text;
    if (text.length <= _textLength) {
      _textLength = text.length;
      return;
    }
    _textLength = text.length;
    if (!text.endsWith('\n')) {
      return;
    }
    var prevLineStart = text.lastIndexOf('\n', text.length - 2);
    prevLineStart = prevLineStart == -1 ? 0 : prevLineStart + 1;
    var prevLine = text.substring(prevLineStart, text.length - 2);

    var pattern = RegExp(r'^(\s*)([*\-])');
    var match = pattern.firstMatch(prevLine);
    if (match == null) {
      return;
    }

    var indentation = match.group(1) ?? "";
    _textController.text = text + indentation + match.group(2) + ' ';
    _textLength = _textController.text.length;
    _textController.selection = TextSelection.collapsed(offset: _textLength);
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

  _NoteBodyEditor({
    @required this.textController,
    @required this.autofocus,
    @required this.onChanged,
  });

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
