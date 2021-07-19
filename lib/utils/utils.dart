import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/settings/settings.dart';
import '../app.dart';
import '../core/note.dart';
import '../editors/common_types.dart';
import '../repository.dart';
import 'logger.dart';

Future<String> getVersionString() async {
  var info = await PackageInfo.fromPlatform();
  var versionText = "";
  versionText = info.appName + " " + info.version + "+" + info.buildNumber;

  if (JournalApp.isInDebugMode) {
    versionText += " (Debug)";
  }

  return versionText;
}

SnackBar buildUndoDeleteSnackbar(
    GitJournalRepo stateContainer, Note deletedNote) {
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
  ScaffoldMessenger.of(context)
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

Future<void> shareNote(Note note) async {
  return Share.share(note.serialize());
}

Future<Note?> getTodayJournalEntry(NotesFolderFS rootFolder) async {
  var today = DateTime.now();
  var matches = await rootFolder.matchNotes((n) async {
    var dt = n.created;
    if (dt == null) {
      return false;
    }
    return dt.year == today.year &&
        dt.month == today.month &&
        dt.day == today.day;
  });

  return matches.isNotEmpty ? matches[0] : null;
}
