import 'dart:io';

import 'package:flutter_driver/driver_extension.dart';
import 'package:gitjournal/app_settings.dart';
import 'package:path_provider/path_provider.dart';

import 'package:gitjournal/app.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils/datetime.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:dart_git/git.dart';

void main() async {
  enableFlutterDriverExtension();

  var pref = await SharedPreferences.getInstance();
  AppSettings.instance.load(pref);
  Settings.instance.load(pref);

  await populateWithData(pref);
  await JournalApp.main();
}

// Generate lots of notes and folders better screenshots
Future<void> populateWithData(SharedPreferences pref) async {
  var dir = await getApplicationDocumentsDirectory();

  var appSettings = AppSettings.instance;
  appSettings.gitBaseDirectory = dir.path;

  var settings = Settings.instance;
  settings.localGitRepoConfigured = true;
  settings.localGitRepoFolderName = "journal_local";
  settings.save();

  var repoPath = p.join(dir.path, settings.localGitRepoFolderName);
  await GitRepository.init(repoPath);

  print("Filling fake data in $repoPath");

  // Write Folders
  Directory(p.join(repoPath, "GitJournal")).createSync();
  Directory(p.join(repoPath, "Journal/Work")).createSync(recursive: true);
  Directory(p.join(repoPath, "Journal/Personal")).createSync(recursive: true);
  Directory(p.join(repoPath, "Food")).createSync();

  // Write notes
  createChecklist(p.join(repoPath, "checklist.md"), DateTime.now());
  createNoteWithTitle(
    p.join(repoPath, "note1.md"),
    DateTime.now(),
    "Desire",
    "Haven't you always wanted such an app?",
  );
  createNote(
    p.join(repoPath, "note2.md"),
    DateTime.now(),
    "There is not a pipe",
  );

  createNote(
    p.join(repoPath, "note2.md"),
    DateTime.now(),
    "There is not a pipe",
  );
}

void createNote(String filePath, DateTime dt, String body) {
  var content = """---
modified: ${toIso8601WithTimezone(dt)}
created: ${toIso8601WithTimezone(dt)}
---

$body
""";

  File(filePath).writeAsStringSync(content);
}

void createNoteWithTitle(
  String filePath,
  DateTime dt,
  String title,
  String body,
) {
  var content = """---
modified: ${toIso8601WithTimezone(dt)}
created: ${toIso8601WithTimezone(dt)}
title: $title
---

$body
""";

  File(filePath).writeAsStringSync(content);
}

void createChecklist(String filePath, DateTime dt) {
  var content = """---
modified: ${toIso8601WithTimezone(dt)}
created: ${toIso8601WithTimezone(dt)}
title: Shopping List
type: Checklist
---

- [ ] Bananas
- [ ] Rice
- [ ] Cat Food
- [x] Tomatoes
""";

  File(filePath).writeAsStringSync(content);
}
