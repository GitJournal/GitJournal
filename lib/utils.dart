import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

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

SnackBar buildUndoDeleteSnackbar(BuildContext context, Note deletedNote) {
  return SnackBar(
    content: const Text('Note Deleted'),
    action: SnackBarAction(
      label: "Undo",
      onPressed: () {
        Log.d("Undoing delete");

        var stateContainer =
            Provider.of<StateContainer>(context, listen: false);
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
