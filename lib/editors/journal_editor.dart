/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:gitjournal/core/image.dart' as core;
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/editors/editor_scroll_view.dart';
import 'package:gitjournal/editors/heuristics.dart';
import 'package:gitjournal/editors/note_body_editor.dart';
import 'package:gitjournal/editors/undo_redo.dart';
import 'package:gitjournal/editors/utils/disposable_change_notifier.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/widgets/journal_editor_header.dart';
import 'controllers/rich_text_controller.dart';

class JournalEditor extends StatefulWidget implements Editor {
  final Note note;
  final bool noteModified;

  final bool editMode;
  final String? highlightString;
  final ThemeData theme;

  @override
  final EditorCommon common;

  const JournalEditor({
    Key? key,
    required this.note,
    required this.noteModified,
    required this.editMode,
    required this.highlightString,
    required this.theme,
    required this.common,
  }) : super(key: key);

  @override
  JournalEditorState createState() {
    return JournalEditorState();
  }
}

class JournalEditorState extends State<JournalEditor>
    with DisposableChangeNotifier
    implements EditorState {
  late Note _note;
  late TextEditingController _textController;
  late UndoRedoStack _undoRedoStack;
  late bool _noteModified;

  late EditorHeuristics _heuristics;

  final _editorKey = GlobalKey();
  late ScrollController _scrollController;

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

    _heuristics = EditorHeuristics(text: _note.body);
    _scrollController = ScrollController(keepScrollOffset: false);
    _undoRedoStack = UndoRedoStack();
  }

  @override
  void didUpdateWidget(JournalEditor oldWidget) {
    if (oldWidget.noteModified != widget.noteModified) {
      _noteModified = widget.noteModified;
    }
    if (oldWidget.note != widget.note) {
      _note = widget.note;
      _textController.text = _note.body;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();

    super.disposeListenables();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var editor = EditorScrollView(
      scrollController: _scrollController,
      child: Column(
        children: <Widget>[
          JournalEditorHeader(
            _note.created,
            onChange: (dt) {
              setState(() {
                _note.apply(created: dt);
              });
            },
          ),
          NoteBodyEditor(
            key: _editorKey,
            textController: _textController,
            autofocus: widget.editMode,
            onChanged: _noteTextChanged,
          ),
        ],
      ),
    );

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
      findAllowed: true,
    );
  }

  @override
  Note getNote() {
    _note.apply(
      body: _textController.text.trim(),
      type: NoteType.Journal,
    );
    return _note;
  }

  void _noteTextChanged() {
    try {
      _applyHeuristics();
    } catch (e, stackTrace) {
      Log.e("EditorHeuristics: $e");
      logExceptionWarning(e, stackTrace);
    }

    if (_noteModified && !widget.editMode) {
      notifyListeners();
      return;
    }

    var newState = !(widget.editMode && _textController.text.trim().isEmpty);
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
    var note = getNote();
    var image = await core.Image.copyIntoFs(note.parent, filePath);
    note.apply(body: note.body + image.toMarkup(note.fileFormat));

    setState(() {
      _textController.text = note.body;
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
      textEditorKey: _editorKey,
      textStyle: NoteBodyEditor.textStyle(context),
      searchText: text,
      resultNum: num,
    );
  }
}
