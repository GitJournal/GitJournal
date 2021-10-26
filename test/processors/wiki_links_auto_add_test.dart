/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart' as io;

import 'package:gitjournal/core/file/file_storage.dart';
import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/processors/wiki_links_auto_add.dart';

void main() {
  test('Should process body', () async {
    var body =
        "GitJournal is the best? And it works quite well with Foam, Foam and Obsidian.";

    SharedPreferences.setMockInitialValues({});
    var config = NotesFolderConfig('', await SharedPreferences.getInstance());

    var tempDir = await io.Directory.systemTemp.createTemp();
    var fileStorage = await FileStorage.fake(tempDir.path);

    var folder = NotesFolderFS.root(config, fileStorage);
    var p = WikiLinksAutoAddProcessor(folder);
    var newBody = p.processBody(body, ['GitJournal', 'Foam', 'Obsidian']);
    var expectedBody =
        "[[GitJournal]] is the best? And it works quite well with [[Foam]], [[Foam]] and [[Obsidian]].";

    expect(newBody, expectedBody);
  });

  // Add a test to see if processing a Note works
  // FIXME: Make sure the wiki link terms do not have special characters
  // FIXME: WHat about piped links?
  // FIXME: The wiki links can have a space
}
