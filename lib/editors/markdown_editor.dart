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
import 'search.dart';

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
      text: _note.title,
      highlightText: widget.highlightString,
      theme: widget.theme,
    );
    _heuristics = EditorHeuristics(text: _note.body);

    _scrollController = ScrollController(keepScrollOffset: false);
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
      parentFolder: _note.parent,
      body: editor,
      onUndoSelected: _undo,
      onRedoSelected: _redo,
      undoAllowed: false,
      redoAllowed: false,
      extraBottomWidget: markdownToolbar,
    );
  }

  void _updateNote() {
    _note.apply(
      body: _textController.text.trim(),
      title: _titleTextController.text.trim(),
      type: NoteType.Unknown,
    );
  }

  @override
  Note getNote() {
    _updateNote();
    return _note;
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
    note.apply(body: note.body + image.toMarkup(note.fileFormat));

    setState(() {
      _textController.text = note.body;
      _noteModified = true;
    });
  }

  @override
  bool get noteModified => _noteModified;

  Future<void> _undo() async {}

  Future<void> _redo() async {}

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

    var body = _textController.text.toLowerCase();
    text = text.toLowerCase();

    var offset = getSearchResultPosition(body, text, num);
    var newPosition = calculateTextHeight(
      text: body.substring(0, offset),
      style: NoteBodyEditor.textStyle(context),
      editorKey: _bodyEditorKey,
    );

    // FIXME: This '100' is hardcoded as it seems the EditorBottomBar's height
    //        is being included in the viewPortDimension
    var height = _scrollController.position.viewportDimension - 100;
    var minY = _scrollController.position.pixels;
    var maxY = minY + height;

    // Check if this position is 'inside' the current view rect
    if (minY < newPosition && newPosition < maxY) {
      return;
    }

    // print('Height: $newPosition');
    // print('Max: ${_scrollController.position.maxScrollExtent}');
    // print('Position: ${_scrollController.position}');

    // var viewPort = _scrollController.position.viewportDimension;
    // var prevPosition = _scrollController.position.

    _scrollController.animateTo(
      newPosition,
      duration: const Duration(milliseconds: 300),
      curve: decelerateEasing,
    );
  }
}
