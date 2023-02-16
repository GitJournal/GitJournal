/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:function_types/function_types.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/utils/utils.dart';
import 'package:gitjournal/widgets/pro_overlay.dart';
import 'package:image_picker/image_picker.dart';

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

  final Func0<void> onFindSelected;
  final bool findAllowed;

  const EditorBottomBar({
    super.key,
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
    required this.onFindSelected,
    required this.findAllowed,
  });

  @override
  Widget build(BuildContext context) {
    var addIcon = IconButton(
      icon: const Icon(Icons.attach_file),
      onPressed: () {
        var _ = showModalBottomSheet(
          context: context,
          builder: (c) => AddBottomSheet(editor, editorState),
          elevation: 0,
        );
      },
    );

    var menuIcon = IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () {
        var _ = showModalBottomSheet(
          context: context,
          builder: (c) => BottomMenuSheet(
            editor: editor,
            editorState: editorState,
            zenModeEnabled: zenMode,
            zenModeChanged: onZenModeChanged,
            metaDataEditable: metaDataEditable,
            findAllowed: findAllowed,
            onFindSelected: onFindSelected,
          ),
          elevation: 0,
        );
      },
    );

    var theme = Theme.of(context);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _Visibility(
              visible: allowEdits,
              child: addIcon,
            ),
            const Spacer(),
            _Visibility(
              visible: undoAllowed,
              child: IconButton(
                icon: const Icon(Icons.undo),
                onPressed: undoAllowed ? onUndoSelected : null,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.folder),
              label: Text(
                parentFolder.publicName(context),
                style: theme.textTheme.bodyMedium,
              ),
              onPressed: () {
                var note = editorState.getNote();
                editor.common.moveNoteToFolderSelected(note);
              },
            ),
            _Visibility(
              visible: redoAllowed,
              child: IconButton(
                icon: const Icon(Icons.redo),
                onPressed: redoAllowed ? onRedoSelected : null,
              ),
            ),
            const Spacer(),
            // Remove Material when https://github.com/flutter/flutter/issues/30658 is fixed
            Material(child: menuIcon),
          ],
        ),
      ),
    );
  }
}

class AddBottomSheet extends StatelessWidget {
  final Editor editor;
  final EditorState editorState;

  const AddBottomSheet(this.editor, this.editorState, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.camera),
          title: Text(context.loc.editorsCommonTakePhoto),
          onTap: () async {
            try {
              var image = await ImagePicker().pickImage(
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
          title: Text(context.loc.editorsCommonAddImage),
          onTap: () async {
            try {
              var image = await ImagePicker().pickImage(
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
    );
  }
}

class BottomMenuSheet extends StatelessWidget {
  final Editor editor;
  final EditorState editorState;
  final bool zenModeEnabled;
  final Func0<void> zenModeChanged;
  final bool metaDataEditable;

  final bool findAllowed;
  final Func0<void> onFindSelected;

  const BottomMenuSheet({
    super.key,
    required this.editor,
    required this.editorState,
    required this.zenModeEnabled,
    required this.zenModeChanged,
    required this.metaDataEditable,
    required this.onFindSelected,
    required this.findAllowed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.undo),
          title: Text(context.loc.editorsCommonDiscard),
          onTap: () {
            var note = editorState.getNote();
            Navigator.of(context).pop();

            editor.common.discardChanges(note);
          },
          enabled: editorState.noteModified,
        ),
        ListTile(
          leading: const Icon(Icons.share),
          title: Text(context.loc.editorsCommonShare),
          onTap: () {
            var note = editorState.getNote();
            Navigator.of(context).pop();

            shareNote(note);
          },
        ),
        if (metaDataEditable)
          ProOverlay(
            child: ListTile(
              leading: const FaIcon(FontAwesomeIcons.tag),
              title: Text(context.loc.editorsCommonTags),
              onTap: () {
                var note = editorState.getNote();
                Navigator.of(context).pop();

                editor.common.editTags(note);
              },
            ),
          ),
        ListTile(
          key: const ValueKey('EditFileNameButton'),
          leading: const Icon(Icons.edit),
          title: Text(context.loc.editorsCommonEditFileName),
          onTap: () {
            var note = editorState.getNote();
            Navigator.of(context).pop();

            editor.common.renameNote(note);
          },
        ),
        ProOverlay(
          child: ListTile(
            leading: const FaIcon(FontAwesomeIcons.peace),
            title: Text(zenModeEnabled
                ? context.loc.editorsCommonZenDisable
                : context.loc.editorsCommonZenEnable),
            onTap: () {
              zenModeChanged();
              Navigator.of(context).pop();
            },
          ),
        ),
        if (findAllowed)
          ListTile(
            leading: const Icon(Icons.search),
            title: Text(context.loc.editorsCommonFind),
            onTap: () {
              Navigator.of(context).pop();
              onFindSelected();
            },
          ),
      ],
    );
  }
}

class _Visibility extends StatelessWidget {
  final Widget child;
  final bool visible;

  const _Visibility({required this.child, required this.visible});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      // Remove Material when https://github.com/flutter/flutter/issues/30658 is fixed
      visible: visible,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      maintainInteractivity: false,
      // Remove Material when https://github.com/flutter/flutter/issues/30658 is fixed
      child: Material(child: child),
    );
  }
}
