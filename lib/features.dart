/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/foundation.dart' as foundation;
import 'package:gitjournal/l10n.dart';
import 'package:universal_io/io.dart' show Platform;

class Features {
  // Make the desktop version always pro, for now.
  static bool alwaysPro = foundation.kDebugMode ||
      Platform.isWindows ||
      Platform.isLinux ||
      Platform.isMacOS;

  static const fancyOrgEditor = false;

  static final all = <Feature>[
    Feature.basicSearch,
    Feature.darkMode,
    Feature.rawEditor,
    Feature.folderSupport,
    Feature.fileNameCustomize,
    Feature.noteMetaDataCustomize,
    Feature.autoMergeConflicts,
    Feature.yamlModifiedKey,
    Feature.noteSorting,
    Feature.gitPushFreq,
    Feature.emojiSupport,
    Feature.checkListEditor,
    Feature.customSSHKeys,
    Feature.disableYamlHeader,
    Feature.journalEditor,
    Feature.allNotesView,
    Feature.diffViews,
    Feature.journalEditorDefaultFolder,
    Feature.customizeHomeScreen,
    Feature.imageSupport,
    Feature.tags,
    Feature.appShortcuts,
    Feature.createRepo,
    Feature.backlinks,
    Feature.txtFiles,
    Feature.wikiLinks,
    Feature.zenMode,
    Feature.metaDataTitle,
    Feature.yamlCreatedKey,
    Feature.yamlTagsKey,
    Feature.customMetaData,
    Feature.localization,
    Feature.inlineTags,
    Feature.singleJournalEntry,
    Feature.configureBottomMenuBar,
    Feature.customFileNamePerEditor,
    Feature.multiRepos,
    Feature.branchSelection,
    Feature.inlineLatex,
  ];

  static final inProgress = <Lk>[
    Lk.featureGraphVisualization,
    Lk.featureGitLog,
    Lk.featureMarkdownToolbar,
  ];

  static final planned = <Lk>[
    Lk.featureCustomThemes,
    Lk.featureLatex,
    Lk.featureMermaid,
    Lk.featureEncryptedHosting,
    Lk.featureDesktop,
  ];
}

class Feature {
  final String featureName;
  final DateTime date;
  final Lk title;
  final Lk subtitle;
  final bool pro;

  Feature(this.featureName, this.date, this.title, this.subtitle, this.pro);

  static final basicSearch = Feature(
    "BasicSearch",
    DateTime(2019, 09, 15),
    Lk.featureBasicSearch,
    Lk.empty,
    false,
  );

  static final darkMode = Feature(
    "DarkMode",
    DateTime(2019, 09, 25),
    Lk.featureDarkMode,
    Lk.empty,
    false,
  );

  static final rawEditor = Feature(
    "RawEditor",
    DateTime(2019, 10, 07),
    Lk.featureRawEditor,
    Lk.empty,
    false,
  );

  static final folderSupport = Feature(
    "FolderSupport",
    DateTime(2019, 12, 04),
    Lk.featureFolderSupport,
    Lk.empty,
    false,
  );

  static final fileNameCustomize = Feature(
    "FileNameCustomize",
    DateTime(2019, 12, 20),
    Lk.featureFileNameCustomize,
    Lk.empty,
    false,
  );

  static final noteMetaDataCustomize = Feature(
    "NoteMetaDataCustomize",
    DateTime(2019, 12, 20),
    Lk.featureNoteMetaDataCustomizeTitle,
    Lk.featureNoteMetaDataCustomizeSubtitle,
    true,
  );

  static final autoMergeConflicts = Feature(
    "AutoMergeConflicts",
    DateTime(2019, 12, 28),
    Lk.featureAutoMergeConflicts,
    Lk.empty,
    false,
  );

  static final yamlModifiedKey = Feature(
    "YamlModifiedKey",
    DateTime(2020, 01, 05),
    Lk.featureYamlModifiedKey,
    Lk.empty,
    false,
  );

  static final noteSorting = Feature(
    "NoteSorting",
    DateTime(2020, 02, 09),
    Lk.featureNoteSorting,
    Lk.empty,
    false,
  );

  static final gitPushFreq = Feature(
    "GitPushFreq",
    DateTime(2020, 02, 09),
    Lk.featureGitPushFreq,
    Lk.empty,
    false,
  );

  static final emojiSupport = Feature(
    "EmojiSupport",
    DateTime(2020, 02, 14),
    Lk.featureEmojiSupportTitle,
    Lk.featureEmojiSupportSubtitle,
    false,
  );

  static final checkListEditor = Feature(
    "CheckListEditor",
    DateTime(2020, 02, 15),
    Lk.featureChecklistEditor,
    Lk.empty,
    false,
  );

  static final customSSHKeys = Feature(
    "CustomSSHKeys",
    DateTime(2020, 02, 17),
    Lk.featureCustomSSHKeys,
    Lk.empty,
    false,
  );

  static final disableYamlHeader = Feature(
    "DisableYamlHeader",
    DateTime(2020, 02, 18),
    Lk.featureDisableYamlHeader,
    Lk.empty,
    false,
  );

  static final journalEditor = Feature(
    "JournalEditor",
    DateTime(2020, 03, 01),
    Lk.featureJournalEditor,
    Lk.empty,
    false,
  );

  static final allNotesView = Feature(
    "AllNotesView",
    DateTime(2020, 03, 15),
    Lk.featureAllNotesView,
    Lk.empty,
    false,
  );

  static final diffViews = Feature(
    "DiffViews",
    DateTime(2020, 04, 01),
    Lk.featureDiffViews,
    Lk.empty,
    false,
  );

  static final journalEditorDefaultFolder = Feature(
    "JournalEditorDefaultFolder",
    DateTime(2020, 04, 01),
    Lk.featureJournalEditorDefaultFolder,
    Lk.empty,
    true,
  );

  static final customizeHomeScreen = Feature(
    "CustomizeHomeScreen",
    DateTime(2020, 05, 06),
    Lk.featureCustomizeHomeScreen,
    Lk.empty,
    true,
  );

  static final imageSupport = Feature(
    "ImageSupport",
    DateTime(2020, 05, 08),
    Lk.featureImageSupport,
    Lk.empty,
    false,
  );

  static final tags = Feature(
    "Tags",
    DateTime(2020, 05, 14),
    Lk.featureTags,
    Lk.empty,
    true,
  );

  static final appShortcuts = Feature(
    "AppShortcuts",
    DateTime(2020, 05, 14),
    Lk.featureAppShortcuts,
    Lk.empty,
    false,
  );

  static final createRepo = Feature(
    "CreateRepo",
    DateTime(2020, 05, 18),
    Lk.featureCreateRepo,
    Lk.empty,
    false,
  );

  static final backlinks = Feature(
    "Backlinks",
    DateTime(2020, 05, 27),
    Lk.featureBacklinks,
    Lk.empty,
    true,
  );

  static final txtFiles = Feature(
    "TxtFiles",
    DateTime(2020, 06, 03),
    Lk.featureTxtFiles,
    Lk.empty,
    false,
  );

  static final wikiLinks = Feature(
    "WikiLinks",
    DateTime(2020, 07, 09),
    Lk.featureWikiLinks,
    Lk.empty,
    false,
  );

  static final zenMode = Feature(
    "ZenMode",
    DateTime(2020, 07, 28),
    Lk.featureZenMode,
    Lk.empty,
    true,
  );

  static final metaDataTitle = Feature(
    "MetaDataTitle",
    DateTime(2020, 07, 30),
    Lk.featureMetaDataTitle,
    Lk.empty,
    false,
  );

  static final yamlCreatedKey = Feature(
    "YamlCreatedKey",
    DateTime(2020, 08, 02),
    Lk.featureYamlCreatedKey,
    Lk.empty,
    false,
  );

  static final yamlTagsKey = Feature(
    "yamlTagsKey",
    DateTime(2020, 08, 06),
    Lk.featureYamlTagsKey,
    Lk.empty,
    false,
  );

  static final customMetaData = Feature(
    "customMetaData",
    DateTime(2020, 08, 18),
    Lk.featureCustomMetaData,
    Lk.empty,
    true,
  );

  static final localization = Feature(
    "localization",
    DateTime(2020, 08, 30),
    Lk.featureLocalizationTitle,
    Lk.featureLocalizationSubtitle,
    false,
  );

  static final inlineTags = Feature(
    "inlineTags",
    DateTime(2020, 09, 02),
    Lk.featureInlineTags,
    Lk.empty,
    true,
  );

  static final singleJournalEntry = Feature(
    "singleJournalEntry",
    DateTime(2020, 09, 16),
    Lk.featureSingleJournalEntry,
    Lk.empty,
    true,
  );

  static final configureBottomMenuBar = Feature(
    "configureBottomMenuBar",
    DateTime(2020, 10, 05),
    Lk.featureConfigureBottomMenuBar,
    Lk.empty,
    true,
  );

  static final customFileNamePerEditor = Feature(
    "customFileNamePerEditor",
    DateTime(2020, 10, 05),
    Lk.featureCustomFileNamePerEditor,
    Lk.empty,
    true,
  );

  static final multiRepos = Feature(
    "multiRepos",
    DateTime(2021, 02, 20),
    Lk.featureMutliRepos,
    Lk.empty,
    true,
  );

  static final branchSelection = Feature(
    "multiRepos",
    DateTime(2021, 04, 20),
    Lk.featureBranchSelection,
    Lk.empty,
    false,
  );

  static final inlineLatex = Feature(
    "inlineLatex",
    DateTime(2022, 01, 1),
    Lk.featureInlineLatex,
    Lk.empty,
    true,
  );
}

// Feature Adding checklist
// 1. Add to this Feature class
// 2. Add to all features
// 3. Make sure strings are translatable
