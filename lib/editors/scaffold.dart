import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/widgets/note_viewer.dart';

class EditorScaffold extends StatefulWidget {
  final Editor editor;
  final EditorState editorState;
  final bool noteModified;
  final bool isNewNote;
  final IconButton extraButton;
  final Widget body;
  final NotesFolderFS parentFolder;

  EditorScaffold({
    @required this.editor,
    @required this.editorState,
    @required this.noteModified,
    @required this.isNewNote,
    @required this.body,
    @required this.parentFolder,
    this.extraButton,
  });

  @override
  _EditorScaffoldState createState() => _EditorScaffoldState();
}

class _EditorScaffoldState extends State<EditorScaffold> {
  var hideUIElements = false;
  var editingMode = true;
  Note note;

  @override
  void initState() {
    super.initState();

    var settings = Settings.instance;

    hideUIElements = settings.zenMode;
    widget.editorState.addListener(_editorChanged);

    if (settings.markdownDefaultView == SettingsMarkdownDefaultView.LastUsed) {
      editingMode =
          settings.markdownLastUsedView == SettingsMarkdownDefaultView.Edit;
    } else {
      editingMode =
          settings.markdownDefaultView == SettingsMarkdownDefaultView.Edit;
    }

    if (widget.isNewNote) {
      editingMode = true;
    }

    note = widget.editorState.getNote();
  }

  @override
  void dispose() {
    widget.editorState.removeListener(_editorChanged);

    super.dispose();
  }

  void _editorChanged() {
    var settings = Provider.of<Settings>(context);

    if (settings.zenMode && !hideUIElements) {
      setState(() {
        hideUIElements = true;
      });
    }
  }

  void _switchMode() {
    var settings = Provider.of<Settings>(context);

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
    Widget body = editingMode
        ? widget.body
        : NoteViewer(
            note: note,
            parentFolder: widget.parentFolder,
          );

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
            _AnimatedOpacityIgnorePointer(
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
            Expanded(child: body),
            _AnimatedOpacityIgnorePointer(
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
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _AnimatedOpacityIgnorePointer extends StatelessWidget {
  final bool visible;
  final Widget child;

  _AnimatedOpacityIgnorePointer({@required this.visible, @required this.child});

  @override
  Widget build(BuildContext context) {
    var opacity = visible ? 1.0 : 0.0;
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: opacity,
        child: child,
      ),
    );
  }
}
