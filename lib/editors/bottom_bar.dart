import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:function_types/function_types.dart';
import 'package:image_picker/image_picker.dart';

import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/features.dart';
import 'package:gitjournal/utils/utils.dart';
import 'package:gitjournal/widgets/pro_overlay.dart';

class EditorBottomBar extends StatelessWidget {
  final Editor editor;
  final EditorState editorState;
  final NotesFolderFS parentFolder;
  final bool allowEdits;
  final bool zenMode;
  final Func0<void> onZenModeChanged;
  final bool metaDataEditable;

  final bool undoAllowed;
  final bool redoAllowed;

  final Func0<void> onUndoSelected;
  final Func0<void> onRedoSelected;

  EditorBottomBar({
    required this.editor,
    required this.editorState,
    required this.parentFolder,
    required this.allowEdits,
    required this.zenMode,
    required this.onZenModeChanged,
    required this.metaDataEditable,
    required this.onUndoSelected,
    required this.onRedoSelected,
    required this.undoAllowed,
    required this.redoAllowed,
  });

  @override
  Widget build(BuildContext context) {
    var addIcon = IconButton(
      icon: const Icon(Icons.attach_file),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (c) => _buildAddBottomSheet(c, editor, editorState),
          elevation: 0,
        );
      },
    );

    var menuIcon = IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (c) => _buildBottomMenuSheet(
            c,
            editor,
            editorState,
            zenMode,
            onZenModeChanged,
            metaDataEditable,
          ),
          elevation: 0,
        );
      },
    );

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            Visibility(
              child: addIcon,
              visible: allowEdits,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              maintainInteractivity: false,
            ),
            const Spacer(),
            if (undoAllowed)
              IconButton(
                icon: const Icon(Icons.undo),
                onPressed: undoAllowed ? onUndoSelected : null,
              ),
            TextButton.icon(
              icon: const Icon(Icons.folder),
              label: Text(parentFolder.publicName),
              onPressed: () {
                var note = editorState.getNote();
                editor.moveNoteToFolderSelected(note);
              },
            ),
            if (redoAllowed)
              IconButton(
                icon: const Icon(Icons.redo),
                onPressed: redoAllowed ? onRedoSelected : null,
              ),
            const Spacer(),
            menuIcon,
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}

Widget _buildAddBottomSheet(
  BuildContext context,
  Editor editor,
  EditorState editorState,
) {
  return Container(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.camera),
          title: Text(tr('editors.common.takePhoto')),
          onTap: () async {
            try {
              var image = await ImagePicker().getImage(
                source: ImageSource.camera,
              );

              if (image != null) {
                await editorState.addImage(image.path);
              }
            } catch (e) {
              reportError(e, StackTrace.current);
            }
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          leading: const Icon(Icons.image),
          title: Text(tr('editors.common.addImage')),
          onTap: () async {
            try {
              var image = await ImagePicker().getImage(
                source: ImageSource.gallery,
              );

              if (image != null) {
                await editorState.addImage(image.path);
              }
            } catch (e) {
              if (e is PlatformException && e.code == "photo_access_denied") {
                Navigator.of(context).pop();
                return;
              }
              reportError(e, StackTrace.current);
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}

Widget _buildBottomMenuSheet(
  BuildContext context,
  Editor editor,
  EditorState editorState,
  bool zenModeEnabled,
  Func0<void> zenModeChanged,
  bool metaDataEditable,
) {
  return Container(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.undo),
          title: Text(tr('editors.common.discard')),
          onTap: () {
            var note = editorState.getNote();
            Navigator.of(context).pop();

            editor.discardChangesSelected(note);
          },
          enabled: editorState.noteModified,
        ),
        ListTile(
          leading: const Icon(Icons.share),
          title: Text(tr('editors.common.share')),
          onTap: () {
            var note = editorState.getNote();
            Navigator.of(context).pop();

            shareNote(note);
          },
        ),
        if (metaDataEditable)
          ProOverlay(
            feature: Feature.tags,
            child: ListTile(
              leading: const FaIcon(FontAwesomeIcons.tag),
              title: Text(tr('editors.common.tags')),
              onTap: () {
                var note = editorState.getNote();
                Navigator.of(context).pop();

                editor.editTagsSelected(note);
              },
            ),
          ),
        ListTile(
          leading: const Icon(Icons.edit),
          title: Text(tr('editors.common.editFileName')),
          onTap: () {
            var note = editorState.getNote();
            Navigator.of(context).pop();

            editor.renameNoteSelected(note);
          },
        ),
        ProOverlay(
          feature: Feature.zenMode,
          child: ListTile(
            leading: const FaIcon(FontAwesomeIcons.peace),
            title: Text(tr(zenModeEnabled
                ? 'editors.common.zen.disable'
                : 'editors.common.zen.enable')),
            onTap: () {
              zenModeChanged();
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    ),
  );
}
