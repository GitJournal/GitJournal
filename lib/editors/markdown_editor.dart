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

    if (Settings.instance.experimentalMarkdownToolbar && editingMode) {
      body = Container(
        height: 600,
        child: Column(
          children: <Widget>[
            Expanded(child: editor),
            MarkdownToolBar(
              onHeader1: () => _modifyCurrentLine('# '),
              onItallics: () => _modifyCurrentWord('*'),
              onBold: () => _modifyCurrentWord('**'),
            ),
          ],
          mainAxisSize: MainAxisSize.min,
        ),
      );
    }

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

  void _modifyCurrentLine(String char) {
    var selection = _textController.value.selection;
    var text = _textController.value.text;

    print('Base offset: ${selection.baseOffset}');
    print('Extent offset: ${selection.extentOffset}');
    var cursorPos = selection.baseOffset;
    if (cursorPos == -1) {
      cursorPos = 0;
    }
    print('CursorPos: $cursorPos');

    var lineStartPos =
        text.lastIndexOf('\n', cursorPos == 0 ? 0 : cursorPos - 1);
    if (lineStartPos == -1) {
      lineStartPos = 0;
    }

    var lineEndPos = text.indexOf('\n', cursorPos);
    if (lineEndPos == -1) {
      lineEndPos = text.length;
    }

    print('Line Start: $lineStartPos');
    print('Line End: $lineEndPos');
    print('Line: ${text.substring(lineStartPos, lineEndPos)}');

    // Check if already present
    if (text.startsWith(char, lineStartPos)) {
      print('Removing `$char`');
      _textController.text = text.replaceFirst(char, '', lineStartPos);
      _textController.selection =
          TextSelection.collapsed(offset: cursorPos - char.length);
      return;
    }

    print('Adding `$char`');
    _textController.text = text.replaceRange(lineStartPos, lineStartPos, char);
    _textController.selection =
        TextSelection.collapsed(offset: cursorPos + char.length);
  }

  void _modifyCurrentWord(String char) {
    var selection = _textController.value.selection;
    var text = _textController.value.text;

    print('Base offset: ${selection.baseOffset}');
    print('Extent offset: ${selection.extentOffset}');
    var cursorPos = selection.baseOffset;
    if (cursorPos == -1) {
      cursorPos = 0;
    }
    print('CursorPos: $cursorPos');

    var wordStartPos =
        text.lastIndexOf(' ', cursorPos == 0 ? 0 : cursorPos - 1);
    if (wordStartPos == -1) {
      wordStartPos = 0;
    }

    var wordEndPos = text.indexOf(' ', cursorPos);
    if (wordEndPos == -1) {
      wordEndPos = text.length;
    }

    print('Word Start: $wordStartPos');
    print('Word End: $wordEndPos');
    print('Word: ${text.substring(wordStartPos, wordEndPos)}');

    // Check if already present
    if (text.startsWith(char, wordStartPos)) {
      print('Removing `$char`');
      _textController.text = text.replaceFirst(char, '', wordStartPos);
      _textController.selection =
          TextSelection.collapsed(offset: cursorPos - (char.length * 2));
      return;
    }

    print('Adding `$char`');
    _textController.text = text.replaceRange(wordStartPos, wordStartPos, char);
    wordEndPos += char.length;

    _textController.text =
        text.replaceRange(wordEndPos - 1, wordEndPos - 1, char);
    _textController.selection =
        TextSelection.collapsed(offset: cursorPos + (char.length * 2));

    print('$char');
  }
}

class MarkdownToolBar extends StatelessWidget {
  final Function onHeader1;
  final Function onItallics;
  final Function onBold;

  MarkdownToolBar({
    @required this.onHeader1,
    @required this.onItallics,
    @required this.onBold,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Text('H1'),
          onPressed: onHeader1,
        ),
        IconButton(
          icon: const Text('I'),
          onPressed: onItallics,
        ),
        IconButton(
          icon: const Text('B'),
          onPressed: onBold,
        ),
      ],
    );
  }
}
