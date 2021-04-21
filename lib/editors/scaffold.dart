// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:function_types/function_types.dart';
import 'package:provider/provider.dart';
import 'package:time/time.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/editors/bottom_bar.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/widgets/note_viewer.dart';
import 'package:org_flutter/org_flutter.dart';

class EditorScaffold extends StatefulWidget {
  final Editor editor;
  final EditorState editorState;
  final bool noteModified;
  final bool editMode;
  final IconButton extraButton;
  final Widget body;
  final NotesFolderFS parentFolder;

  final Func0<void> onUndoSelected;
  final Func0<void> onRedoSelected;

  final bool undoAllowed;
  final bool redoAllowed;

  final Widget extraBottomWidget;

  EditorScaffold({
    @required this.editor,
    @required this.editorState,
    @required this.noteModified,
    @required this.editMode,
    @required this.body,
    @required this.parentFolder,
    @required this.onUndoSelected,
    @required this.onRedoSelected,
    @required this.undoAllowed,
    @required this.redoAllowed,
    this.extraBottomWidget,
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

    SchedulerBinding.instance
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

      note = widget.editorState.getNote();
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
    Widget body;
    if (editingMode) {
      body = widget.body;
    } else {
      switch (note.fileFormat) {
        case NoteFileFormat.OrgMode:
          body = Org(note.body);
          break;
        default:
          body = NoteViewer(
            note: note,
            parentFolder: widget.parentFolder,
          );
          break;
      }
    }

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
                metaDataEditable: note != null ? note.canHaveMetadata : false,
                onUndoSelected: widget.onUndoSelected,
                onRedoSelected: widget.onRedoSelected,
                undoAllowed: widget.undoAllowed,
                redoAllowed: widget.redoAllowed,
              ),
            ),
            if (widget.extraBottomWidget != null) widget.extraBottomWidget,
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
        duration: 500.milliseconds,
        opacity: opacity,
        child: child,
      ),
    );
  }
}
