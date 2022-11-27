/*
 * SPDX-FileCopyrightText: 2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

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
      case Lk.settingsSortingOrderDesc:
        return loc.settingsSortingOrderDesc;
      case Lk.settingsSortingFieldCreated:
        return loc.settingsSortingFieldCreated;
      case Lk.settingsSortingFieldFilename:
        return loc.settingsSortingFieldFilename;
      case Lk.settingsSortingFieldModified:
        return loc.settingsSortingFieldModified;
      case Lk.settingsNoteMetaDataUnixTimestampDateMagnitudeSeconds:
        return loc.settingsNoteMetaDataUnixTimestampDateMagnitudeSeconds;
      case Lk.settingsNoteMetaDataUnixTimestampDateMagnitudeMilliseconds:
        return loc.settingsNoteMetaDataUnixTimestampDateMagnitudeMilliseconds;
      case Lk.settingsNoteMetaDataDateFormatIso8601:
        return loc.settingsNoteMetaDataDateFormatIso8601;
      case Lk.settingsNoteMetaDataDateFormatUnixTimestamp:
        return loc.settingsNoteMetaDataDateFormatUnixTimestamp;
      case Lk.settingsNoteMetaDataDateFormatNone:
        return loc.settingsNoteMetaDataDateFormatNone;
      case Lk.settingsDisplayImagesThemingThemeVectorGraphicsOff:
        return loc.settingsDisplayImagesThemingThemeVectorGraphicsOff;
      case Lk.settingsDisplayImagesThemingThemeVectorGraphicsOn:
        return loc.settingsDisplayImagesThemingThemeVectorGraphicsOn;
      case Lk.settingsDisplayImagesThemingThemeVectorGraphicsFilter:
        return loc.settingsDisplayImagesThemingThemeVectorGraphicsFilter;
      case Lk.settingsDisplayImagesThemingAdjustColorsGrays:
        return loc.settingsDisplayImagesThemingAdjustColorsGrays;
      case Lk.settingsDisplayImagesThemingAdjustColorsBlackAndWhite:
        return loc.settingsDisplayImagesThemingAdjustColorsBlackAndWhite;
      case Lk.settingsDisplayImagesThemingAdjustColorsAll:
        return loc.settingsDisplayImagesThemingAdjustColorsAll;
      case Lk.settingsDisplayImagesImageTextTypeAltAndTooltip:
        return loc.settingsDisplayImagesImageTextTypeAltAndTooltip;
      case Lk.settingsDisplayImagesImageTextTypeTooltip:
        return loc.settingsDisplayImagesImageTextTypeTooltip;
      case Lk.settingsDisplayImagesImageTextTypeAlt:
        return loc.settingsDisplayImagesImageTextTypeAlt;
      case Lk.settingsDisplayImagesImageTextTypeNone:
        return loc.settingsDisplayImagesImageTextTypeNone;
      case Lk.settingsNoteFileNameFormatIso8601WithTimeZone:
        return loc.settingsNoteFileNameFormatIso8601WithTimeZone;
      case Lk.settingsNoteFileNameFormatKebabCase:
        return loc.settingsNoteFileNameFormatKebabCase;
      case Lk.settingsNoteFileNameFormatDateOnly:
        return loc.settingsNoteFileNameFormatDateOnly;
      case Lk.settingsNoteFileNameFormatIso8601WithoutColon:
        return loc.settingsNoteFileNameFormatIso8601WithoutColon;
      case Lk.settingsNoteFileNameFormatUuid:
        return loc.settingsNoteFileNameFormatUuid;
      case Lk.settingsNoteFileNameFormatSimple:
        return loc.settingsNoteFileNameFormatSimple;
      case Lk.settingsNoteFileNameFormatTitle:
        return loc.settingsNoteFileNameFormatTitle;
      case Lk.settingsNoteFileNameFormatZettelkasten:
        return loc.settingsNoteFileNameFormatZettelkasten;
      case Lk.settingsNoteFileNameFormatIso8601:
        return loc.settingsNoteFileNameFormatIso8601;
      case Lk.settingsRemoteSyncManual:
        return loc.settingsRemoteSyncManual;
      case Lk.settingsRemoteSyncAuto:
        return loc.settingsRemoteSyncAuto;
      case Lk.widgetsFolderViewViewsStandard:
        return loc.widgetsFolderViewViewsStandard;
      case Lk.widgetsFolderViewViewsJournal:
        return loc.widgetsFolderViewViewsJournal;
      case Lk.widgetsFolderViewViewsCard:
        return loc.widgetsFolderViewViewsCard;
      case Lk.widgetsFolderViewViewsGrid:
        return loc.widgetsFolderViewViewsGrid;
      case Lk.widgetsFolderViewViewsCalendar:
        return loc.widgetsFolderViewViewsCalendar;
      case Lk.settingsFileFormatOrgMode:
        return loc.settingsFileFormatOrgMode;
      case Lk.settingsFileFormatTxt:
        return loc.settingsFileFormatTxt;
      case Lk.settingsFileFormatMarkdown:
        return loc.settingsFileFormatMarkdown;
      case Lk.settingsEditorsRawEditor:
        return loc.settingsEditorsRawEditor;
      case Lk.settingsEditorsMarkdownEditor:
        return loc.settingsEditorsMarkdownEditor;
      case Lk.settingsEditorsJournalEditor:
        return loc.settingsEditorsJournalEditor;
      case Lk.settingsEditorsChecklistEditor:
        return loc.settingsEditorsChecklistEditor;
      case Lk.settingsEditorsOrgEditor:
        return loc.settingsEditorsOrgEditor;
      case Lk.settingsEditorDefaultViewEdit:
        return loc.settingsEditorDefaultViewEdit;
      case Lk.settingsEditorDefaultViewView:
        return loc.settingsEditorDefaultViewView;
      case Lk.settingsEditorDefaultViewLastUsed:
        return loc.settingsEditorDefaultViewLastUsed;
      case Lk.settingsHomeScreenAllNotes:
        return loc.settingsHomeScreenAllNotes;
      case Lk.settingsHomeScreenAllFolders:
        return loc.settingsHomeScreenAllFolders;
      case Lk.settingsThemeDark:
        return loc.settingsThemeDark;
      case Lk.settingsThemeLight:
        return loc.settingsThemeLight;
      case Lk.settingsThemeDefault:
        return loc.settingsThemeDefault;
      case Lk.settingsNoteMetaDataTitleMetaDataFromYaml:
        return loc.settingsNoteMetaDataTitleMetaDataFromYaml;
      case Lk.settingsNoteMetaDataTitleMetaDataFromH1:
        return loc.settingsNoteMetaDataTitleMetaDataFromH1;
      case Lk.settingsNoteMetaDataTitleMetaDataFilename:
        return loc.settingsNoteMetaDataTitleMetaDataFilename;
      case Lk.settingsSshKeyEd25519:
        return loc.settingsSshKeyEd25519;
      case Lk.settingsSshKeyRsa:
        return loc.settingsSshKeyRsa;
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
  return [
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
  settingsSortingOrderDesc,
  settingsSortingFieldCreated,
  settingsSortingFieldFilename,
  settingsSortingFieldModified,
  settingsNoteMetaDataUnixTimestampDateMagnitudeSeconds,
  settingsNoteMetaDataUnixTimestampDateMagnitudeMilliseconds,
  settingsNoteMetaDataDateFormatIso8601,
  settingsNoteMetaDataDateFormatUnixTimestamp,
  settingsNoteMetaDataDateFormatNone,
  settingsDisplayImagesThemingThemeVectorGraphicsOff,
  settingsDisplayImagesThemingThemeVectorGraphicsOn,
  settingsDisplayImagesThemingThemeVectorGraphicsFilter,
  settingsDisplayImagesThemingAdjustColorsGrays,
  settingsDisplayImagesThemingAdjustColorsBlackAndWhite,
  settingsDisplayImagesThemingAdjustColorsAll,
  settingsDisplayImagesImageTextTypeAltAndTooltip,
  settingsDisplayImagesImageTextTypeTooltip,
  settingsDisplayImagesImageTextTypeAlt,
  settingsDisplayImagesImageTextTypeNone,
  settingsNoteFileNameFormatIso8601WithTimeZone,
  settingsNoteFileNameFormatKebabCase,
  settingsNoteFileNameFormatDateOnly,
  settingsNoteFileNameFormatIso8601WithoutColon,
  settingsNoteFileNameFormatUuid,
  settingsNoteFileNameFormatSimple,
  settingsNoteFileNameFormatTitle,
  settingsNoteFileNameFormatZettelkasten,
  settingsNoteFileNameFormatIso8601,
  settingsRemoteSyncManual,
  settingsRemoteSyncAuto,
  widgetsFolderViewViewsStandard,
  widgetsFolderViewViewsJournal,
  widgetsFolderViewViewsCard,
  widgetsFolderViewViewsGrid,
  widgetsFolderViewViewsCalendar,
  settingsFileFormatOrgMode,
  settingsFileFormatTxt,
  settingsFileFormatMarkdown,
  settingsEditorsRawEditor,
  settingsEditorsMarkdownEditor,
  settingsEditorsJournalEditor,
  settingsEditorsChecklistEditor,
  settingsEditorsOrgEditor,
  settingsEditorDefaultViewEdit,
  settingsEditorDefaultViewView,
  settingsEditorDefaultViewLastUsed,
  settingsHomeScreenAllNotes,
  settingsHomeScreenAllFolders,
  settingsThemeDark,
  settingsThemeLight,
  settingsThemeDefault,
  settingsNoteMetaDataTitleMetaDataFromYaml,
  settingsNoteMetaDataTitleMetaDataFromH1,
  settingsNoteMetaDataTitleMetaDataFilename,
  settingsSshKeyEd25519,
  settingsSshKeyRsa,
}
