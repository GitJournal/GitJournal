// SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dart_git/git.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time/time.dart';
import 'package:universal_io/io.dart';

import 'package:gitjournal/app.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:gitjournal/utils/datetime.dart';

Future<void> main() async {
  // enableFlutterDriverExtension();

  var pref = await SharedPreferences.getInstance();
  AppConfig.instance.load(pref);

  await populateWithData(pref);
  await JournalApp.main(pref);
}

// Generate lots of notes and folders better screenshots
Future<void> populateWithData(SharedPreferences pref) async {
  var dir = await getApplicationDocumentsDirectory();

  var repoPath = p.join(dir.path, "journal_local");
  await GitRepository.init(repoPath);

  stderr.writeln("Filling fake data in $repoPath");

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
    now.add(-2.days),
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
    now.add(-2.hours),
    body:
        "What are the different models for building sustainable Open Source Software?",
  );

  createNote(
    p.join(repoPath, "git-analogy.md"),
    now.add(-5.hours),
    body: "Perhaps Git could be explained as a virtual usb-drive",
    title: "Git Analogy",
  );

  createNote(
    p.join(repoPath, "open-source-analytics.md"),
    now.add(-5.hours),
    body: "Research what Open Source Alternative Exist for App Analytics",
  );

  createNote(
    p.join(repoPath, "lighting.md"),
    now.add(-5.hours),
    body: "But some lamps to make the office more cozy at night",
  );
}

void createNote(String filePath, DateTime dt,
    {required String body, String? title}) {
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
