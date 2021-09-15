/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:gitjournal/core/image.dart' as core;
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/editors/disposable_change_notifier.dart';
import 'package:gitjournal/editors/editor_scroll_view.dart';
import 'package:gitjournal/editors/heuristics.dart';
import 'package:gitjournal/editors/markdown_toolbar.dart';
import 'package:gitjournal/editors/note_body_editor.dart';
import 'package:gitjournal/editors/note_title_editor.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/app_settings.dart';
import 'rich_text_controller.dart';

class MarkdownEditor extends StatefulWidget implements Editor {
  final Note note;
  final NotesFolder parentFolder;
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

  final bool editMode;
  final String? highlightString;
  final ThemeData theme;

  MarkdownEditor({
    Key? key,
    required this.note,
    required this.parentFolder,
    required this.noteModified,
    required this.noteDeletionSelected,
    required this.noteEditorChooserSelected,
    required this.exitEditorSelected,
    required this.renameNoteSelected,
    required this.editTagsSelected,
    required this.moveNoteToFolderSelected,
    required this.discardChangesSelected,
    required this.editMode,
    required this.highlightString,
    required this.theme,
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
  late TextEditingController _textController;
  late TextEditingController _titleTextController;

  late EditorHeuristics _heuristics;

  late bool _noteModified;

  MarkdownEditorState(this.note);

  @override
  void initState() {
    super.initState();
    _noteModified = widget.noteModified;

    _textController = buildController(
      text: note.body,
      highlightText: widget.highlightString,
      theme: widget.theme,
    );
    _titleTextController = buildController(
      text: note.title,
      highlightText: widget.highlightString,
      theme: widget.theme,
    );

    _heuristics = EditorHeuristics(text: note.body);
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
            _noteTitleTextChanged,
          ),
          NoteBodyEditor(
            textController: _textController,
            autofocus: widget.editMode,
            onChanged: _noteTextChanged,
          ),
        ],
      ),
    );

    var settings = Provider.of<AppSettings>(context);
    Widget? markdownToolbar;
    if (settings.experimentalMarkdownToolbar) {
      markdownToolbar = MarkdownToolBar(
        textController: _textController,
      );
    }

    return EditorScaffold(
      editor: widget,
      editorState: this,
      noteModified: _noteModified,
      editMode: widget.editMode,
      parentFolder: note.parent,
      body: editor,
      onUndoSelected: _undo,
      onRedoSelected: _redo,
      undoAllowed: false,
      redoAllowed: false,
      extraBottomWidget: markdownToolbar,
    );
  }

  void _updateNote() {
    note.title = _titleTextController.text.trim();
    note.body = _textController.text;
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
    if (_noteModified && !widget.editMode) return;

    var newState = !(widget.editMode && _textController.text.trim().isEmpty);
    if (newState != _noteModified) {
      setState(() {
        _noteModified = newState;
      });
    }

    notifyListeners();
  }

  void _noteTitleTextChanged() {
    if (_noteModified && !widget.editMode) return;

    var newState =
        !(widget.editMode && _titleTextController.text.trim().isEmpty);
    if (newState != _noteModified) {
      setState(() {
        _noteModified = newState;
      });
    }

    notifyListeners();
  }

  void _applyHeuristics() {
    var editState = TextEditorState.fromValue(_textController.value);
    var es = _heuristics.textChanged(editState);
    if (es != null) {
      _textController.value = es.toValue();
    }
  }

  @override
  Future<void> addImage(String filePath) async {
    var note = getNote();
    var image = await core.Image.copyIntoFs(note.parent, filePath);
    note.body += image.toMarkup(note.fileFormat);

    setState(() {
      _textController.text = note.body;
      _noteModified = true;
    });
  }

  @override
  bool get noteModified => _noteModified;

  Future<void> _undo() async {}

  Future<void> _redo() async {}
}
