import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/core/sorting_mode.dart';
import 'package:gitjournal/editors/common_types.dart';
import 'package:gitjournal/folder_views/common.dart';
import 'package:gitjournal/folder_views/standard_view.dart';
import 'package:gitjournal/settings/settings.dart';

@immutable
class NotesFolderConfig extends Equatable {
  static const FILENAME = ".gitjournal.yaml";

  final SortingMode sortingMode;
  final EditorType defaultEditor;
  final FolderViewType defaultView;

  final StandardViewHeader viewHeader;
  final bool showNoteSummary;
  final NoteFileNameFormat fileNameFormat;
  final NoteFileNameFormat journalFileNameFormat;
  final NotesFolderFS? folder;
  final bool yamlHeaderEnabled;
  //int _version = 1;

  final String yamlModifiedKey;
  final String yamlCreatedKey;
  final String yamlTagsKey;
  final SettingsTitle titleSettings;

  final Set<String> inlineTagPrefixes;
  final String imageLocationSpec;

  NotesFolderConfig({
    required this.sortingMode,
    required this.defaultEditor,
    required this.defaultView,
    required this.viewHeader,
    required this.showNoteSummary,
    required this.fileNameFormat,
    required this.journalFileNameFormat,
    required this.folder,
    required this.yamlHeaderEnabled,
    required this.yamlModifiedKey,
    required this.yamlCreatedKey,
    required this.yamlTagsKey,
    required this.titleSettings,
    required this.inlineTagPrefixes,
    required this.imageLocationSpec,
  });

  @override
  List<Object> get props => [
        sortingMode,
        defaultEditor,
        defaultView,
        viewHeader,
        fileNameFormat,
        journalFileNameFormat,
        if (folder != null) folder!,
        yamlHeaderEnabled,
        yamlModifiedKey,
        yamlCreatedKey,
        yamlTagsKey,
        titleSettings,
        inlineTagPrefixes,
        imageLocationSpec,
      ];

  static NotesFolderConfig fromSettings(
      NotesFolderFS? folder, Settings settings) {
    late StandardViewHeader viewHeader;
    switch (settings.folderViewHeaderType) {
      case "TitleGenerated":
        viewHeader = StandardViewHeader.TitleGenerated;
        break;
      case "FileName":
        viewHeader = StandardViewHeader.FileName;
        break;
      case "TitleOrFileName":
      default:
        viewHeader = StandardViewHeader.TitleOrFileName;
        break;
    }

    return NotesFolderConfig(
      defaultEditor: settings.defaultEditor.toEditorType(),
      defaultView: settings.defaultView.toFolderViewType(),
      sortingMode: SortingMode(settings.sortingField, settings.sortingOrder),
      showNoteSummary: settings.showNoteSummary,
      viewHeader: viewHeader,
      fileNameFormat: settings.noteFileNameFormat,
      journalFileNameFormat: settings.journalNoteFileNameFormat,
      folder: folder,
      yamlHeaderEnabled: settings.yamlHeaderEnabled,
      yamlCreatedKey: settings.yamlCreatedKey,
      yamlModifiedKey: settings.yamlModifiedKey,
      yamlTagsKey: settings.yamlTagsKey,
      titleSettings: settings.titleSettings,
      inlineTagPrefixes: settings.inlineTagPrefixes,
      imageLocationSpec: settings.imageLocationSpec,
    );
  }

  Future<void> saveToSettings(Settings settings) async {
    settings.sortingField = sortingMode.field;
    settings.sortingOrder = sortingMode.order;
    settings.showNoteSummary = showNoteSummary;
    settings.defaultEditor = SettingsEditorType.fromEditorType(defaultEditor);
    settings.defaultView =
        SettingsFolderViewType.fromFolderViewType(defaultView);

    String? ht;
    switch (viewHeader) {
      case StandardViewHeader.FileName:
        ht = "FileName";
        break;
      case StandardViewHeader.TitleGenerated:
        ht = "TitleGenerated";
        break;
      case StandardViewHeader.TitleOrFileName:
        ht = "TitleOrFileName";
        break;
    }
    settings.folderViewHeaderType = ht;
    settings.noteFileNameFormat = fileNameFormat;
    settings.journalNoteFileNameFormat = journalFileNameFormat;
    settings.yamlHeaderEnabled = yamlHeaderEnabled;
    settings.yamlCreatedKey = yamlCreatedKey;
    settings.yamlModifiedKey = yamlModifiedKey;
    settings.yamlTagsKey = yamlTagsKey;
    settings.titleSettings = titleSettings;
    settings.inlineTagPrefixes = inlineTagPrefixes;
    settings.imageLocationSpec = imageLocationSpec;
    settings.save();
  }

  NotesFolderConfig copyWith({
    SortingMode? sortingMode,
    EditorType? defaultEditor,
    FolderViewType? defaultView,
    StandardViewHeader? viewHeader,
    bool? showNoteSummary,
    NoteFileNameFormat? fileNameFormat,
    NoteFileNameFormat? journalFileNameFormat,
    NotesFolderFS? folder,
    bool? yamlHeaderEnabled,
    String? yamlCreatedKey,
    String? yamlModifiedKey,
    String? yamlTagsKey,
    SettingsTitle? titleSettings,
    Set<String>? inlineTagPrefixes,
    String? imageLocationSpec,
  }) {
    return NotesFolderConfig(
      sortingMode: sortingMode ?? this.sortingMode,
      defaultEditor: defaultEditor ?? this.defaultEditor,
      defaultView: defaultView ?? this.defaultView,
      viewHeader: viewHeader ?? this.viewHeader,
      showNoteSummary: showNoteSummary ?? this.showNoteSummary,
      fileNameFormat: fileNameFormat ?? this.fileNameFormat,
      journalFileNameFormat:
          journalFileNameFormat ?? this.journalFileNameFormat,
      folder: folder ?? this.folder,
      yamlHeaderEnabled: yamlHeaderEnabled ?? this.yamlHeaderEnabled,
      yamlCreatedKey: yamlCreatedKey ?? this.yamlCreatedKey,
      yamlModifiedKey: yamlModifiedKey ?? this.yamlModifiedKey,
      yamlTagsKey: yamlTagsKey ?? this.yamlTagsKey,
      titleSettings: titleSettings ?? this.titleSettings,
      inlineTagPrefixes: inlineTagPrefixes ?? this.inlineTagPrefixes,
      imageLocationSpec: imageLocationSpec ?? this.imageLocationSpec,
    );
  }
}
