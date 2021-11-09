/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:function_types/function_types.dart';
import 'package:provider/provider.dart';
import 'package:time/time.dart';

import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/editors/bottom_bar.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/editors/note_body_editor.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/widgets/note_viewer.dart';

class EditorScaffold extends StatefulWidget {
  final Note startingNote;
  final Editor editor;
  final EditorState editorState;
  final bool noteModified;
  final bool editMode;
  final IconButton? extraButton;
  final Widget body;
  final NotesFolderFS parentFolder;

  final Func0<void> onUndoSelected;
  final Func0<void> onRedoSelected;

  final bool undoAllowed;
  final bool redoAllowed;

  final bool findAllowed;

  final Widget? extraBottomWidget;

  const EditorScaffold({
    required this.startingNote,
    required this.editor,
    required this.editorState,
    required this.noteModified,
    required this.editMode,
    required this.body,
    required this.parentFolder,
    required this.onUndoSelected,
    required this.onRedoSelected,
    required this.undoAllowed,
    required this.redoAllowed,
    required this.findAllowed,
    this.extraBottomWidget,
    this.extraButton,
  });

  @override
  _EditorScaffoldState createState() => _EditorScaffoldState();
}

class _EditorScaffoldState extends State<EditorScaffold> {
  var hideUIElements = false;
  var editingMode = true;
  var findMode = false;

  late Note note;

  @override
  void initState() {
    super.initState();

    note = widget.startingNote;

    SchedulerBinding.instance!
        .addPostFrameCallback((_) => _initStateWithContext());
  }

  void _initStateWithContext() {
    if (!mounted) return;

    var settings = Provider.of<Settings>(context, listen: false);

    setState(() {
      hideUIElements = settings.zenMode;
      widget.editorState.addListener(_editorChanged);

      if (settings.markdownDefaultView ==
          SettingsMarkdownDefaultView.LastUsed) {
        editingMode =
            settings.markdownLastUsedView == SettingsMarkdownDefaultView.Edit;
      } else {
        editingMode =
            settings.markdownDefaultView == SettingsMarkdownDefaultView.Edit;
      }

      if (widget.editMode) {
        editingMode = true;
      }
    });
  }

  @override
  void dispose() {
    widget.editorState.removeListener(_editorChanged);

    super.dispose();
  }

  void _editorChanged() {
    var settings = Provider.of<Settings>(context, listen: false);

    if (settings.zenMode && !hideUIElements) {
      setState(() {
        hideUIElements = true;
      });
    }
  }

  void _switchMode() {
    var settings = Provider.of<Settings>(context, listen: false);

    setState(() {
      editingMode = !editingMode;
      switch (editingMode) {
        case true:
          settings.markdownLastUsedView = SettingsMarkdownDefaultView.Edit;
          break;
        case false:
          settings.markdownLastUsedView = SettingsMarkdownDefaultView.View;
          break;
      }
      settings.save();
      note = widget.editorState.getNote();
    });
  }

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<Settings>(context);

    var responsiveBody = LayoutBuilder(builder: (context, constraints) {
      // FIXME: This shouldn't depend on the font
      var ch = textSize('0', NoteBodyEditor.textStyle(context));
      var maxWidth = ch.width * 65;

      var body = editingMode
          ? widget.body
          : NoteViewer(note: note, parentFolder: widget.parentFolder);

      body = Scrollbar(child: body);

      if (constraints.maxWidth <= maxWidth) {
        return body;
      }

      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: SizedBox(width: maxWidth, child: body),
        ),
      );
    });

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (settings.zenMode) {
            setState(() {
              hideUIElements = false;
            });
          }
        },
        child: Column(
          children: <Widget>[
            if (!findMode)
              _HideWidget(
                visible: !hideUIElements,
                child: EditorAppBar(
                  editor: widget.editor,
                  editorState: widget.editorState,
                  noteModified: widget.noteModified,
                  extraButton: widget.extraButton,
                  allowEdits: editingMode,
                  onEditingModeChange: _switchMode,
                ),
              ),
            if (findMode)
              _HideWidget(
                visible: !hideUIElements,
                child: EditorAppSearchBar(
                  editorState: widget.editorState,
                  onCloseSelected: () {
                    setState(() {
                      findMode = false;
                    });
                  },
                  scrollToResult: widget.editorState.scrollToResult,
                ),
              ),
            Expanded(
              child: Hero(tag: note.filePath, child: responsiveBody),
            ),
            _HideWidget(
              visible: !hideUIElements,
              child: EditorBottomBar(
                editor: widget.editor,
                editorState: widget.editorState,
                parentFolder: widget.parentFolder,
                allowEdits: editingMode,
                zenMode: settings.zenMode,
                onZenModeChanged: () {
                  setState(() {
                    settings.zenMode = !settings.zenMode;
                    settings.save();

                    if (settings.zenMode) {
                      hideUIElements = true;
                    }
                  });
                },
                metaDataEditable: note.canHaveMetadata,
                onUndoSelected: widget.onUndoSelected,
                onRedoSelected: widget.onRedoSelected,
                undoAllowed: widget.undoAllowed,
                redoAllowed: widget.redoAllowed,
                findAllowed: widget.findAllowed,
                onFindSelected: () {
                  setState(() {
                    findMode = true;
                  });
                },
              ),
            ),
            if (widget.extraBottomWidget != null) widget.extraBottomWidget!,
          ],
        ),
      ),
    );
  }
}

class _HideWidget extends StatelessWidget {
  final bool visible;
  final Widget child;

  const _HideWidget({required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    var opacity = visible ? 1.0 : 0.0;
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        duration: 500.milliseconds,
        opacity: opacity,
        child: child,
      ),
    );
  }
}
