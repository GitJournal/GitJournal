import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/screens/note_editor.dart';
import 'package:gitjournal/settings.dart';
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
    content: Text(tr('widgets.FolderView.noteDeleted')),
    action: SnackBarAction(
      label: tr('widgets.FolderView.undo'),
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
  Settings settings,
  NotesFolderFS rootFolder,
  EditorType editorType,
) {
  var spec = settings.defaultNewNoteFolderSpec;

  switch (editorType) {
    case EditorType.Journal:
      spec = settings.journalEditordefaultNewNoteFolderSpec;
      break;
    default:
      break;
  }

  return rootFolder.getFolderWithSpec(spec) ?? rootFolder;
}

Future<void> showAlertDialog(
    BuildContext context, String title, String message) async {
  var dialog = AlertDialog(
    title: Text(title),
    content: Text(message),
  );
  return showDialog(context: context, builder: (context) => dialog);
}

bool folderWithSpecExists(BuildContext context, String spec) {
  var rootFolder = Provider.of<NotesFolderFS>(context, listen: false);

  return rootFolder.getFolderWithSpec(spec) != null;
}

String toCurlCommand(String url, Map<String, String> headers) {
  var headersStr = "";
  headers.forEach((key, value) {
    headersStr += ' -H "$key: $value" ';
  });

  return "curl -X GET '$url' $headersStr";
}
