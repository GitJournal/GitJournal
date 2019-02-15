import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'app.dart';
import 'note.dart';
import 'state_container.dart';

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
  BuildContext context,
  Note deletedNote,
  int deletedNoteIndex,
) {
  var snackbar = SnackBar(
    content: Text("Note Deleted"),
    action: SnackBarAction(
      label: "Undo",
      onPressed: () {
        print("Undoing delete");
        var stateContainer = StateContainer.of(context);
        stateContainer.undoRemoveNote(deletedNote, deletedNoteIndex);
      },
    ),
  );

  return snackbar;
}
