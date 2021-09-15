/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/image.dart' as core;
import 'package:gitjournal/core/md_yaml_doc_codec.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/editors/autocompletion_widget.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/editors/disposable_change_notifier.dart';
import 'package:gitjournal/editors/editor_scroll_view.dart';
import 'package:gitjournal/editors/undo_redo.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/settings/app_settings.dart';
import 'rich_text_controller.dart';

class RawEditor extends StatefulWidget implements Editor {
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

  final bool editMode;
  final String? highlightString;
  final ThemeData theme;

  RawEditor({
    Key? key,
    required this.note,
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
  RawEditorState createState() {
    return RawEditorState(note);
  }
}

class RawEditorState extends State<RawEditor>
    with DisposableChangeNotifier
    implements EditorState {
  Note note;
  late bool _noteModified;
  late TextEditingController _textController;
  late UndoRedoStack _undoRedoStack;

  final serializer = MarkdownYAMLCodec();

  RawEditorState(this.note);

  @override
  void initState() {
    super.initState();
    _noteModified = widget.noteModified;

    _textController = buildController(
      text: serializer.encode(note.data),
      highlightText: widget.highlightString,
      theme: widget.theme,
    );

    _undoRedoStack = UndoRedoStack();
  }

  @override
  void dispose() {
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
  }

  @override
  Widget build(BuildContext context) {
    var editor = EditorScrollView(
      child: _NoteEditor(
        textController: _textController,
        autofocus: widget.editMode,
        onChanged: _noteTextChanged,
      ),
    );

    return EditorScaffold(
      editor: widget,
      editorState: this,
      noteModified: _noteModified,
      editMode: widget.editMode,
      parentFolder: note.parent,
      body: editor,
      onUndoSelected: _undo,
      onRedoSelected: _redo,
      undoAllowed: _undoRedoStack.undoPossible,
      redoAllowed: _undoRedoStack.redoPossible,
    );
  }

  @override
  Note getNote() {
    note.data = serializer.decode(_textController.text);
    return note;
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
}

class _NoteEditor extends StatefulWidget {
  final TextEditingController textController;
  final bool autofocus;
  final Function onChanged;

  _NoteEditor({
    required this.textController,
    required this.autofocus,
    required this.onChanged,
  });

  @override
  State<_NoteEditor> createState() => _NoteEditorState();
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
    var style = theme.textTheme.subtitle1!.copyWith(fontFamily: "Roboto Mono");

    var textField = TextField(
      key: _textFieldKey,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      style: style,
      decoration: InputDecoration(
        hintText: tr(LocaleKeys.editors_common_defaultBodyHint),
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

    var appSettings = Provider.of<AppSettings>(context);
    if (!appSettings.experimentalTagAutoCompletion) {
      return textField;
    }

    return AutoCompletionWidget(
      textFieldStyle: style,
      textFieldKey: _textFieldKey,
      textFieldFocusNode: _focusNode,
      textController: widget.textController,
      child: textField,
    );
  }
}
