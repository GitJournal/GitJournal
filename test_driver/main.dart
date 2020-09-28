import 'dart:io';

import 'package:flutter_driver/driver_extension.dart';
import 'package:gitjournal/app_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:meta/meta.dart';

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

  final now = DateTime.now();

  // Write notes
  createChecklist(p.join(repoPath, "checklist.md"), DateTime.now());
  createNote(
    p.join(repoPath, "note1.md"),
    now,
    body: "Desire",
    title: "Haven't you always wanted such an app?",
  );
  createNote(
    p.join(repoPath, "note2.md"),
    now,
    body: "There is not a pipe",
  );

  createNote(
    p.join(repoPath, "note3.md"),
    now,
    body:
        "What are the different models for building sustainable Open Source Software?",
  );

  createNote(
    p.join(repoPath, "note-taking-apps.md"),
    now.add(const Duration(days: -2)),
    body:
        """There seems to be an explosion of Note Taking apps. Here are some of the Open Sources ones that I have found -

- Zettlr
- Foam
- Dendron
- Joplin
- SimpleNote
- Standard Notes
- TiddlyWiki
""",
  );

  createNote(
    p.join(repoPath, "note3.md"),
    now.add(const Duration(hours: -2)),
    body:
        "What are the different models for building sustainable Open Source Software?",
  );

  createNote(
    p.join(repoPath, "git-analogy.md"),
    now.add(const Duration(hours: -5)),
    body: "Perhaps Git could be explained as a virtual usb-drive",
    title: "Git Analogy",
  );

  createNote(
    p.join(repoPath, "open-source-analytics.md"),
    now.add(const Duration(hours: -5)),
    body: "Research what Open Source Alternative Exist for App Analytics",
  );

  createNote(
    p.join(repoPath, "lighting.md"),
    now.add(const Duration(hours: -5)),
    body: "But some lamps to make the office more cozy at night",
  );
}

void createNote(String filePath, DateTime dt,
    {@required String body, String title}) {
  var content = "";

  if (title == null) {
    content = """---
modified: ${toIso8601WithTimezone(dt)}
created: ${toIso8601WithTimezone(dt)}
---

$body
""";
  } else {
    content = """---
modified: ${toIso8601WithTimezone(dt)}
created: ${toIso8601WithTimezone(dt)}
title: $title
---

$body
""";
  }

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
