/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/image.dart' as core;
import 'package:gitjournal/core/image.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes/note.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/editors/editor_scroll_view.dart';
import 'package:gitjournal/editors/heuristics.dart';
import 'package:gitjournal/editors/markdown_toolbar.dart';
import 'package:gitjournal/editors/note_body_editor.dart';
import 'package:gitjournal/editors/note_title_editor.dart';
import 'package:gitjournal/editors/undo_redo.dart';
import 'package:gitjournal/editors/utils/disposable_change_notifier.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:gitjournal/utils/utils.dart';
import 'controllers/rich_text_controller.dart';

class MarkdownEditor extends StatefulWidget implements Editor {
  final Note note;
  final NotesFolder parentFolder;
  final bool noteModified;

  @override
  final EditorCommon common;

  final bool editMode;
  final String? highlightString;
  final ThemeData theme;

  const MarkdownEditor({
    Key? key,
    required this.note,
    required this.parentFolder,
    required this.noteModified,
    required this.editMode,
    required this.highlightString,
    required this.theme,
    required this.common,
  }) : super(key: key);

  @override
  MarkdownEditorState createState() {
    return MarkdownEditorState();
  }
}

class MarkdownEditorState extends State<MarkdownEditor>
    with DisposableChangeNotifier
    implements EditorState {
  late Note _note;
  late TextEditingController _textController;
  late TextEditingController _titleTextController;
  late UndoRedoStack _undoRedoStack;

  late EditorHeuristics _heuristics;

  late bool _noteModified;

  late ScrollController _scrollController;

  final _bodyEditorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _noteModified = widget.noteModified;

    _textController = buildController(
      text: _note.body,
      highlightText: widget.highlightString,
      theme: widget.theme,
    );
    _titleTextController = buildController(
      text: _note.title ?? "",
      highlightText: widget.highlightString,
      theme: widget.theme,
    );
    _heuristics = EditorHeuristics(text: _note.body);

    _scrollController = ScrollController(keepScrollOffset: false);
    _undoRedoStack = UndoRedoStack();
  }

  @override
  void dispose() {
    _textController.dispose();
    _titleTextController.dispose();
    _scrollController.dispose();

    super.disposeListenables();
    super.dispose();
  }

  @override
  void didUpdateWidget(MarkdownEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.noteModified != widget.noteModified) {
      _noteModified = widget.noteModified;
    }
    if (oldWidget.note != widget.note) {
      _note = widget.note;
      _textController.text = _note.body;
      _titleTextController.text = _note.title ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    var editor = EditorScrollView(
      scrollController: _scrollController,
      child: Column(
        children: <Widget>[
          NoteTitleEditor(
            _titleTextController,
            _noteTitleTextChanged,
          ),
          NoteBodyEditor(
            key: _bodyEditorKey,
            textController: _textController,
            autofocus: widget.editMode,
            onChanged: _noteTextChanged,
          ),
        ],
      ),
    );

    var settings = Provider.of<AppConfig>(context);
    Widget? markdownToolbar;
    if (settings.experimentalMarkdownToolbar) {
      markdownToolbar = MarkdownToolBar(
        textController: _textController,
      );
    }

    return EditorScaffold(
      startingNote: widget.note,
      editor: widget,
      editorState: this,
      noteModified: _noteModified,
      editMode: widget.editMode,
      parentFolder: _note.parent,
      body: editor,
      onUndoSelected: _undo,
      onRedoSelected: _redo,
      undoAllowed: _undoRedoStack.undoPossible,
      redoAllowed: _undoRedoStack.redoPossible,
      extraBottomWidget: markdownToolbar,
      findAllowed: true,
    );
  }

  @override
  Note getNote() {
    return _note.copyWith(
      body: _textController.text.trim(),
      title: _titleTextController.text.trim(),
      type: NoteType.Unknown,
    );
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

    var redraw = _undoRedoStack.textChanged(editState);
    if (redraw) {
      setState(() {});
    }
  }

  @override
  Future<void> addImage(String filePath) async {
    var imageR = await core.Image.copyIntoFs(_note.parent, filePath);
    if (imageR.isFailure) {
      Log.e("addImage", result: imageR);
      showResultError(context, imageR);
      return;
    }

    var ts = insertImage(
      TextEditorState.fromValue(_textController.value),
      imageR.getOrThrow(),
      _note.fileFormat,
    );

    setState(() {
      _textController.value = ts.toValue();
      _noteModified = true;
    });
  }

  @override
  bool get noteModified => _noteModified;

  Future<void> _undo() async {
    var es = _undoRedoStack.undo();
    setState(() {
      _textController.value = es.toValue();
    });
  }

  Future<void> _redo() async {
    var es = _undoRedoStack.redo();
    setState(() {
      _textController.value = es.toValue();
    });
  }

  @override
  SearchInfo search(String? text) {
    setState(() {
      _textController = buildController(
        text: _textController.text,
        highlightText: text,
        theme: widget.theme,
      );
      _titleTextController = buildController(
        text: _titleTextController.text,
        highlightText: text,
        theme: widget.theme,
      );
    });

    return SearchInfo.compute(body: _textController.text, text: text);
  }

  @override
  void scrollToResult(String text, int num) {
    setState(() {
      _textController = buildController(
        text: _textController.text,
        highlightText: text,
        theme: widget.theme,
        currentPos: num,
      );
    });

    scrollToSearchResult(
      scrollController: _scrollController,
      textController: _textController,
      textEditorKey: _bodyEditorKey,
      textStyle: NoteBodyEditor.textStyle(context),
      searchText: text,
      resultNum: num,
    );
  }
}
