/*
 * SPDX-FileCopyrightText: 2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart' as io;

import 'package:gitjournal/core/file/file_storage.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/image.dart' as core;
import 'package:gitjournal/core/transformers/base.dart';
import 'package:gitjournal/editors/common.dart';

void main() {
  late NotesFolderFS rootFolder;
  late core.Image image;
  var hash = "8e9bec0ec76d06092355a34a79d3eea5";

  setUp(() async {
    var tempDir = await io.Directory.systemTemp.createTemp();
    var repoPath = tempDir.path + p.separator;

    SharedPreferences.setMockInitialValues({});
    var config = NotesFolderConfig('', await SharedPreferences.getInstance());
    var fileStorage = await FileStorage.fake(repoPath);

    rootFolder = NotesFolderFS.root(config, fileStorage);

    var currentDir = io.Directory.current;
    late String imagePath;
    if (p.basename(currentDir.path) == 'test') {
      imagePath = p.join(currentDir.path, 'testdata/icon.png');
    } else {
      imagePath = p.join(currentDir.path, 'test/testdata/icon.png');
    }

    image = await core.Image.copyIntoFs(rootFolder, imagePath);
  });

  test('Insert at end', () {
    var ts = TextEditorState("Hell ", 5);
    var val = insertImage(ts, image, NoteFileFormat.Markdown);

    expect(val.text, "Hell ![Image](./$hash.png) ");
    expect(val.cursorPos, val.text.length);
  });

  test('Insert in the middle', () {
    var ts = TextEditorState("Hello", 1);
    var val = insertImage(ts, image, NoteFileFormat.Markdown);

    var cp = " ![Image](./$hash.png) ".length;
    expect(val.text, "H ![Image](./$hash.png) ello");
    expect(val.cursorPos, cp + 1);
  });

  test('Empty', () {
    var ts = TextEditorState("", 0);
    var val = insertImage(ts, image, NoteFileFormat.Markdown);

    expect(val.text, "![Image](./$hash.png) ");
    expect(val.cursorPos, val.text.length);
  });

  test('Out of bounds', () {
    var ts = TextEditorState("", 1);
    var val = insertImage(ts, image, NoteFileFormat.Markdown);

    expect(val.text, "![Image](./$hash.png) ");
    expect(val.cursorPos, val.text.length);
  });
}
