/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/image.dart' as core;
import 'package:gitjournal/core/image.dart';
import 'package:gitjournal/core/markdown/md_yaml_doc_codec.dart';
import 'package:gitjournal/core/markdown/md_yaml_note_serializer.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/views/inline_tags_view.dart';
import 'package:gitjournal/editors/autocompletion_widget.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/editors/editor_scroll_view.dart';
import 'package:gitjournal/editors/undo_redo.dart';
import 'package:gitjournal/editors/utils/disposable_change_notifier.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:gitjournal/utils/utils.dart';
import 'package:gitjournal/widgets/future_builder_with_progress.dart';
import 'package:provider/provider.dart';

import 'controllers/rich_text_controller.dart';

class RawEditor extends StatefulWidget implements Editor {
  final Note note;
  final bool noteModified;

  @override
  final EditorCommon common;

  final bool editMode;
  final String? highlightString;
  final ThemeData theme;

  const RawEditor({
    super.key,
    required this.note,
    required this.noteModified,
    required this.editMode,
    required this.highlightString,
    required this.theme,
    required this.common,
  });

  @override
  RawEditorState createState() {
    return RawEditorState();
  }
}

class RawEditorState extends State<RawEditor>
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

    _textController = buildController(
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
  void didUpdateWidget(RawEditor oldWidget) {
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
      textStyle: _NoteEditor.textStyle(context),
      searchText: text,
      resultNum: num,
    );
  }
}

class _NoteEditor extends StatefulWidget {
  final TextEditingController textController;
  final bool autofocus;
  final Function onChanged;

  const _NoteEditor({
    super.key,
    required this.textController,
    required this.autofocus,
    required this.onChanged,
  });

  @override
  State<_NoteEditor> createState() => _NoteEditorState();

  static TextStyle textStyle(BuildContext context) {
    var theme = Theme.of(context);
    return theme.textTheme.titleMedium!.copyWith(fontFamily: "Roboto Mono");
  }
}

class _NoteEditorState extends State<_NoteEditor> {
  late FocusNode _focusNode;
  late GlobalKey _textFieldKey;

  @override
  void initState() {
    _focusNode = FocusNode();
    _textFieldKey = GlobalKey();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var textField = TextField(
      key: _textFieldKey,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      style: _NoteEditor.textStyle(context),
      decoration: InputDecoration(
        hintText: context.loc.editorsCommonDefaultBodyHint,
        border: InputBorder.none,
        isDense: true,
        fillColor: theme.scaffoldBackgroundColor,
        hoverColor: theme.scaffoldBackgroundColor,
        isCollapsed: true,
      ),
      controller: widget.textController,
      textCapitalization: TextCapitalization.sentences,
      scrollPadding: const EdgeInsets.all(0.0),
      onChanged: (_) => widget.onChanged(),
    );

    var appConfig = Provider.of<AppConfig>(context);
    if (!appConfig.experimentalTagAutoCompletion) {
      return textField;
    }

    final rootFolder = Provider.of<NotesFolderFS>(context, listen: false);
    final inlineTagsView = InlineTagsProvider.of(context);

    futureBuilder() async {
      var allTags = await rootFolder.getNoteTagsRecursively(inlineTagsView);

      Log.d("Building autocompleter with $allTags");
      return AutoCompletionWidget(
        textFieldStyle: _NoteEditor.textStyle(context),
        textFieldKey: _textFieldKey,
        textFieldFocusNode: _focusNode,
        textController: widget.textController,
        tags: allTags.toList(),
        child: textField,
      );
    }

    return FutureBuilderWithProgress(future: futureBuilder());
  }
}
