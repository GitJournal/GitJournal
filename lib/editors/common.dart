import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:function_types/function_types.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share/share.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/widgets/pro_overlay.dart';

export 'package:gitjournal/editors/scaffold.dart';

typedef NoteCallback = void Function(Note);

abstract class Editor {
  NoteCallback get noteDeletionSelected;
  NoteCallback get noteEditorChooserSelected;
  NoteCallback get exitEditorSelected;
  NoteCallback get renameNoteSelected;
  NoteCallback get editTagsSelected;
  NoteCallback get moveNoteToFolderSelected;
  NoteCallback get discardChangesSelected;
}

abstract class EditorState with ChangeNotifier {
  Note getNote();
  Future<void> addImage(File file);

  bool get noteModified;
}

class EditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Editor editor;
  final EditorState editorState;
  final bool noteModified;
  final IconButton extraButton;

  EditorAppBar({
    Key key,
    @required this.editor,
    @required this.editorState,
    @required this.noteModified,
    this.extraButton,
  })  : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        key: const ValueKey("NewEntry"),
        icon: Icon(noteModified ? Icons.check : Icons.close),
        onPressed: () {
          editor.exitEditorSelected(editorState.getNote());
        },
      ),
      actions: <Widget>[
        if (extraButton != null) extraButton,
        IconButton(
          key: const ValueKey("EditorSelector"),
          icon: const Icon(Icons.library_books),
          onPressed: () {
            var note = editorState.getNote();
            editor.noteEditorChooserSelected(note);
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            var note = editorState.getNote();
            editor.noteDeletionSelected(note);
          },
        ),
      ],
    );
  }
}

class EditorBottomBar extends StatelessWidget {
  final Editor editor;
  final EditorState editorState;
  final NotesFolderFS parentFolder;
  final bool allowEdits;
  final Func0<void> onZenModeChanged;

  EditorBottomBar({
    @required this.editor,
    @required this.editorState,
    @required this.parentFolder,
    @required this.allowEdits,
    @required this.onZenModeChanged,
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
          builder: (c) =>
              _buildBottomMenuSheet(c, editor, editorState, onZenModeChanged),
          elevation: 0,
        );
      },
    );

    return BottomAppBar(
      elevation: 0.0,
      color: Theme.of(context).scaffoldBackgroundColor,
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
          Expanded(
            child: FlatButton.icon(
              icon: const Icon(Icons.folder),
              label: Text(parentFolder.publicName),
              onPressed: () {
                var note = editorState.getNote();
                editor.moveNoteToFolderSelected(note);
              },
            ),
          ),
          menuIcon,
        ],
        mainAxisAlignment: MainAxisAlignment.center,
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
                await editorState.addImage(File(image.path));
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
                await editorState.addImage(File(image.path));
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
  Func0<void> zenModeChanged,
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

            Share.share(note.body);
          },
        ),
        ProOverlay(
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
          child: ListTile(
            leading: const FaIcon(FontAwesomeIcons.peace),
            title: Text(tr('editors.common.zen')),
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
