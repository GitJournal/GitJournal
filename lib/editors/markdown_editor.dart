import 'dart:io';

import 'package:flutter/material.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/editors/disposable_change_notifier.dart';
import 'package:gitjournal/editors/heuristics.dart';
import 'package:gitjournal/editors/note_body_editor.dart';
import 'package:gitjournal/editors/note_title_editor.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils/logger.dart';
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

class MarkdownEditorState extends State<MarkdownEditor>
    with DisposableChangeNotifier
    implements EditorState {
  Note note;
  TextEditingController _textController = TextEditingController();
  TextEditingController _titleTextController = TextEditingController();

  String _oldText;

  bool editingMode = true;
  bool _noteModified;

  MarkdownEditorState(this.note) {
    _textController = TextEditingController(text: note.body);
    _titleTextController = TextEditingController(text: note.title);
    _oldText = note.body;

    var settings = Settings.instance;
    if (settings.markdownDefaultView == SettingsMarkdownDefaultView.LastUsed) {
      editingMode =
          settings.markdownLastUsedView == SettingsMarkdownDefaultView.Edit;
    } else {
      editingMode =
          settings.markdownDefaultView == SettingsMarkdownDefaultView.Edit;
    }
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

    super.disposeListenables();
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
          NoteTitleEditor(
            _titleTextController,
            _noteTextChanged,
          ),
          NoteBodyEditor(
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
      switch (editingMode) {
        case true:
          Settings.instance.markdownLastUsedView =
              SettingsMarkdownDefaultView.Edit;
          break;
        case false:
          Settings.instance.markdownLastUsedView =
              SettingsMarkdownDefaultView.View;
          break;
      }
      Settings.instance.save();
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
    try {
      _applyHeuristics();
    } catch (e, stackTrace) {
      Log.e("EditorHeuristics: $e");
      logExceptionWarning(e, stackTrace);
    }
    if (_noteModified && !widget.isNewNote) return;

    var newState = !(widget.isNewNote && _textController.text.trim().isEmpty);
    if (newState != _noteModified) {
      setState(() {
        _noteModified = newState;
      });
    }

    notifyListeners();
  }

  void _applyHeuristics() {
    var selection = _textController.selection;
    if (selection.baseOffset != selection.extentOffset) {
      _oldText = _textController.text;
      return;
    }

    var r =
        autoAddBulletList(_oldText, _textController.text, selection.baseOffset);
    _oldText = _textController.text;

    if (r == null) {
      return;
    }

    _textController.text = r.text;
    _textController.selection = TextSelection.collapsed(offset: r.cursorPos);
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
