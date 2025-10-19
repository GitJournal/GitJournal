// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get pro => 'Про';

  @override
  String get rootFolder => 'Корневой каталог';

  @override
  String get beta => 'BETA';

  @override
  String get none => 'None';

  @override
  String get settingsOk => 'Ok';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAuthorLabel => 'Author Name';

  @override
  String get settingsAuthorValidator => 'Please enter a name';

  @override
  String get settingsEmailLabel => 'Email Address';

  @override
  String get settingsEmailValidatorEmpty => 'Please enter an email';

  @override
  String get settingsEmailValidatorInvalid => 'Please enter a valid email';

  @override
  String get settingsDisplayTitle => 'Display Settings';

  @override
  String get settingsDisplayHomeScreen => 'Home Screen';

  @override
  String get settingsDisplayTheme => 'Theme';

  @override
  String get settingsDisplayImagesTitle => 'Image Settings';

  @override
  String get settingsDisplayImagesSubtitle =>
      'Configure how images are displayed';

  @override
  String get settingsDisplayImagesImageTextTypeAlt => 'Alt Text';

  @override
  String get settingsDisplayImagesImageTextTypeAltAndTooltip =>
      'Alt Text and Tooltip';

  @override
  String get settingsDisplayImagesImageTextTypeTooltip => 'Tooltip';

  @override
  String get settingsDisplayImagesImageTextTypeNone => 'None';

  @override
  String get settingsDisplayImagesCaptionsTitle => 'Image Captions';

  @override
  String get settingsDisplayImagesCaptionsSubtitle =>
      'Configure the image captions';

  @override
  String get settingsDisplayImagesCaptionsUseAsCaption => 'Use as caption';

  @override
  String get settingsDisplayImagesCaptionsOverlayCaption =>
      'Draw caption on top of large enough images';

  @override
  String get settingsDisplayImagesCaptionsTransparentCaption =>
      'Overlay captions have a semitransparent background';

  @override
  String get settingsDisplayImagesCaptionsBlurBehindCaption =>
      'Blur Image behind caption';

  @override
  String get settingsDisplayImagesCaptionsTooltipFirstTitle =>
      'Show tooltip before alt text';

  @override
  String get settingsDisplayImagesCaptionsTooltipFirstTooltip =>
      'Current order is “<tooltip> - <altText>”';

  @override
  String get settingsDisplayImagesCaptionsTooltipFirstAltText =>
      'Current order is “<altText> - <tooltip>”';

  @override
  String get settingsDisplayImagesCaptionsCaptionOverrides =>
      'Caption Overrides';

  @override
  String get settingsDisplayImagesCaptionsTagDescription =>
      'Put these tags in “![altText](... \"tooltip\")” to override the behavior for it.';

  @override
  String get settingsDisplayImagesCaptionsDoNotCaptionTagsHint =>
      'DoNotCaption-Tags';

  @override
  String get settingsDisplayImagesCaptionsDoNotCaptionTagsLabel =>
      'Never use as caption with tags';

  @override
  String get settingsDisplayImagesCaptionsDoNotCaptionTagsValidatorEmpty =>
      'Tags cannot be empty.';

  @override
  String get settingsDisplayImagesCaptionsDoNotCaptionTagsValidatorSame =>
      'Tag cannot be identical to a “DoCaption-Tag”.';

  @override
  String get settingsDisplayImagesCaptionsDoCaptionTagsHint => 'DoCaption-Tags';

  @override
  String get settingsDisplayImagesCaptionsDoCaptionTagsLabel =>
      'Always use as caption with tags';

  @override
  String get settingsDisplayImagesCaptionsDoCaptionTagsValidatorEmpty =>
      'Tags cannot be empty.';

  @override
  String get settingsDisplayImagesCaptionsDoCaptionTagsValidatorSame =>
      'Tag cannot be identical to a “DoNotCaption-Tag”.';

  @override
  String get settingsDisplayImagesDetailsViewHeader => 'Detail View';

  @override
  String get settingsDisplayImagesDetailsViewMaxZoom => 'Maximal zoom level';

  @override
  String get settingsDisplayImagesDetailsViewRotateGesturesTitle =>
      'Rotate Image with gestures';

  @override
  String get settingsDisplayImagesDetailsViewRotateGesturesSubtitle =>
      'Rotate by moving two fingers in a circle';

  @override
  String get settingsDisplayImagesThemingTitle => 'Image Theming';

  @override
  String get settingsDisplayImagesThemingSubtitle =>
      'Configure how images are themed';

  @override
  String get settingsDisplayImagesThemingAdjustColorsAll => 'All';

  @override
  String get settingsDisplayImagesThemingAdjustColorsBlackAndWhite =>
      'Only black and white';

  @override
  String get settingsDisplayImagesThemingAdjustColorsGrays => 'Only grays';

  @override
  String get settingsDisplayImagesThemingDoNotThemeTagsHint =>
      'DoNotTheme-Tags';

  @override
  String get settingsDisplayImagesThemingDoNotThemeTagsLabel =>
      'Never theme images with tags';

  @override
  String get settingsDisplayImagesThemingDoNotThemeTagsValidatorEmpty =>
      'Tags cannot be empty.';

  @override
  String get settingsDisplayImagesThemingDoNotThemeTagsValidatorSame =>
      'Tag cannot be identical to a “DoTheme-Tag”.';

  @override
  String get settingsDisplayImagesThemingDoThemeTagsHint => 'DoTheme-Tag';

  @override
  String get settingsDisplayImagesThemingDoThemeTagsLabel =>
      'Always theme images with tags';

  @override
  String get settingsDisplayImagesThemingDoThemeTagsValidatorEmpty =>
      'Tags cannot be empty.';

  @override
  String get settingsDisplayImagesThemingDoThemeTagsValidatorSame =>
      'Tag cannot be identical to a “DoNotTheme-Tag”.';

  @override
  String get settingsDisplayImagesThemingMatchCanvasColorTitle =>
      'Match Background Color';

  @override
  String get settingsDisplayImagesThemingMatchCanvasColorSubtitle =>
      'Replaces white/black parts of vector graphics with the canvas color';

  @override
  String get settingsDisplayImagesThemingTagDescription =>
      'Put these tags in “![altText](... \"tooltip\")” to override the behavior for the image.';

  @override
  String get settingsDisplayImagesThemingThemeOverrides => 'Theme Overrides';

  @override
  String get settingsDisplayImagesThemingThemeOverrideTagLocation =>
      'Theme Override Tag Location';

  @override
  String get settingsDisplayImagesThemingThemeRasterGraphics =>
      'Theme Raster Graphics (.png/.jpg)';

  @override
  String get settingsDisplayImagesThemingThemeSvgWithBackground =>
      'Theme SVGs With Background';

  @override
  String get settingsDisplayImagesThemingThemeVectorGraphicsTitle =>
      'Theme Vector Graphics';

  @override
  String get settingsDisplayImagesThemingThemeVectorGraphicsFilter =>
      'Using Color Filter';

  @override
  String get settingsDisplayImagesThemingThemeVectorGraphicsOff => 'false';

  @override
  String get settingsDisplayImagesThemingThemeVectorGraphicsOn => 'true';

  @override
  String get settingsDisplayImagesThemingVectorGraphics =>
      'Vector Graphics (.svg)';

  @override
  String get settingsDisplayImagesThemingVectorGraphicsAdjustColors =>
      'Colors to Adjust';

  @override
  String get settingsDisplayLang => 'Language';

  @override
  String get settingsGitAuthor => 'Git Author Settings';

  @override
  String get settingsVersionInfo => 'GitJournal Version';

  @override
  String get settingsAnalytics => 'Analytics';

  @override
  String get settingsCrashReports => 'Collect Anonymous Crash Reports';

  @override
  String get settingsUsageStats => 'Collect Anonymous Usage Statistics';

  @override
  String get settingsDebugTitle => 'Debug App';

  @override
  String get settingsDebugSubtitle => 'Look under the hood';

  @override
  String get settingsDebugLevelsTitle => 'Select Level';

  @override
  String get settingsDebugLevelsError => 'Error';

  @override
  String get settingsDebugLevelsWarning => 'warning';

  @override
  String get settingsDebugLevelsInfo => 'Info';

  @override
  String get settingsDebugLevelsDebug => 'Debug';

  @override
  String get settingsDebugLevelsVerbose => 'Verbose';

  @override
  String get settingsDebugCopy => 'Debug Logs Copied';

  @override
  String get settingsImagesTitle => 'Image Settings';

  @override
  String get settingsImagesSubtitle => 'Configure how Images are stored';

  @override
  String get settingsImagesImageLocation => 'Image Location';

  @override
  String get settingsImagesCurrentFolder => 'Same Folder as Note';

  @override
  String get settingsImagesCustomFolder => 'Custom Folder';

  @override
  String get settingsGitRemoteChangeHostTitle => 'Reconfigure Git Host';

  @override
  String get settingsGitRemoteChangeHostSubtitle =>
      'Notes which have not been synced will be lost';

  @override
  String get settingsGitRemoteChangeHostOk => 'Ok';

  @override
  String get settingsGitRemoteChangeHostCancel => 'Cancel';

  @override
  String get settingsGitRemoteTitle => 'Git Remote Settings';

  @override
  String get settingsGitRemoteSubtitle =>
      'Configure where your notes are synced';

  @override
  String get settingsGitRemoteHost => 'Git Host';

  @override
  String get settingsGitRemoteBranch => 'Branch';

  @override
  String get settingsGitRemoteResetHardTitle => 'Reset Git Host';

  @override
  String get settingsGitRemoteResetHardSubtitle =>
      'This will HARD reset the current branch to its remote';

  @override
  String get settingsNoteMetaDataTitle => 'Note Metadata Settings';

  @override
  String get settingsNoteMetaDataSubtitle =>
      'Configure how the Note Metadata is saved';

  @override
  String get settingsNoteMetaDataText =>
      'Every note has some metadata which is stored in a YAML Header as follows -';

  @override
  String get settingsNoteMetaDataEnableHeader => 'Enable YAML Header';

  @override
  String get settingsNoteMetaDataModified => 'Modified Field';

  @override
  String get settingsNoteMetaDataCreated => 'Created Field';

  @override
  String get settingsNoteMetaDataTags => 'Tags Field';

  @override
  String get settingsNoteMetaDataExampleTitle => 'Pigeons';

  @override
  String get settingsNoteMetaDataTitleMetaDataTitle => 'Title';

  @override
  String get settingsNoteMetaDataTitleMetaDataFromH1 => 'Text Header 1';

  @override
  String get settingsNoteMetaDataTitleMetaDataFromYaml => 'From YAML \'title\'';

  @override
  String get settingsNoteMetaDataTitleMetaDataFilename => 'FileName';

  @override
  String get settingsNoteMetaDataExampleBody =>
      'I think they might be evil. Even more evil than penguins.';

  @override
  String get settingsNoteMetaDataExampleTag1 => 'Birds';

  @override
  String get settingsNoteMetaDataExampleTag2 => 'Evil';

  @override
  String get settingsNoteMetaDataCustomMetaDataTitle => 'Custom MetaData';

  @override
  String get settingsNoteMetaDataCustomMetaDataInvalid => 'Invalid YAML';

  @override
  String get settingsNoteMetaDataOutput => 'Output';

  @override
  String get settingsNoteMetaDataInput => 'Input';

  @override
  String get settingsNoteMetaDataEditorType => 'Editor Type Field';

  @override
  String get settingsNoteMetaDataUnixTimestampMagnitude =>
      'Unix Timestamp Magnitude';

  @override
  String get settingsNoteMetaDataUnixTimestampDateMagnitudeSeconds => 'Seconds';

  @override
  String get settingsNoteMetaDataUnixTimestampDateMagnitudeMilliseconds =>
      'Milliseconds';

  @override
  String get settingsNoteMetaDataModifiedFormat => 'Modified Format';

  @override
  String get settingsNoteMetaDataCreatedFormat => 'Created Format';

  @override
  String get settingsNoteMetaDataDateFormatIso8601 => 'ISO 8601';

  @override
  String get settingsNoteMetaDataDateFormatNone => 'None';

  @override
  String get settingsNoteMetaDataDateFormatUnixTimestamp => 'Unix Timestamp';

  @override
  String get settingsNoteMetaDataDateFormatYearMonthDay => 'YYYY-MM-DD';

  @override
  String get settingsPrivacy => 'Privacy Policy';

  @override
  String get settingsTerms => 'Terms and Conditions';

  @override
  String get settingsExperimentalTitle => 'Experimental Features';

  @override
  String get settingsExperimentalSubtitle => 'Try out features in Development';

  @override
  String get settingsExperimentalMarkdownToolbar =>
      'Show Markdown Toolbar in Editor';

  @override
  String get settingsExperimentalGraphView => 'Graph View';

  @override
  String get settingsExperimentalAccounts => 'Platform Independent Accounts';

  @override
  String get settingsExperimentalIncludeSubfolders => 'Include Subfolders';

  @override
  String get settingsExperimentalExperimentalGitOps =>
      'Dart-only Git implementation';

  @override
  String get settingsExperimentalAutoCompleteTags => 'Tags Auto Completion';

  @override
  String get settingsExperimentalHistory => 'History View';

  @override
  String get settingsEditorsTitle => 'Editor Settings';

  @override
  String get settingsEditorsSubtitle => 'Configure how different editors work';

  @override
  String get settingsEditorsDefaultEditor => 'Default Editor';

  @override
  String get settingsEditorsDefaultState => 'Default State';

  @override
  String get settingsEditorsMarkdownEditor => 'Markdown Editor';

  @override
  String get settingsEditorsJournalEditor => 'Journal Editor';

  @override
  String get settingsEditorsDefaultFolder => 'Default Folder';

  @override
  String get settingsEditorsChecklistEditor => 'Checklist Editor';

  @override
  String get settingsEditorsRawEditor => 'Raw Editor';

  @override
  String get settingsEditorsChoose => 'Choose Editor';

  @override
  String get settingsEditorsOrgEditor => 'Org Editor';

  @override
  String get settingsEditorsDefaultNoteFormat => 'Default Note Format';

  @override
  String settingsEditorsJournalDefaultFolderSelect(Object loc) {
    return 'Creating a Note in \'$loc\'';
  }

  @override
  String get settingsSortingFieldModified => 'Last Modified';

  @override
  String get settingsSortingFieldCreated => 'Created';

  @override
  String get settingsSortingFieldFilename => 'File Name';

  @override
  String get settingsSortingFieldTitle => 'Title';

  @override
  String get settingsSortingOrderAsc => 'Ascending';

  @override
  String get settingsSortingOrderDesc => 'Descending';

  @override
  String get settingsSortingModeField => 'Field';

  @override
  String get settingsSortingModeOrder => 'Order';

  @override
  String get settingsRemoteSyncAuto => 'Automatic';

  @override
  String get settingsRemoteSyncManual => 'Manual';

  @override
  String get settingsTagsTitle => 'Tags Settings';

  @override
  String get settingsTagsSubtitle => 'Configure how inline tags are parsed';

  @override
  String get settingsTagsEnable => 'Parse Inline Tags';

  @override
  String get settingsTagsPrefixes => 'Inline Tags Prefixes';

  @override
  String get settingsMiscTitle => 'Misc Settings';

  @override
  String get settingsMiscSwipe => 'Swipe to Delete Note';

  @override
  String get settingsMiscListView => 'List View';

  @override
  String get settingsMiscConfirmDelete => 'Show a Popup to Confirm Deletes';

  @override
  String get settingsMiscHardWrap => 'Enable hardWrap';

  @override
  String get settingsMiscEmoji => 'Emojify text';

  @override
  String get settingsNoteFileNameFormatIso8601WithTimeZone =>
      'ISO8601 With TimeZone';

  @override
  String get settingsNoteFileNameFormatIso8601 => 'ISO8601';

  @override
  String get settingsNoteFileNameFormatIso8601WithoutColon =>
      'ISO8601 without Colons';

  @override
  String get settingsNoteFileNameFormatTitle => 'Title';

  @override
  String get settingsNoteFileNameFormatUuid => 'Uuid V4';

  @override
  String get settingsNoteFileNameFormatZettelkasten => 'yyyymmddhhmmss';

  @override
  String get settingsNoteFileNameFormatSimple => 'yyyy-mm-dd-hh-mm-ss';

  @override
  String get settingsNoteFileNameFormatDateOnly => 'yyyy-mm-dd';

  @override
  String get settingsNoteFileNameFormatKebabCase => 'Kebab Case';

  @override
  String get settingsHomeScreenAllNotes => 'All Notes';

  @override
  String get settingsHomeScreenAllFolders => 'All Folders';

  @override
  String get settingsEditorDefaultViewEdit => 'Edit';

  @override
  String get settingsEditorDefaultViewView => 'View';

  @override
  String get settingsEditorDefaultViewLastUsed => 'Last Used';

  @override
  String get settingsThemeLight => 'Light Theme';

  @override
  String get settingsThemeDark => 'Dark Theme';

  @override
  String get settingsThemeDefault => 'System Default';

  @override
  String get settingsVersionCopied => 'Copied version to clipboard';

  @override
  String get settingsSshSyncFreq => 'Sync Frequency';

  @override
  String get settingsNoteTitle => 'Note Settings';

  @override
  String get settingsNoteDefaultFolder => 'Default Folder for new notes';

  @override
  String get settingsNoteNewNoteFileName => 'New Note Filename';

  @override
  String get settingsStorageTitle => 'Storage';

  @override
  String get settingsStorageFileName => 'filename';

  @override
  String get settingsStorageExternal => 'Store Repo Externally';

  @override
  String get settingsStorageIcloud => 'Store in iCloud';

  @override
  String get settingsStorageRepoLocation => 'Repo Location';

  @override
  String settingsStorageNotWritable(Object loc) {
    return '$loc is not writable';
  }

  @override
  String get settingsStorageFailedExternal =>
      'Unable to get External Storage Directory';

  @override
  String get settingsStoragePermissionFailed =>
      'External Storage Permission Failed';

  @override
  String get settingsDrawerTitle => 'Sidebar Settings';

  @override
  String get settingsBottomMenuBarTitle => 'Bottom Menu Bar';

  @override
  String get settingsBottomMenuBarSubtitle =>
      'Configure its appearance and behavior';

  @override
  String get settingsBottomMenuBarEnable => 'Enable Bottom Menu Bar';

  @override
  String get settingsDeleteRepo => 'Delete Repository';

  @override
  String get settingsFileFormatMarkdown => 'Markdown';

  @override
  String get settingsFileFormatTxt => 'Txt';

  @override
  String get settingsFileFormatOrgMode => 'Org Mode';

  @override
  String get settingsFileTypesTitle => 'Note File Types';

  @override
  String get settingsFileTypesSubtitle =>
      'Configure what files are considered Notes';

  @override
  String settingsFileTypesNumFiles(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Files',
      one: '1 File',
      zero: 'No Files',
    );
    return '$_temp0';
  }

  @override
  String get settingsFileTypesNoExt => 'No Extension';

  @override
  String get settingsListUserInterfaceTitle => 'User Interface';

  @override
  String get settingsListUserInterfaceSubtitle =>
      'Theme, Language, Home, Bottom Bar, Rendering';

  @override
  String get settingsListGitTitle => 'Git';

  @override
  String get settingsListGitSubtitle => 'Git Author, Remote, Sync Frequency';

  @override
  String get settingsListEditorTitle => 'Editor';

  @override
  String get settingsListEditorSubtitle => 'Default Editor, Default View';

  @override
  String get settingsListStorageTitle => 'Storage & File Formats';

  @override
  String get settingsListStorageSubtitle =>
      'Storage, Serialization, Metadata, File Formats';

  @override
  String get settingsListAnalyticsTitle => 'Analytics';

  @override
  String get settingsListAnalyticsSubtitle =>
      'It\'s important that you feel comfortable';

  @override
  String get settingsListDebugTitle => 'Debug';

  @override
  String get settingsListDebugSubtitle =>
      'Peek inside the inner workings of GitJournal';

  @override
  String get settingsListExperimentsTitle => 'Experiments';

  @override
  String get settingsListExperimentsSubtitle =>
      'Play around with experimental features';

  @override
  String get settingsProjectHeader => 'Project';

  @override
  String get settingsProjectDocs => 'Documentation & Support';

  @override
  String get settingsProjectContribute => 'Contribute';

  @override
  String get settingsProjectAbout => 'About';

  @override
  String get settingsLicenseTitle => 'Licenses';

  @override
  String get settingsLicenseSubtitle => 'GitJoural uses other great software';

  @override
  String get settingsSshKeyKeyType => 'SSH Key Type';

  @override
  String get settingsSshKeyRsa => 'RSA';

  @override
  String get settingsSshKeyEd25519 => 'Ed25519';

  @override
  String get editorsChecklistAdd => 'Add Item';

  @override
  String get editorsCommonDefaultBodyHint => 'Write here';

  @override
  String get editorsCommonDefaultTitleHint => 'Title';

  @override
  String get editorsCommonDiscard => 'Discard Changes';

  @override
  String get editorsCommonShare => 'Share Note';

  @override
  String get editorsCommonTakePhoto => 'Take Photo';

  @override
  String get editorsCommonAddImage => 'Add Image from Gallery';

  @override
  String get editorsCommonEditFileName => 'Edit File Name';

  @override
  String get editorsCommonTags => 'Edit Tags';

  @override
  String get editorsCommonZenEnable => 'Enable Zen Mode';

  @override
  String get editorsCommonZenDisable => 'Disable Zen Mode';

  @override
  String get editorsCommonSaveNoteFailedTitle => 'Failed to Save Note';

  @override
  String get editorsCommonSaveNoteFailedMessage =>
      'We\'re sorry, but we cannot seem to save the Note. It has been copied to the clipboard to avoid data loss.';

  @override
  String get editorsCommonDefaultFileNameHint => 'File Name';

  @override
  String get editorsCommonFind => 'Find in note';

  @override
  String get actionsNewNote => 'New Note';

  @override
  String get actionsNewJournal => 'New Journal Entry';

  @override
  String get actionsNewChecklist => 'New Checklist';

  @override
  String get screensFoldersTitle => 'Folders';

  @override
  String get screensFoldersSelected => 'Folder Selected';

  @override
  String get screensFoldersDialogTitle => 'Create new Folder';

  @override
  String get screensFoldersDialogCreate => 'Create';

  @override
  String get screensFoldersDialogDiscard => 'Discard';

  @override
  String get screensFoldersErrorDialogTitle => 'Error';

  @override
  String get screensFoldersErrorDialogDeleteContent =>
      'Cannot delete a Folder which contains notes';

  @override
  String get screensFoldersErrorDialogRenameContent =>
      'Cannot rename Root Folder';

  @override
  String get screensFoldersErrorDialogOk => 'Ok';

  @override
  String get screensFoldersActionsRename => 'Rename Folder';

  @override
  String get screensFoldersActionsSubFolder => 'Create Sub-Folder';

  @override
  String get screensFoldersActionsDelete => 'Delete Folder';

  @override
  String get screensFoldersActionsDecoration => 'Folder Name';

  @override
  String get screensFoldersActionsEmpty => 'Please enter a name';

  @override
  String get screensTagsTitle => 'Tags';

  @override
  String get screensTagsEmpty => 'No Tags Found';

  @override
  String get screensFilesystemIgnoredFileTitle => 'File Ignored';

  @override
  String get screensFilesystemIgnoredFileOk => 'Ok';

  @override
  String get screensFilesystemIgnoredFileRename => 'Rename';

  @override
  String get screensFilesystemRenameDecoration => 'File Name';

  @override
  String get screensFilesystemRenameTitle => 'Rename';

  @override
  String get screensFolderViewEmpty => 'Let\'s add some notes?';

  @override
  String get screensHomeAllNotes => 'All Notes';

  @override
  String get screensCacheLoadingText => 'Reading Git History ...';

  @override
  String get screensErrorTitle => 'Error';

  @override
  String get screensErrorMessage =>
      'The repo couldn\'t be opened. Please file a bug and recreate the repo.';

  @override
  String get widgetsRenameYes => 'Rename';

  @override
  String get widgetsRenameNo => 'Cancel';

  @override
  String get widgetsRenameValidatorEmpty => 'Please enter a name';

  @override
  String get widgetsRenameValidatorExists => 'Already Exists';

  @override
  String get widgetsRenameValidatorContains => 'Cannot contain /';

  @override
  String get widgetsRenameNoExt =>
      'Warning: Extension missing. Will treat file as plain text';

  @override
  String widgetsRenameChangeExt(Object from, Object to) {
    return 'Warning: Changing file type from \'$from\' to \'$to\'';
  }

  @override
  String widgetsBacklinksTitle(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Notes link to this Note',
      one: '1 Note links to this Note',
    );
    return '$_temp0';
  }

  @override
  String get widgetsSortingOrderSelectorTitle => 'Sorting Criteria';

  @override
  String widgetsPurchaseButtonText(Object price) {
    return 'Purchase for $price';
  }

  @override
  String get widgetsPurchaseButtonFail => 'Failed to Load';

  @override
  String get widgetsPurchaseButtonFailSend => 'Failed to send purchase request';

  @override
  String widgetsPurchaseButtonFailPurchase(Object err) {
    return 'Failed to Purchase - $err';
  }

  @override
  String widgetsFolderViewSyncError(Object err) {
    return 'Sync Error $err';
  }

  @override
  String get widgetsFolderViewHeaderOptionsHeading => 'Header Options';

  @override
  String get widgetsFolderViewHeaderOptionsAuto => 'Auto Generated Title';

  @override
  String get widgetsFolderViewHeaderOptionsTitleFileName => 'Title or FileName';

  @override
  String get widgetsFolderViewHeaderOptionsFileName => 'FileName';

  @override
  String get widgetsFolderViewHeaderOptionsSummary => 'Show Summary';

  @override
  String get widgetsFolderViewHeaderOptionsCustomize => 'Customize View';

  @override
  String get widgetsFolderViewViewsStandard => 'Standard View';

  @override
  String get widgetsFolderViewViewsJournal => 'Journal View';

  @override
  String get widgetsFolderViewViewsGrid => 'Grid View';

  @override
  String get widgetsFolderViewViewsCard => 'Card View';

  @override
  String get widgetsFolderViewViewsSelect => 'Select View';

  @override
  String get widgetsFolderViewViewsCalendar => 'Calendar View';

  @override
  String get widgetsFolderViewSortingOptions => 'Sorting Options';

  @override
  String get widgetsFolderViewViewOptions => 'View Options';

  @override
  String get widgetsFolderViewNoteDeleted => 'Note Deleted';

  @override
  String get widgetsFolderViewUndo => 'Undo';

  @override
  String get widgetsFolderViewSearchFailed => 'No Search Results Found';

  @override
  String get widgetsFolderViewActionsMoveToFolder => 'Move To Folder';

  @override
  String get widgetsFolderViewPinned => 'Pinned';

  @override
  String get widgetsFolderViewOthers => 'Others';

  @override
  String widgetsImageRendererCaption(Object first, Object second) {
    return '$first - $second';
  }

  @override
  String widgetsImageRendererHttpError(Object status, Object url) {
    return 'Code: $status for $url';
  }

  @override
  String widgetsNoteDeleteDialogTitle(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Do you want to delete these $count notes?',
      one: 'Do you want to delete this note?',
    );
    return '$_temp0';
  }

  @override
  String get widgetsNotesFolderDeleteDialogTitle =>
      'Do you want to delete this folder and everything inside it?';

  @override
  String get widgetsNoteDeleteDialogYes => 'true';

  @override
  String get widgetsNoteDeleteDialogNo => 'false';

  @override
  String get widgetsNoteEditorRenameFile => 'Rename File';

  @override
  String get widgetsNoteEditorFileName => 'Filename';

  @override
  String widgetsNoteEditorAddType(Object ext) {
    return 'Adding \'$ext\' to supported file types';
  }

  @override
  String widgetsSyncButtonError(Object err) {
    return 'Sync Error $err';
  }

  @override
  String get widgetsPurchaseWidgetFailed => 'Purchase Failed';

  @override
  String widgetsNoteViewerLinkNotFound(Object name) {
    return 'Link \'$name\' not found';
  }

  @override
  String widgetsNoteViewerLinkInvalid(Object name) {
    return 'Link \'$name\' is invalid.';
  }

  @override
  String get widgetsFolderSelectionDialogTitle => 'Select a Folder';

  @override
  String widgetsFolderTreeViewNotesCount(Object num) {
    return '$num Notes';
  }

  @override
  String get ignoredFilesDot => 'Starts with a .';

  @override
  String get ignoredFilesExt => 'Doesn\'t end with one of the following -';

  @override
  String get drawerSetup => 'Setup Git Host';

  @override
  String get drawerPro => 'Unlock Pro Version';

  @override
  String get drawerAll => 'All Notes';

  @override
  String get drawerFolders => 'Folders';

  @override
  String get drawerFs => 'File System';

  @override
  String get drawerTags => 'Tags';

  @override
  String get drawerShare => 'Share App';

  @override
  String get drawerRate => 'Rate Us';

  @override
  String get drawerFeedback => 'Feedback';

  @override
  String get drawerBug => 'Bug Report';

  @override
  String get drawerGraph => 'Graph View';

  @override
  String get drawerRemote => 'No Git Host';

  @override
  String get drawerAddRepo => 'Add Repository';

  @override
  String get drawerLogin => 'Login';

  @override
  String get drawerHistory => 'History';

  @override
  String get setupAutoConfigureTitle => 'How do you want to do this?';

  @override
  String get setupAutoConfigureAutomatic => 'Setup Automatically';

  @override
  String get setupAutoConfigureManual => 'Let me do it manually';

  @override
  String get setupAutoconfigureStep1 =>
      '1. List your existing repos or create a new repo';

  @override
  String get setupAutoconfigureStep2 => '2. Generate an SSH Key on this device';

  @override
  String get setupAutoconfigureStep3 =>
      '3. Add the key as a deploy key with write access to the repository';

  @override
  String get setupAutoconfigureWarning =>
      'This will require granting GitJournal access to all private and public repos. If you\'re not comfortable with that please go back and chose the manual setup option.';

  @override
  String get setupAutoconfigureAuthorize => 'Authorize GitJournal';

  @override
  String get setupAutoconfigureWaitPerm => 'Waiting for Permissions ...';

  @override
  String get setupAutoconfigureReadUser => 'Reading User Info';

  @override
  String get setupRepoSelectorTitle => 'Select or Create a Repository';

  @override
  String get setupRepoSelectorHint => 'Type to Search or Create a Repo';

  @override
  String setupRepoSelectorCreate(Object name) {
    return 'Create Private Repo $name';
  }

  @override
  String get setupRepoSelectorLoading => 'Loading';

  @override
  String get setupCloneUrlEnter => 'Enter the Git Clone URL';

  @override
  String get setupCloneUrlValidatorEmpty => 'Please enter some text';

  @override
  String get setupCloneUrlValidatorInvalid => 'Invalid Input';

  @override
  String get setupCloneUrlValidatorOnlySsh =>
      'Only SSH urls are currently accepted';

  @override
  String get setupCloneUrlManualTitle => 'Please create a new git repository -';

  @override
  String get setupCloneUrlManualStep1 =>
      '1. Go to the website, create a repo and copy its git clone URL';

  @override
  String get setupCloneUrlManualStep2 => '2. Enter the Git clone URL';

  @override
  String get setupCloneUrlManualButton => 'Open Create New Repo Webpage';

  @override
  String get setupNext => 'Next';

  @override
  String get setupFail => 'Failed';

  @override
  String get setupKeyEditorsPublic =>
      'Invalid Public Key - Doesn\'t start with ssh-rsa or ssh-ed25519';

  @override
  String get setupKeyEditorsPrivate => 'Invalid Private Key';

  @override
  String get setupKeyEditorsLoad => 'Load from File';

  @override
  String get setupSshKeyGenerate => 'Generating SSH Key';

  @override
  String get setupSshKeyTitle =>
      'In order to access this repository, this public key must be copied as a deploy key';

  @override
  String get setupSshKeyStep1 => '1. Copy the key';

  @override
  String get setupSshKeyStep2a =>
      '2. Open webpage, and paste the deploy key. Make sure it is given Write Access.';

  @override
  String get setupSshKeyStep2b =>
      '2. Give this SSH Key access to the git repo. (You need to figure it out yourself)';

  @override
  String get setupSshKeyStep3 => '3. Try Cloning ..';

  @override
  String get setupSshKeyCopy => 'Copy Key';

  @override
  String get setupSshKeyCopied => 'Public Key copied to Clipboard';

  @override
  String get setupSshKeyRegenerate => 'Regenerate Key';

  @override
  String get setupSshKeyOpenDeploy => 'Open Deploy Key Webpage';

  @override
  String get setupSshKeyClone => 'Clone Repo';

  @override
  String get setupSshKeyAddDeploy => 'Adding as a Deploy Key';

  @override
  String get setupSshKeySave => 'Save';

  @override
  String get setupSshKeyChoiceTitle => 'We need SSH keys to authenticate -';

  @override
  String get setupSshKeyChoiceGenerate => 'Generate new keys';

  @override
  String get setupSshKeyChoiceCustom => 'Provide Custom SSH Keys';

  @override
  String get setupSshKeyUserProvidedPublic => 'Public Key -';

  @override
  String get setupSshKeyUserProvidedPrivate => 'Private Key -';

  @override
  String get setupSshKeyUserProvidedPassword => 'Private Key Password';

  @override
  String get setupCloning => 'Cloning ...';

  @override
  String get setupHostTitle => 'Select a Git Hosting Provider -';

  @override
  String get setupHostCustom => 'Custom';

  @override
  String get purchaseScreenTitle => 'Pro Version';

  @override
  String get purchaseScreenDesc =>
      'GitJournal is completely open source and is the result of significant development work. It has no venture capital or corporation backing and it never will. Your support directly sustains development.   GitJournal operates on a \"pay what you want model (with a minimum)\".';

  @override
  String get purchaseScreenRestore => 'Restore Purchase';

  @override
  String get purchaseScreenOneTimeTitle => 'One Time Purchase';

  @override
  String get purchaseScreenOneTimeDesc =>
      'Permanently enables all Pro features currently in GitJournal and new features added in the following 12 months.';

  @override
  String get purchaseScreenMonthlyTitle => 'Monthly Installments';

  @override
  String purchaseScreenMonthlyDesc(Object minYearlyPurchase) {
    return 'Enables all Pro Features. After 12 months or after paying $minYearlyPurchase, you will get all the benefits of the \'One Time Purchase\'';
  }

  @override
  String get purchaseScreenThanksTitle => 'Thank You';

  @override
  String get purchaseScreenThanksSubtitle =>
      'You\'re awesome for supporting GitJournal';

  @override
  String get purchaseScreenUnknown => 'Unknown';

  @override
  String get onBoardingSkip => 'Skip';

  @override
  String get onBoardingNext => 'Next';

  @override
  String get onBoardingGetStarted => 'Get Started';

  @override
  String get onBoardingSubtitle =>
      'An Open Source Note Taking App built on top of Git';

  @override
  String get onBoardingPage2 =>
      'Your Notes are stored in a standard Markdown + YAML Header format';

  @override
  String get onBoardingPage3 => 'Sync your Local Git Repo with any provider';

  @override
  String get singleJournalEntry => 'Single Journal Entry File per day';

  @override
  String get exportRepo => 'Export Repository';

  @override
  String get shareAsZip => 'Share as a ZIP file';

  @override
  String get failedToExport => 'Failed to Export';
}
