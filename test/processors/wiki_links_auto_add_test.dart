import 'package:test/test.dart';

import 'package:gitjournal/core/notes_folder_config.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/core/processors/wiki_links_auto_add.dart';

void main() {
  test('Should process body', () {
    var body =
        "GitJournal is the best? And it works quite well with Foam, Foam and Obsidian.";

    var folder = NotesFolderFS(null, '/', NotesFolderConfig(''));
    var p = WikiLinksAutoAddProcessor(folder);
    var newBody = p.processBody(body, ['GitJournal', 'Foam', 'Obsidian']);
    var expectedBody =
        "[[GitJournal]] is the best? And it works quite well with [[Foam]], [[Foam]] and [[Obsidian]].";

    expect(newBody, expectedBody);
  });

  // Add a test to see if processing a Note works
  // FIXME: Make sure the wiki link terms do not have special characters
  // FIXME: WHat about piped links?
}
