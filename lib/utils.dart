import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'package:flushbar/flushbar.dart';

import 'app.dart';
import 'core/note.dart';
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

SnackBar buildUndoDeleteSnackbar(BuildContext context, Note deletedNote) {
  return SnackBar(
    content: const Text('Note Deleted'),
    action: SnackBarAction(
      label: "Undo",
      onPressed: () {
        Fimber.d("Undoing delete");

        var stateContainer = StateContainer.of(context);
        stateContainer.undoRemoveNote(deletedNote);
      },
    ),
  );
}

void showSnackbar(BuildContext context, String message) {
  Flushbar(
    message: message,
    duration: const Duration(seconds: 3),
  ).show(context);
}
