import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/settings.dart';

class EditorScaffold extends StatefulWidget {
  final Editor editor;
  final EditorState editorState;
  final bool noteModified;
  final IconButton extraButton;
  final Widget body;
  final NotesFolderFS parentFolder;
  final bool allowEdits;

  EditorScaffold({
    @required this.editor,
    @required this.editorState,
    @required this.noteModified,
    @required this.body,
    @required this.parentFolder,
    this.extraButton,
    this.allowEdits = true,
  });

  @override
  _EditorScaffoldState createState() => _EditorScaffoldState();
}

class _EditorScaffoldState extends State<EditorScaffold> {
  var hideUIElements = false;

  @override
  void initState() {
    super.initState();

    hideUIElements = Settings.instance.zenMode;
    widget.editorState.addListener(_editorChanged);
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

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<Settings>(context);

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
              ),
            ),
            Expanded(child: widget.body),
            _AnimatedOpacityIgnorePointer(
              visible: !hideUIElements,
              child: EditorBottomBar(
                editor: widget.editor,
                editorState: widget.editorState,
                parentFolder: widget.parentFolder,
                allowEdits: widget.allowEdits,
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
