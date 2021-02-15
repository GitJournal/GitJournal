import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:gitjournal/core/notes_folder_config.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/core/sorting_mode.dart';
import 'package:gitjournal/folder_views/common.dart';
import 'package:gitjournal/folder_views/standard_view.dart';
import 'package:gitjournal/screens/note_editor.dart';
import 'package:gitjournal/settings.dart';

void main() {
  group('Notes Folder Config', () {
    Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('__notes_config_test__');
    });

    tearDown(() async {
      tempDir.deleteSync(recursive: true);
    });

    test('Should load from FS correctly', () async {
      var folder = NotesFolderFS(null, tempDir.path, Settings(''));
      var config = NotesFolderConfig(
        defaultEditor: EditorType.Checklist,
        defaultView: FolderViewType.Standard,
        showNoteSummary: true,
        sortingMode:
            SortingMode(SortingField.Modified, SortingOrder.Descending),
        viewHeader: StandardViewHeader.TitleOrFileName,
        fileNameFormat: NoteFileNameFormat.Default,
        journalFileNameFormat: NoteFileNameFormat.Default,
        folder: folder,
        yamlHeaderEnabled: true,
        yamlCreatedKey: 'created',
        yamlModifiedKey: 'modified',
        yamlTagsKey: 'tags',
        titleSettings: SettingsTitle.InYaml,
        inlineTagPrefixes: {},
        imageLocationSpec: "",
      );

      await config.saveToFS();
      var file = File(p.join(tempDir.path, NotesFolderConfig.FILENAME));
      expect(file.existsSync(), true);

      var config2 = await NotesFolderConfig.fromFS(folder);
      expect(config, config2);
    });
  });
}
