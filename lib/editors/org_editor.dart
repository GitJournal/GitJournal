/*
Copyright 2020-2021 Alen Šiljak <gitjournal@alensiljak.eu.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:gitjournal/core/md_yaml_doc_codec.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/editors/disposable_change_notifier.dart';
import 'package:gitjournal/editors/editor_scroll_view.dart';
import 'package:gitjournal/editors/undo_redo.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';

class OrgEditor extends StatefulWidget implements Editor {
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

  OrgEditor({
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
  }) : super(key: key);

  @override
  OrgEditorState createState() {
    return OrgEditorState(note);
  }
}

class OrgEditorState extends State<OrgEditor>
    with DisposableChangeNotifier
    implements EditorState {
  Note note;
  late bool _noteModified;
  late TextEditingController _textController;
  late UndoRedoStack _undoRedoStack;

  final serializer = MarkdownYAMLCodec();

  OrgEditorState(this.note);

  @override
  void initState() {
    super.initState();
    _noteModified = widget.noteModified;
    _textController = TextEditingController(text: serializer.encode(note.data));
    _undoRedoStack = UndoRedoStack();
  }

  @override
  void dispose() {
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
    await getNote().addImage(filePath);
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

class _NoteEditor extends StatelessWidget {
  final TextEditingController textController;
  final bool autofocus;
  final Function onChanged;

  _NoteEditor({
    required this.textController,
    required this.autofocus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.subtitle1!.copyWith(fontFamily: "Roboto Mono");

    return TextField(
      autofocus: autofocus,
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
      controller: textController,
      textCapitalization: TextCapitalization.sentences,
      scrollPadding: const EdgeInsets.all(0.0),
      onChanged: (_) => onChanged(),
    );
  }
}
