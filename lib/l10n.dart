/*
 * SPDX-FileCopyrightText: 2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

export 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension LocalizedBuildContext on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
  String tr(Lk key) {
    switch (key) {
      case Lk.empty:
        return "";

      case Lk.featureBasicSearch:
        return loc.featureBasicSearch;
      case Lk.featureDarkMode:
        return loc.featureDarkMode;
      case Lk.featureRawEditor:
        return loc.featureRawEditor;
      case Lk.featureFolderSupport:
        return loc.featureFolderSupport;
      case Lk.featureFileNameCustomize:
        return loc.featureFileNameCustomize;
      case Lk.featureYamlModifiedKey:
        return loc.featureYamlModifiedKey;
      case Lk.featureNoteMetaDataCustomizeTitle:
        return loc.featureNoteMetaDataCustomizeTitle;
      case Lk.featureNoteMetaDataCustomizeSubtitle:
        return loc.featureNoteMetaDataCustomizeSubtitle;
      case Lk.featureAutoMergeConflicts:
        return loc.featureAutoMergeConflicts;
      case Lk.featureNoteSorting:
        return loc.featureNoteSorting;
      case Lk.featureGitPushFreq:
        return loc.featureGitPushFreq;
      case Lk.featureEmojiSupportTitle:
        return loc.featureEmojiSupportTitle;
      case Lk.featureEmojiSupportSubtitle:
        return loc.featureEmojiSupportSubtitle;
      case Lk.featureChecklistEditor:
        return loc.featureChecklistEditor;
      case Lk.featureCustomSSHKeys:
        return loc.featureCustomSSHKeys;
      case Lk.featureDisableYamlHeader:
        return loc.featureDisableYamlHeader;
      case Lk.featureJournalEditor:
        return loc.featureJournalEditor;
      case Lk.featureAllNotesView:
        return loc.featureAllNotesView;
      case Lk.featureDiffViews:
        return loc.featureDiffViews;
      case Lk.featureJournalEditorDefaultFolder:
        return loc.featureJournalEditorDefaultFolder;
      case Lk.featureCustomizeHomeScreen:
        return loc.featureCustomizeHomeScreen;
      case Lk.featureImageSupport:
        return loc.featureImageSupport;
      case Lk.featureTags:
        return loc.featureTags;
      case Lk.featureAppShortcuts:
        return loc.featureAppShortcuts;
      case Lk.featureCreateRepo:
        return loc.featureCreateRepo;
      case Lk.featureBacklinks:
        return loc.featureBacklinks;
      case Lk.featureTxtFiles:
        return loc.featureTxtFiles;
      case Lk.featureWikiLinks:
        return loc.featureWikiLinks;
      case Lk.featureZenMode:
        return loc.featureZenMode;
      case Lk.featureMetaDataTitle:
        return loc.featureMetaDataTitle;
      case Lk.featureYamlCreatedKey:
        return loc.featureYamlCreatedKey;
      case Lk.featureYamlTagsKey:
        return loc.featureYamlTagsKey;
      case Lk.featureCustomMetaData:
        return loc.featureCustomMetaData;
      case Lk.featureLocalizationTitle:
        return loc.featureLocalizationTitle;
      case Lk.featureLocalizationSubtitle:
        return loc.featureLocalizationSubtitle;
      case Lk.featureInlineTags:
        return loc.featureInlineTags;
      case Lk.featureSingleJournalEntry:
        return loc.featureSingleJournalEntry;
      case Lk.featureConfigureBottomMenuBar:
        return loc.featureConfigureBottomMenuBar;
      case Lk.featureCustomFileNamePerEditor:
        return loc.featureCustomFileNamePerEditor;
      case Lk.featureMutliRepos:
        return loc.featureMutliRepos;
      case Lk.featureBranchSelection:
        return loc.featureBranchSelection;
      case Lk.featureInlineLatex:
        return loc.featureInlineLatex;
      case Lk.featureGraphVisualization:
        return loc.featureGraphVisualization;
      case Lk.featureGitLog:
        return loc.featureGitLog;
      case Lk.featureMarkdownToolbar:
        return loc.featureMarkdownToolbar;
      case Lk.featureCustomThemes:
        return loc.featureCustomThemes;
      case Lk.featureLatex:
        return loc.featureLatex;
      case Lk.featureMermaid:
        return loc.featureMermaid;
      case Lk.featureEncryptedHosting:
        return loc.featureEncryptedHosting;
      case Lk.featureDesktop:
        return loc.featureDesktop;
    }
  }
}

// Arranged Alphabetically
// Remember to update Info.plist
const gitJournalSupportedLocales = [
  Locale('de'),
  Locale('en'),
  Locale('es'),
  Locale('fr'),
  Locale('hu'),
  Locale('id'),
  Locale('it'),
  Locale('ja'),
  Locale('ko'),
  Locale('pl'),
  Locale('pt'),
  Locale('ru'),
  Locale('sv'),
  Locale('vi'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
];

Iterable<LocalizationsDelegate<dynamic>> buildDelegates(BuildContext context) {
  var easyLocale = EasyLocalization.of(context);

  return [
    if (easyLocale != null) ...easyLocale.delegates,
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

enum Lk {
  empty,
  featureBasicSearch,
  featureDarkMode,
  featureRawEditor,
  featureFolderSupport,
  featureFileNameCustomize,
  featureYamlModifiedKey,
  featureNoteMetaDataCustomizeTitle,
  featureNoteMetaDataCustomizeSubtitle,
  featureAutoMergeConflicts,
  featureNoteSorting,
  featureGitPushFreq,
  featureEmojiSupportTitle,
  featureEmojiSupportSubtitle,
  featureChecklistEditor,
  featureCustomSSHKeys,
  featureDisableYamlHeader,
  featureJournalEditor,
  featureAllNotesView,
  featureDiffViews,
  featureJournalEditorDefaultFolder,
  featureCustomizeHomeScreen,
  featureImageSupport,
  featureTags,
  featureAppShortcuts,
  featureCreateRepo,
  featureBacklinks,
  featureTxtFiles,
  featureWikiLinks,
  featureZenMode,
  featureMetaDataTitle,
  featureYamlCreatedKey,
  featureYamlTagsKey,
  featureCustomMetaData,
  featureLocalizationTitle,
  featureLocalizationSubtitle,
  featureInlineTags,
  featureSingleJournalEntry,
  featureConfigureBottomMenuBar,
  featureCustomFileNamePerEditor,
  featureMutliRepos,
  featureBranchSelection,
  featureInlineLatex,
  featureGraphVisualization,
  featureGitLog,
  featureMarkdownToolbar,
  featureCustomThemes,
  featureLatex,
  featureMermaid,
  featureEncryptedHosting,
  featureDesktop,
}
