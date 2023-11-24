/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 * SPDX-FileCopyrightText: 2020-2021 Alen Šiljak <gitjournal@alensiljak.eu.org>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/core/image.dart' as core;
import 'package:gitjournal/core/image.dart';
import 'package:gitjournal/core/markdown/md_yaml_doc_codec.dart';
import 'package:gitjournal/core/markdown/md_yaml_note_serializer.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/editors/editor_scroll_view.dart';
import 'package:gitjournal/editors/undo_redo.dart';
import 'package:gitjournal/editors/utils/disposable_change_notifier.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/utils/utils.dart';

import 'org_text_controller.dart';

class OrgEditor extends StatefulWidget implements Editor {
  final Note note;
  final bool noteModified;

  @override
  final EditorCommon common;

  final bool editMode;
  final String? highlightString;
  final ThemeData theme;

  const OrgEditor({
    super.key,
    required this.note,
    required this.noteModified,
    required this.editMode,
    required this.highlightString,
    required this.theme,
    required this.common,
  });

  @override
  OrgEditorState createState() {
    return OrgEditorState();
  }
}

class OrgEditorState extends State<OrgEditor>
    with DisposableChangeNotifier
    implements EditorState {
  late Note _note;
  late bool _noteModified;
  late TextEditingController _textController;
  late UndoRedoStack _undoRedoStack;

  final _serializer = MarkdownYAMLCodec();

  final _editorKey = GlobalKey();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _noteModified = widget.noteModified;
    _textController = buildOrgTextController(
      text: _serializer.encode(_note.data),
      highlightText: widget.highlightString,
      theme: widget.theme,
    );

    _undoRedoStack = UndoRedoStack();
    _scrollController = ScrollController(keepScrollOffset: false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();

    super.disposeListenables();
    super.dispose();
  }

  @override
  void didUpdateWidget(OrgEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.noteModified != widget.noteModified) {
      _noteModified = widget.noteModified;
    }
    if (oldWidget.note != widget.note) {
      _note = widget.note;
      _textController.text = _note.body;
    }
  }

  @override
  Widget build(BuildContext context) {
    var editor = EditorScrollView(
      scrollController: _scrollController,
      child: _NoteEditor(
        key: _editorKey,
        textController: _textController,
        autofocus: widget.editMode,
        onChanged: _noteTextChanged,
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
    var doc = _serializer.decode(_textController.text);
    return NoteSerializer.decodeNote(
      data: doc,
      parent: _note.parent,
      file: _note.file,
      settings: _note.noteSerializer.settings,
      fileFormat: _note.fileFormat,
    );
  }

  void _noteTextChanged() {
    notifyListeners();

    var editState = TextEditorState.fromValue(_textController.value);
    var redraw = _undoRedoStack.textChanged(editState);
    if (redraw) {
      setState(() {});
    }

    if (_noteModified) return;
    setState(() {
      _noteModified = true;
    });
  }

  @override
  Future<void> addImage(String filePath) async {
    try {
      var image = await core.Image.copyIntoFs(_note.parent, filePath);
      var ts = insertImage(
        TextEditorState.fromValue(_textController.value),
        image,
        _note.fileFormat,
      );

      setState(() {
        _textController.value = ts.toValue();
        _noteModified = true;
      });
    } catch (ex) {
      showErrorSnackbar(context, ex);
    }
  }

  @override
  bool get noteModified => _noteModified;

  Future<void> _undo() async {
    var es = _undoRedoStack.undo();
    _textController.value = es.toValue();
    setState(() {
      // To Redraw the undo/redo button state
    });
  }

  Future<void> _redo() async {
    var es = _undoRedoStack.redo();
    _textController.value = es.toValue();
    setState(() {
      // To Redraw the undo/redo button state
    });
  }

  @override
  SearchInfo search(String? text) {
    setState(() {
      _textController = buildOrgTextController(
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
      _textController = buildOrgTextController(
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
      textStyle: _NoteEditor.textStyle(context),
      searchText: text,
      resultNum: num,
    );
  }
}

class _NoteEditor extends StatelessWidget {
  final TextEditingController textController;
  final bool autofocus;
  final Function onChanged;

  const _NoteEditor({
    super.key,
    required this.textController,
    required this.autofocus,
    required this.onChanged,
  });

  static TextStyle textStyle(BuildContext context) {
    var theme = Theme.of(context);
    return theme.textTheme.titleMedium!.copyWith(fontFamily: "Roboto Mono");
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return TextField(
      autofocus: autofocus,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      style: textStyle(context),
      decoration: InputDecoration(
        hintText: context.loc.editorsCommonDefaultBodyHint,
        border: InputBorder.none,
        isDense: true,
        fillColor: theme.scaffoldBackgroundColor,
        hoverColor: theme.scaffoldBackgroundColor,
        isCollapsed: true,
      ),
      controller: textController,
      textCapitalization: TextCapitalization.sentences,
      scrollPadding: const EdgeInsets.all(0.0),
      onChanged: (_) => onChanged(),
    );
  }
}
