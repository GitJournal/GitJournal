import 'package:flutter/material.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/screens/note_editor.dart';
import 'package:gitjournal/settings.dart';
import 'package:package_info/package_info.dart';

import 'app.dart';
import 'core/note.dart';
import 'state_container.dart';
import 'utils/logger.dart';

Future<String> getVersionString() async {
  var info = await PackageInfo.fromPlatform();
  var versionText = "";
  if (info != null) {
    versionText = info.appName + " " + info.version + "+" + info.buildNumber;

    if (JournalApp.isInDebugMode) {
      versionText += " (Debug)";
    }
  }

  return versionText;
}

SnackBar buildUndoDeleteSnackbar(
    StateContainer stateContainer, Note deletedNote) {
  return SnackBar(
    content: const Text('Note Deleted'),
    action: SnackBarAction(
      label: "Undo",
      onPressed: () {
        Log.d("Undoing delete");
        stateContainer.undoRemoveNote(deletedNote);
      },
    ),
  );
}

void showSnackbar(BuildContext context, String message) {
  var snackBar = SnackBar(content: Text(message));
  Scaffold.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(snackBar);
}

NotesFolderFS getFolderForEditor(
  NotesFolderFS rootFolder,
  EditorType editorType,
) {
  var spec = Settings.instance.defaultNewNoteFolderSpec;
  var journalSpec = Settings.instance.journalEditordefaultNewNoteFolderSpec;

  switch (editorType) {
    case EditorType.Journal:
      return rootFolder.getFolderWithSpec(journalSpec);
    default:
      return rootFolder.getFolderWithSpec(spec);
  }
}
