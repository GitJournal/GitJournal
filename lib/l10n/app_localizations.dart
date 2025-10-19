import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fa'),
    Locale('fi'),
    Locale('fr'),
    Locale('hi'),
    Locale('hu'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ru'),
    Locale('sv'),
    Locale('ta'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale('zh', 'TW')
  ];

  /// No description provided for @pro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get pro;

  /// No description provided for @rootFolder.
  ///
  /// In en, this message translates to:
  /// **'Root Folder'**
  String get rootFolder;

  /// No description provided for @beta.
  ///
  /// In en, this message translates to:
  /// **'BETA'**
  String get beta;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @settingsOk.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get settingsOk;

  /// No description provided for @settingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAuthorLabel.
  ///
  /// In en, this message translates to:
  /// **'Author Name'**
  String get settingsAuthorLabel;

  /// No description provided for @settingsAuthorValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get settingsAuthorValidator;

  /// No description provided for @settingsEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get settingsEmailLabel;

  /// No description provided for @settingsEmailValidatorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get settingsEmailValidatorEmpty;

  /// No description provided for @settingsEmailValidatorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get settingsEmailValidatorInvalid;

  /// No description provided for @settingsDisplayTitle.
  ///
  /// In en, this message translates to:
  /// **'Display Settings'**
  String get settingsDisplayTitle;

  /// No description provided for @settingsDisplayHomeScreen.
  ///
  /// In en, this message translates to:
  /// **'Home Screen'**
  String get settingsDisplayHomeScreen;

  /// No description provided for @settingsDisplayTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsDisplayTheme;

  /// No description provided for @settingsDisplayImagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Image Settings'**
  String get settingsDisplayImagesTitle;

  /// No description provided for @settingsDisplayImagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure how images are displayed'**
  String get settingsDisplayImagesSubtitle;

  /// No description provided for @settingsDisplayImagesImageTextTypeAlt.
  ///
  /// In en, this message translates to:
  /// **'Alt Text'**
  String get settingsDisplayImagesImageTextTypeAlt;

  /// No description provided for @settingsDisplayImagesImageTextTypeAltAndTooltip.
  ///
  /// In en, this message translates to:
  /// **'Alt Text and Tooltip'**
  String get settingsDisplayImagesImageTextTypeAltAndTooltip;

  /// No description provided for @settingsDisplayImagesImageTextTypeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Tooltip'**
  String get settingsDisplayImagesImageTextTypeTooltip;

  /// No description provided for @settingsDisplayImagesImageTextTypeNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get settingsDisplayImagesImageTextTypeNone;

  /// No description provided for @settingsDisplayImagesCaptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Image Captions'**
  String get settingsDisplayImagesCaptionsTitle;

  /// No description provided for @settingsDisplayImagesCaptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure the image captions'**
  String get settingsDisplayImagesCaptionsSubtitle;

  /// No description provided for @settingsDisplayImagesCaptionsUseAsCaption.
  ///
  /// In en, this message translates to:
  /// **'Use as caption'**
  String get settingsDisplayImagesCaptionsUseAsCaption;

  /// No description provided for @settingsDisplayImagesCaptionsOverlayCaption.
  ///
  /// In en, this message translates to:
  /// **'Draw caption on top of large enough images'**
  String get settingsDisplayImagesCaptionsOverlayCaption;

  /// No description provided for @settingsDisplayImagesCaptionsTransparentCaption.
  ///
  /// In en, this message translates to:
  /// **'Overlay captions have a semitransparent background'**
  String get settingsDisplayImagesCaptionsTransparentCaption;

  /// No description provided for @settingsDisplayImagesCaptionsBlurBehindCaption.
  ///
  /// In en, this message translates to:
  /// **'Blur Image behind caption'**
  String get settingsDisplayImagesCaptionsBlurBehindCaption;

  /// No description provided for @settingsDisplayImagesCaptionsTooltipFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'Show tooltip before alt text'**
  String get settingsDisplayImagesCaptionsTooltipFirstTitle;

  /// No description provided for @settingsDisplayImagesCaptionsTooltipFirstTooltip.
  ///
  /// In en, this message translates to:
  /// **'Current order is “<tooltip> - <altText>”'**
  String get settingsDisplayImagesCaptionsTooltipFirstTooltip;

  /// No description provided for @settingsDisplayImagesCaptionsTooltipFirstAltText.
  ///
  /// In en, this message translates to:
  /// **'Current order is “<altText> - <tooltip>”'**
  String get settingsDisplayImagesCaptionsTooltipFirstAltText;

  /// No description provided for @settingsDisplayImagesCaptionsCaptionOverrides.
  ///
  /// In en, this message translates to:
  /// **'Caption Overrides'**
  String get settingsDisplayImagesCaptionsCaptionOverrides;

  /// No description provided for @settingsDisplayImagesCaptionsTagDescription.
  ///
  /// In en, this message translates to:
  /// **'Put these tags in “![altText](... \"tooltip\")” to override the behavior for it.'**
  String get settingsDisplayImagesCaptionsTagDescription;

  /// No description provided for @settingsDisplayImagesCaptionsDoNotCaptionTagsHint.
  ///
  /// In en, this message translates to:
  /// **'DoNotCaption-Tags'**
  String get settingsDisplayImagesCaptionsDoNotCaptionTagsHint;

  /// No description provided for @settingsDisplayImagesCaptionsDoNotCaptionTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Never use as caption with tags'**
  String get settingsDisplayImagesCaptionsDoNotCaptionTagsLabel;

  /// No description provided for @settingsDisplayImagesCaptionsDoNotCaptionTagsValidatorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tags cannot be empty.'**
  String get settingsDisplayImagesCaptionsDoNotCaptionTagsValidatorEmpty;

  /// No description provided for @settingsDisplayImagesCaptionsDoNotCaptionTagsValidatorSame.
  ///
  /// In en, this message translates to:
  /// **'Tag cannot be identical to a “DoCaption-Tag”.'**
  String get settingsDisplayImagesCaptionsDoNotCaptionTagsValidatorSame;

  /// No description provided for @settingsDisplayImagesCaptionsDoCaptionTagsHint.
  ///
  /// In en, this message translates to:
  /// **'DoCaption-Tags'**
  String get settingsDisplayImagesCaptionsDoCaptionTagsHint;

  /// No description provided for @settingsDisplayImagesCaptionsDoCaptionTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Always use as caption with tags'**
  String get settingsDisplayImagesCaptionsDoCaptionTagsLabel;

  /// No description provided for @settingsDisplayImagesCaptionsDoCaptionTagsValidatorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tags cannot be empty.'**
  String get settingsDisplayImagesCaptionsDoCaptionTagsValidatorEmpty;

  /// No description provided for @settingsDisplayImagesCaptionsDoCaptionTagsValidatorSame.
  ///
  /// In en, this message translates to:
  /// **'Tag cannot be identical to a “DoNotCaption-Tag”.'**
  String get settingsDisplayImagesCaptionsDoCaptionTagsValidatorSame;

  /// No description provided for @settingsDisplayImagesDetailsViewHeader.
  ///
  /// In en, this message translates to:
  /// **'Detail View'**
  String get settingsDisplayImagesDetailsViewHeader;

  /// No description provided for @settingsDisplayImagesDetailsViewMaxZoom.
  ///
  /// In en, this message translates to:
  /// **'Maximal zoom level'**
  String get settingsDisplayImagesDetailsViewMaxZoom;

  /// No description provided for @settingsDisplayImagesDetailsViewRotateGesturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Rotate Image with gestures'**
  String get settingsDisplayImagesDetailsViewRotateGesturesTitle;

  /// No description provided for @settingsDisplayImagesDetailsViewRotateGesturesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rotate by moving two fingers in a circle'**
  String get settingsDisplayImagesDetailsViewRotateGesturesSubtitle;

  /// No description provided for @settingsDisplayImagesThemingTitle.
  ///
  /// In en, this message translates to:
  /// **'Image Theming'**
  String get settingsDisplayImagesThemingTitle;

  /// No description provided for @settingsDisplayImagesThemingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure how images are themed'**
  String get settingsDisplayImagesThemingSubtitle;

  /// No description provided for @settingsDisplayImagesThemingAdjustColorsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get settingsDisplayImagesThemingAdjustColorsAll;

  /// No description provided for @settingsDisplayImagesThemingAdjustColorsBlackAndWhite.
  ///
  /// In en, this message translates to:
  /// **'Only black and white'**
  String get settingsDisplayImagesThemingAdjustColorsBlackAndWhite;

  /// No description provided for @settingsDisplayImagesThemingAdjustColorsGrays.
  ///
  /// In en, this message translates to:
  /// **'Only grays'**
  String get settingsDisplayImagesThemingAdjustColorsGrays;

  /// No description provided for @settingsDisplayImagesThemingDoNotThemeTagsHint.
  ///
  /// In en, this message translates to:
  /// **'DoNotTheme-Tags'**
  String get settingsDisplayImagesThemingDoNotThemeTagsHint;

  /// No description provided for @settingsDisplayImagesThemingDoNotThemeTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Never theme images with tags'**
  String get settingsDisplayImagesThemingDoNotThemeTagsLabel;

  /// No description provided for @settingsDisplayImagesThemingDoNotThemeTagsValidatorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tags cannot be empty.'**
  String get settingsDisplayImagesThemingDoNotThemeTagsValidatorEmpty;

  /// No description provided for @settingsDisplayImagesThemingDoNotThemeTagsValidatorSame.
  ///
  /// In en, this message translates to:
  /// **'Tag cannot be identical to a “DoTheme-Tag”.'**
  String get settingsDisplayImagesThemingDoNotThemeTagsValidatorSame;

  /// No description provided for @settingsDisplayImagesThemingDoThemeTagsHint.
  ///
  /// In en, this message translates to:
  /// **'DoTheme-Tag'**
  String get settingsDisplayImagesThemingDoThemeTagsHint;

  /// No description provided for @settingsDisplayImagesThemingDoThemeTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Always theme images with tags'**
  String get settingsDisplayImagesThemingDoThemeTagsLabel;

  /// No description provided for @settingsDisplayImagesThemingDoThemeTagsValidatorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tags cannot be empty.'**
  String get settingsDisplayImagesThemingDoThemeTagsValidatorEmpty;

  /// No description provided for @settingsDisplayImagesThemingDoThemeTagsValidatorSame.
  ///
  /// In en, this message translates to:
  /// **'Tag cannot be identical to a “DoNotTheme-Tag”.'**
  String get settingsDisplayImagesThemingDoThemeTagsValidatorSame;

  /// No description provided for @settingsDisplayImagesThemingMatchCanvasColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Match Background Color'**
  String get settingsDisplayImagesThemingMatchCanvasColorTitle;

  /// No description provided for @settingsDisplayImagesThemingMatchCanvasColorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replaces white/black parts of vector graphics with the canvas color'**
  String get settingsDisplayImagesThemingMatchCanvasColorSubtitle;

  /// No description provided for @settingsDisplayImagesThemingTagDescription.
  ///
  /// In en, this message translates to:
  /// **'Put these tags in “![altText](... \"tooltip\")” to override the behavior for the image.'**
  String get settingsDisplayImagesThemingTagDescription;

  /// No description provided for @settingsDisplayImagesThemingThemeOverrides.
  ///
  /// In en, this message translates to:
  /// **'Theme Overrides'**
  String get settingsDisplayImagesThemingThemeOverrides;

  /// No description provided for @settingsDisplayImagesThemingThemeOverrideTagLocation.
  ///
  /// In en, this message translates to:
  /// **'Theme Override Tag Location'**
  String get settingsDisplayImagesThemingThemeOverrideTagLocation;

  /// No description provided for @settingsDisplayImagesThemingThemeRasterGraphics.
  ///
  /// In en, this message translates to:
  /// **'Theme Raster Graphics (.png/.jpg)'**
  String get settingsDisplayImagesThemingThemeRasterGraphics;

  /// No description provided for @settingsDisplayImagesThemingThemeSvgWithBackground.
  ///
  /// In en, this message translates to:
  /// **'Theme SVGs With Background'**
  String get settingsDisplayImagesThemingThemeSvgWithBackground;

  /// No description provided for @settingsDisplayImagesThemingThemeVectorGraphicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Vector Graphics'**
  String get settingsDisplayImagesThemingThemeVectorGraphicsTitle;

  /// No description provided for @settingsDisplayImagesThemingThemeVectorGraphicsFilter.
  ///
  /// In en, this message translates to:
  /// **'Using Color Filter'**
  String get settingsDisplayImagesThemingThemeVectorGraphicsFilter;

  /// No description provided for @settingsDisplayImagesThemingThemeVectorGraphicsOff.
  ///
  /// In en, this message translates to:
  /// **'false'**
  String get settingsDisplayImagesThemingThemeVectorGraphicsOff;

  /// No description provided for @settingsDisplayImagesThemingThemeVectorGraphicsOn.
  ///
  /// In en, this message translates to:
  /// **'true'**
  String get settingsDisplayImagesThemingThemeVectorGraphicsOn;

  /// No description provided for @settingsDisplayImagesThemingVectorGraphics.
  ///
  /// In en, this message translates to:
  /// **'Vector Graphics (.svg)'**
  String get settingsDisplayImagesThemingVectorGraphics;

  /// No description provided for @settingsDisplayImagesThemingVectorGraphicsAdjustColors.
  ///
  /// In en, this message translates to:
  /// **'Colors to Adjust'**
  String get settingsDisplayImagesThemingVectorGraphicsAdjustColors;

  /// No description provided for @settingsDisplayLang.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsDisplayLang;

  /// No description provided for @settingsGitAuthor.
  ///
  /// In en, this message translates to:
  /// **'Git Author Settings'**
  String get settingsGitAuthor;

  /// No description provided for @settingsVersionInfo.
  ///
  /// In en, this message translates to:
  /// **'GitJournal Version'**
  String get settingsVersionInfo;

  /// No description provided for @settingsAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get settingsAnalytics;

  /// No description provided for @settingsCrashReports.
  ///
  /// In en, this message translates to:
  /// **'Collect Anonymous Crash Reports'**
  String get settingsCrashReports;

  /// No description provided for @settingsUsageStats.
  ///
  /// In en, this message translates to:
  /// **'Collect Anonymous Usage Statistics'**
  String get settingsUsageStats;

  /// No description provided for @settingsDebugTitle.
  ///
  /// In en, this message translates to:
  /// **'Debug App'**
  String get settingsDebugTitle;

  /// No description provided for @settingsDebugSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Look under the hood'**
  String get settingsDebugSubtitle;

  /// No description provided for @settingsDebugLevelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Level'**
  String get settingsDebugLevelsTitle;

  /// No description provided for @settingsDebugLevelsError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get settingsDebugLevelsError;

  /// No description provided for @settingsDebugLevelsWarning.
  ///
  /// In en, this message translates to:
  /// **'warning'**
  String get settingsDebugLevelsWarning;

  /// No description provided for @settingsDebugLevelsInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get settingsDebugLevelsInfo;

  /// No description provided for @settingsDebugLevelsDebug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get settingsDebugLevelsDebug;

  /// No description provided for @settingsDebugLevelsVerbose.
  ///
  /// In en, this message translates to:
  /// **'Verbose'**
  String get settingsDebugLevelsVerbose;

  /// No description provided for @settingsDebugCopy.
  ///
  /// In en, this message translates to:
  /// **'Debug Logs Copied'**
  String get settingsDebugCopy;

  /// No description provided for @settingsImagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Image Settings'**
  String get settingsImagesTitle;

  /// No description provided for @settingsImagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure how Images are stored'**
  String get settingsImagesSubtitle;

  /// No description provided for @settingsImagesImageLocation.
  ///
  /// In en, this message translates to:
  /// **'Image Location'**
  String get settingsImagesImageLocation;

  /// No description provided for @settingsImagesCurrentFolder.
  ///
  /// In en, this message translates to:
  /// **'Same Folder as Note'**
  String get settingsImagesCurrentFolder;

  /// No description provided for @settingsImagesCustomFolder.
  ///
  /// In en, this message translates to:
  /// **'Custom Folder'**
  String get settingsImagesCustomFolder;

  /// No description provided for @settingsGitRemoteChangeHostTitle.
  ///
  /// In en, this message translates to:
  /// **'Reconfigure Git Host'**
  String get settingsGitRemoteChangeHostTitle;

  /// No description provided for @settingsGitRemoteChangeHostSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notes which have not been synced will be lost'**
  String get settingsGitRemoteChangeHostSubtitle;

  /// No description provided for @settingsGitRemoteChangeHostOk.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get settingsGitRemoteChangeHostOk;

  /// No description provided for @settingsGitRemoteChangeHostCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsGitRemoteChangeHostCancel;

  /// No description provided for @settingsGitRemoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Git Remote Settings'**
  String get settingsGitRemoteTitle;

  /// No description provided for @settingsGitRemoteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure where your notes are synced'**
  String get settingsGitRemoteSubtitle;

  /// No description provided for @settingsGitRemoteHost.
  ///
  /// In en, this message translates to:
  /// **'Git Host'**
  String get settingsGitRemoteHost;

  /// No description provided for @settingsGitRemoteBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get settingsGitRemoteBranch;

  /// No description provided for @settingsGitRemoteResetHardTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Git Host'**
  String get settingsGitRemoteResetHardTitle;

  /// No description provided for @settingsGitRemoteResetHardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This will HARD reset the current branch to its remote'**
  String get settingsGitRemoteResetHardSubtitle;

  /// No description provided for @settingsNoteMetaDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Note Metadata Settings'**
  String get settingsNoteMetaDataTitle;

  /// No description provided for @settingsNoteMetaDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure how the Note Metadata is saved'**
  String get settingsNoteMetaDataSubtitle;

  /// No description provided for @settingsNoteMetaDataText.
  ///
  /// In en, this message translates to:
  /// **'Every note has some metadata which is stored in a YAML Header as follows -'**
  String get settingsNoteMetaDataText;

  /// No description provided for @settingsNoteMetaDataEnableHeader.
  ///
  /// In en, this message translates to:
  /// **'Enable YAML Header'**
  String get settingsNoteMetaDataEnableHeader;

  /// No description provided for @settingsNoteMetaDataModified.
  ///
  /// In en, this message translates to:
  /// **'Modified Field'**
  String get settingsNoteMetaDataModified;

  /// No description provided for @settingsNoteMetaDataCreated.
  ///
  /// In en, this message translates to:
  /// **'Created Field'**
  String get settingsNoteMetaDataCreated;

  /// No description provided for @settingsNoteMetaDataTags.
  ///
  /// In en, this message translates to:
  /// **'Tags Field'**
  String get settingsNoteMetaDataTags;

  /// No description provided for @settingsNoteMetaDataExampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Pigeons'**
  String get settingsNoteMetaDataExampleTitle;

  /// No description provided for @settingsNoteMetaDataTitleMetaDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get settingsNoteMetaDataTitleMetaDataTitle;

  /// No description provided for @settingsNoteMetaDataTitleMetaDataFromH1.
  ///
  /// In en, this message translates to:
  /// **'Text Header 1'**
  String get settingsNoteMetaDataTitleMetaDataFromH1;

  /// No description provided for @settingsNoteMetaDataTitleMetaDataFromYaml.
  ///
  /// In en, this message translates to:
  /// **'From YAML \'title\''**
  String get settingsNoteMetaDataTitleMetaDataFromYaml;

  /// No description provided for @settingsNoteMetaDataTitleMetaDataFilename.
  ///
  /// In en, this message translates to:
  /// **'FileName'**
  String get settingsNoteMetaDataTitleMetaDataFilename;

  /// No description provided for @settingsNoteMetaDataExampleBody.
  ///
  /// In en, this message translates to:
  /// **'I think they might be evil. Even more evil than penguins.'**
  String get settingsNoteMetaDataExampleBody;

  /// No description provided for @settingsNoteMetaDataExampleTag1.
  ///
  /// In en, this message translates to:
  /// **'Birds'**
  String get settingsNoteMetaDataExampleTag1;

  /// No description provided for @settingsNoteMetaDataExampleTag2.
  ///
  /// In en, this message translates to:
  /// **'Evil'**
  String get settingsNoteMetaDataExampleTag2;

  /// No description provided for @settingsNoteMetaDataCustomMetaDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom MetaData'**
  String get settingsNoteMetaDataCustomMetaDataTitle;

  /// No description provided for @settingsNoteMetaDataCustomMetaDataInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid YAML'**
  String get settingsNoteMetaDataCustomMetaDataInvalid;

  /// No description provided for @settingsNoteMetaDataOutput.
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get settingsNoteMetaDataOutput;

  /// No description provided for @settingsNoteMetaDataInput.
  ///
  /// In en, this message translates to:
  /// **'Input'**
  String get settingsNoteMetaDataInput;

  /// No description provided for @settingsNoteMetaDataEditorType.
  ///
  /// In en, this message translates to:
  /// **'Editor Type Field'**
  String get settingsNoteMetaDataEditorType;

  /// No description provided for @settingsNoteMetaDataUnixTimestampMagnitude.
  ///
  /// In en, this message translates to:
  /// **'Unix Timestamp Magnitude'**
  String get settingsNoteMetaDataUnixTimestampMagnitude;

  /// No description provided for @settingsNoteMetaDataUnixTimestampDateMagnitudeSeconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get settingsNoteMetaDataUnixTimestampDateMagnitudeSeconds;

  /// No description provided for @settingsNoteMetaDataUnixTimestampDateMagnitudeMilliseconds.
  ///
  /// In en, this message translates to:
  /// **'Milliseconds'**
  String get settingsNoteMetaDataUnixTimestampDateMagnitudeMilliseconds;

  /// No description provided for @settingsNoteMetaDataModifiedFormat.
  ///
  /// In en, this message translates to:
  /// **'Modified Format'**
  String get settingsNoteMetaDataModifiedFormat;

  /// No description provided for @settingsNoteMetaDataCreatedFormat.
  ///
  /// In en, this message translates to:
  /// **'Created Format'**
  String get settingsNoteMetaDataCreatedFormat;

  /// No description provided for @settingsNoteMetaDataDateFormatIso8601.
  ///
  /// In en, this message translates to:
  /// **'ISO 8601'**
  String get settingsNoteMetaDataDateFormatIso8601;

  /// No description provided for @settingsNoteMetaDataDateFormatNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get settingsNoteMetaDataDateFormatNone;

  /// No description provided for @settingsNoteMetaDataDateFormatUnixTimestamp.
  ///
  /// In en, this message translates to:
  /// **'Unix Timestamp'**
  String get settingsNoteMetaDataDateFormatUnixTimestamp;

  /// No description provided for @settingsNoteMetaDataDateFormatYearMonthDay.
  ///
  /// In en, this message translates to:
  /// **'YYYY-MM-DD'**
  String get settingsNoteMetaDataDateFormatYearMonthDay;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get settingsTerms;

  /// No description provided for @settingsExperimentalTitle.
  ///
  /// In en, this message translates to:
  /// **'Experimental Features'**
  String get settingsExperimentalTitle;

  /// No description provided for @settingsExperimentalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try out features in Development'**
  String get settingsExperimentalSubtitle;

  /// No description provided for @settingsExperimentalMarkdownToolbar.
  ///
  /// In en, this message translates to:
  /// **'Show Markdown Toolbar in Editor'**
  String get settingsExperimentalMarkdownToolbar;

  /// No description provided for @settingsExperimentalGraphView.
  ///
  /// In en, this message translates to:
  /// **'Graph View'**
  String get settingsExperimentalGraphView;

  /// No description provided for @settingsExperimentalAccounts.
  ///
  /// In en, this message translates to:
  /// **'Platform Independent Accounts'**
  String get settingsExperimentalAccounts;

  /// No description provided for @settingsExperimentalIncludeSubfolders.
  ///
  /// In en, this message translates to:
  /// **'Include Subfolders'**
  String get settingsExperimentalIncludeSubfolders;

  /// No description provided for @settingsExperimentalExperimentalGitOps.
  ///
  /// In en, this message translates to:
  /// **'Dart-only Git implementation'**
  String get settingsExperimentalExperimentalGitOps;

  /// No description provided for @settingsExperimentalAutoCompleteTags.
  ///
  /// In en, this message translates to:
  /// **'Tags Auto Completion'**
  String get settingsExperimentalAutoCompleteTags;

  /// No description provided for @settingsExperimentalHistory.
  ///
  /// In en, this message translates to:
  /// **'History View'**
  String get settingsExperimentalHistory;

  /// No description provided for @settingsEditorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Editor Settings'**
  String get settingsEditorsTitle;

  /// No description provided for @settingsEditorsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure how different editors work'**
  String get settingsEditorsSubtitle;

  /// No description provided for @settingsEditorsDefaultEditor.
  ///
  /// In en, this message translates to:
  /// **'Default Editor'**
  String get settingsEditorsDefaultEditor;

  /// No description provided for @settingsEditorsDefaultState.
  ///
  /// In en, this message translates to:
  /// **'Default State'**
  String get settingsEditorsDefaultState;

  /// No description provided for @settingsEditorsMarkdownEditor.
  ///
  /// In en, this message translates to:
  /// **'Markdown Editor'**
  String get settingsEditorsMarkdownEditor;

  /// No description provided for @settingsEditorsJournalEditor.
  ///
  /// In en, this message translates to:
  /// **'Journal Editor'**
  String get settingsEditorsJournalEditor;

  /// No description provided for @settingsEditorsDefaultFolder.
  ///
  /// In en, this message translates to:
  /// **'Default Folder'**
  String get settingsEditorsDefaultFolder;

  /// No description provided for @settingsEditorsChecklistEditor.
  ///
  /// In en, this message translates to:
  /// **'Checklist Editor'**
  String get settingsEditorsChecklistEditor;

  /// No description provided for @settingsEditorsRawEditor.
  ///
  /// In en, this message translates to:
  /// **'Raw Editor'**
  String get settingsEditorsRawEditor;

  /// No description provided for @settingsEditorsChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose Editor'**
  String get settingsEditorsChoose;

  /// No description provided for @settingsEditorsOrgEditor.
  ///
  /// In en, this message translates to:
  /// **'Org Editor'**
  String get settingsEditorsOrgEditor;

  /// No description provided for @settingsEditorsDefaultNoteFormat.
  ///
  /// In en, this message translates to:
  /// **'Default Note Format'**
  String get settingsEditorsDefaultNoteFormat;

  /// No description provided for @settingsEditorsJournalDefaultFolderSelect.
  ///
  /// In en, this message translates to:
  /// **'Creating a Note in \'{loc}\''**
  String settingsEditorsJournalDefaultFolderSelect(Object loc);

  /// No description provided for @settingsSortingFieldModified.
  ///
  /// In en, this message translates to:
  /// **'Last Modified'**
  String get settingsSortingFieldModified;

  /// No description provided for @settingsSortingFieldCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get settingsSortingFieldCreated;

  /// No description provided for @settingsSortingFieldFilename.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get settingsSortingFieldFilename;

  /// No description provided for @settingsSortingFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get settingsSortingFieldTitle;

  /// No description provided for @settingsSortingOrderAsc.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get settingsSortingOrderAsc;

  /// No description provided for @settingsSortingOrderDesc.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get settingsSortingOrderDesc;

  /// No description provided for @settingsSortingModeField.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get settingsSortingModeField;

  /// No description provided for @settingsSortingModeOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get settingsSortingModeOrder;

  /// No description provided for @settingsRemoteSyncAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get settingsRemoteSyncAuto;

  /// No description provided for @settingsRemoteSyncManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get settingsRemoteSyncManual;

  /// No description provided for @settingsTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags Settings'**
  String get settingsTagsTitle;

  /// No description provided for @settingsTagsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure how inline tags are parsed'**
  String get settingsTagsSubtitle;

  /// No description provided for @settingsTagsEnable.
  ///
  /// In en, this message translates to:
  /// **'Parse Inline Tags'**
  String get settingsTagsEnable;

  /// No description provided for @settingsTagsPrefixes.
  ///
  /// In en, this message translates to:
  /// **'Inline Tags Prefixes'**
  String get settingsTagsPrefixes;

  /// No description provided for @settingsMiscTitle.
  ///
  /// In en, this message translates to:
  /// **'Misc Settings'**
  String get settingsMiscTitle;

  /// No description provided for @settingsMiscSwipe.
  ///
  /// In en, this message translates to:
  /// **'Swipe to Delete Note'**
  String get settingsMiscSwipe;

  /// No description provided for @settingsMiscListView.
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get settingsMiscListView;

  /// No description provided for @settingsMiscConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Show a Popup to Confirm Deletes'**
  String get settingsMiscConfirmDelete;

  /// No description provided for @settingsMiscHardWrap.
  ///
  /// In en, this message translates to:
  /// **'Enable hardWrap'**
  String get settingsMiscHardWrap;

  /// No description provided for @settingsMiscEmoji.
  ///
  /// In en, this message translates to:
  /// **'Emojify text'**
  String get settingsMiscEmoji;

  /// No description provided for @settingsNoteFileNameFormatIso8601WithTimeZone.
  ///
  /// In en, this message translates to:
  /// **'ISO8601 With TimeZone'**
  String get settingsNoteFileNameFormatIso8601WithTimeZone;

  /// No description provided for @settingsNoteFileNameFormatIso8601.
  ///
  /// In en, this message translates to:
  /// **'ISO8601'**
  String get settingsNoteFileNameFormatIso8601;

  /// No description provided for @settingsNoteFileNameFormatIso8601WithoutColon.
  ///
  /// In en, this message translates to:
  /// **'ISO8601 without Colons'**
  String get settingsNoteFileNameFormatIso8601WithoutColon;

  /// No description provided for @settingsNoteFileNameFormatTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get settingsNoteFileNameFormatTitle;

  /// No description provided for @settingsNoteFileNameFormatUuid.
  ///
  /// In en, this message translates to:
  /// **'Uuid V4'**
  String get settingsNoteFileNameFormatUuid;

  /// No description provided for @settingsNoteFileNameFormatZettelkasten.
  ///
  /// In en, this message translates to:
  /// **'yyyymmddhhmmss'**
  String get settingsNoteFileNameFormatZettelkasten;

  /// No description provided for @settingsNoteFileNameFormatSimple.
  ///
  /// In en, this message translates to:
  /// **'yyyy-mm-dd-hh-mm-ss'**
  String get settingsNoteFileNameFormatSimple;

  /// No description provided for @settingsNoteFileNameFormatDateOnly.
  ///
  /// In en, this message translates to:
  /// **'yyyy-mm-dd'**
  String get settingsNoteFileNameFormatDateOnly;

  /// No description provided for @settingsNoteFileNameFormatKebabCase.
  ///
  /// In en, this message translates to:
  /// **'Kebab Case'**
  String get settingsNoteFileNameFormatKebabCase;

  /// No description provided for @settingsHomeScreenAllNotes.
  ///
  /// In en, this message translates to:
  /// **'All Notes'**
  String get settingsHomeScreenAllNotes;

  /// No description provided for @settingsHomeScreenAllFolders.
  ///
  /// In en, this message translates to:
  /// **'All Folders'**
  String get settingsHomeScreenAllFolders;

  /// No description provided for @settingsEditorDefaultViewEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get settingsEditorDefaultViewEdit;

  /// No description provided for @settingsEditorDefaultViewView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get settingsEditorDefaultViewView;

  /// No description provided for @settingsEditorDefaultViewLastUsed.
  ///
  /// In en, this message translates to:
  /// **'Last Used'**
  String get settingsEditorDefaultViewLastUsed;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsThemeDefault;

  /// No description provided for @settingsVersionCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied version to clipboard'**
  String get settingsVersionCopied;

  /// No description provided for @settingsSshSyncFreq.
  ///
  /// In en, this message translates to:
  /// **'Sync Frequency'**
  String get settingsSshSyncFreq;

  /// No description provided for @settingsNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Note Settings'**
  String get settingsNoteTitle;

  /// No description provided for @settingsNoteDefaultFolder.
  ///
  /// In en, this message translates to:
  /// **'Default Folder for new notes'**
  String get settingsNoteDefaultFolder;

  /// No description provided for @settingsNoteNewNoteFileName.
  ///
  /// In en, this message translates to:
  /// **'New Note Filename'**
  String get settingsNoteNewNoteFileName;

  /// No description provided for @settingsStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get settingsStorageTitle;

  /// No description provided for @settingsStorageFileName.
  ///
  /// In en, this message translates to:
  /// **'filename'**
  String get settingsStorageFileName;

  /// No description provided for @settingsStorageExternal.
  ///
  /// In en, this message translates to:
  /// **'Store Repo Externally'**
  String get settingsStorageExternal;

  /// No description provided for @settingsStorageIcloud.
  ///
  /// In en, this message translates to:
  /// **'Store in iCloud'**
  String get settingsStorageIcloud;

  /// No description provided for @settingsStorageRepoLocation.
  ///
  /// In en, this message translates to:
  /// **'Repo Location'**
  String get settingsStorageRepoLocation;

  /// No description provided for @settingsStorageNotWritable.
  ///
  /// In en, this message translates to:
  /// **'{loc} is not writable'**
  String settingsStorageNotWritable(Object loc);

  /// No description provided for @settingsStorageFailedExternal.
  ///
  /// In en, this message translates to:
  /// **'Unable to get External Storage Directory'**
  String get settingsStorageFailedExternal;

  /// No description provided for @settingsStoragePermissionFailed.
  ///
  /// In en, this message translates to:
  /// **'External Storage Permission Failed'**
  String get settingsStoragePermissionFailed;

  /// No description provided for @settingsDrawerTitle.
  ///
  /// In en, this message translates to:
  /// **'Sidebar Settings'**
  String get settingsDrawerTitle;

  /// No description provided for @settingsBottomMenuBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Bottom Menu Bar'**
  String get settingsBottomMenuBarTitle;

  /// No description provided for @settingsBottomMenuBarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure its appearance and behavior'**
  String get settingsBottomMenuBarSubtitle;

  /// No description provided for @settingsBottomMenuBarEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable Bottom Menu Bar'**
  String get settingsBottomMenuBarEnable;

  /// No description provided for @settingsDeleteRepo.
  ///
  /// In en, this message translates to:
  /// **'Delete Repository'**
  String get settingsDeleteRepo;

  /// No description provided for @settingsFileFormatMarkdown.
  ///
  /// In en, this message translates to:
  /// **'Markdown'**
  String get settingsFileFormatMarkdown;

  /// No description provided for @settingsFileFormatTxt.
  ///
  /// In en, this message translates to:
  /// **'Txt'**
  String get settingsFileFormatTxt;

  /// No description provided for @settingsFileFormatOrgMode.
  ///
  /// In en, this message translates to:
  /// **'Org Mode'**
  String get settingsFileFormatOrgMode;

  /// No description provided for @settingsFileTypesTitle.
  ///
  /// In en, this message translates to:
  /// **'Note File Types'**
  String get settingsFileTypesTitle;

  /// No description provided for @settingsFileTypesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure what files are considered Notes'**
  String get settingsFileTypesSubtitle;

  /// No description provided for @settingsFileTypesNumFiles.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero{No Files} one{1 File} other{{count} Files}}'**
  String settingsFileTypesNumFiles(num count);

  /// No description provided for @settingsFileTypesNoExt.
  ///
  /// In en, this message translates to:
  /// **'No Extension'**
  String get settingsFileTypesNoExt;

  /// No description provided for @settingsListUserInterfaceTitle.
  ///
  /// In en, this message translates to:
  /// **'User Interface'**
  String get settingsListUserInterfaceTitle;

  /// No description provided for @settingsListUserInterfaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Theme, Language, Home, Bottom Bar, Rendering'**
  String get settingsListUserInterfaceSubtitle;

  /// No description provided for @settingsListGitTitle.
  ///
  /// In en, this message translates to:
  /// **'Git'**
  String get settingsListGitTitle;

  /// No description provided for @settingsListGitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Git Author, Remote, Sync Frequency'**
  String get settingsListGitSubtitle;

  /// No description provided for @settingsListEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Editor'**
  String get settingsListEditorTitle;

  /// No description provided for @settingsListEditorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Default Editor, Default View'**
  String get settingsListEditorSubtitle;

  /// No description provided for @settingsListStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage & File Formats'**
  String get settingsListStorageTitle;

  /// No description provided for @settingsListStorageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Storage, Serialization, Metadata, File Formats'**
  String get settingsListStorageSubtitle;

  /// No description provided for @settingsListAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get settingsListAnalyticsTitle;

  /// No description provided for @settingsListAnalyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'It\'s important that you feel comfortable'**
  String get settingsListAnalyticsSubtitle;

  /// No description provided for @settingsListDebugTitle.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get settingsListDebugTitle;

  /// No description provided for @settingsListDebugSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Peek inside the inner workings of GitJournal'**
  String get settingsListDebugSubtitle;

  /// No description provided for @settingsListExperimentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Experiments'**
  String get settingsListExperimentsTitle;

  /// No description provided for @settingsListExperimentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play around with experimental features'**
  String get settingsListExperimentsSubtitle;

  /// No description provided for @settingsProjectHeader.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get settingsProjectHeader;

  /// No description provided for @settingsProjectDocs.
  ///
  /// In en, this message translates to:
  /// **'Documentation & Support'**
  String get settingsProjectDocs;

  /// No description provided for @settingsProjectContribute.
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get settingsProjectContribute;

  /// No description provided for @settingsProjectAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsProjectAbout;

  /// No description provided for @settingsLicenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get settingsLicenseTitle;

  /// No description provided for @settingsLicenseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'GitJoural uses other great software'**
  String get settingsLicenseSubtitle;

  /// No description provided for @settingsSshKeyKeyType.
  ///
  /// In en, this message translates to:
  /// **'SSH Key Type'**
  String get settingsSshKeyKeyType;

  /// No description provided for @settingsSshKeyRsa.
  ///
  /// In en, this message translates to:
  /// **'RSA'**
  String get settingsSshKeyRsa;

  /// No description provided for @settingsSshKeyEd25519.
  ///
  /// In en, this message translates to:
  /// **'Ed25519'**
  String get settingsSshKeyEd25519;

  /// No description provided for @editorsChecklistAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get editorsChecklistAdd;

  /// No description provided for @editorsCommonDefaultBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Write here'**
  String get editorsCommonDefaultBodyHint;

  /// No description provided for @editorsCommonDefaultTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get editorsCommonDefaultTitleHint;

  /// No description provided for @editorsCommonDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard Changes'**
  String get editorsCommonDiscard;

  /// No description provided for @editorsCommonShare.
  ///
  /// In en, this message translates to:
  /// **'Share Note'**
  String get editorsCommonShare;

  /// No description provided for @editorsCommonTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get editorsCommonTakePhoto;

  /// No description provided for @editorsCommonAddImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image from Gallery'**
  String get editorsCommonAddImage;

  /// No description provided for @editorsCommonEditFileName.
  ///
  /// In en, this message translates to:
  /// **'Edit File Name'**
  String get editorsCommonEditFileName;

  /// No description provided for @editorsCommonTags.
  ///
  /// In en, this message translates to:
  /// **'Edit Tags'**
  String get editorsCommonTags;

  /// No description provided for @editorsCommonZenEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable Zen Mode'**
  String get editorsCommonZenEnable;

  /// No description provided for @editorsCommonZenDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable Zen Mode'**
  String get editorsCommonZenDisable;

  /// No description provided for @editorsCommonSaveNoteFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Failed to Save Note'**
  String get editorsCommonSaveNoteFailedTitle;

  /// No description provided for @editorsCommonSaveNoteFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'re sorry, but we cannot seem to save the Note. It has been copied to the clipboard to avoid data loss.'**
  String get editorsCommonSaveNoteFailedMessage;

  /// No description provided for @editorsCommonDefaultFileNameHint.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get editorsCommonDefaultFileNameHint;

  /// No description provided for @editorsCommonFind.
  ///
  /// In en, this message translates to:
  /// **'Find in note'**
  String get editorsCommonFind;

  /// No description provided for @actionsNewNote.
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get actionsNewNote;

  /// No description provided for @actionsNewJournal.
  ///
  /// In en, this message translates to:
  /// **'New Journal Entry'**
  String get actionsNewJournal;

  /// No description provided for @actionsNewChecklist.
  ///
  /// In en, this message translates to:
  /// **'New Checklist'**
  String get actionsNewChecklist;

  /// No description provided for @screensFoldersTitle.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get screensFoldersTitle;

  /// No description provided for @screensFoldersSelected.
  ///
  /// In en, this message translates to:
  /// **'Folder Selected'**
  String get screensFoldersSelected;

  /// No description provided for @screensFoldersDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Create new Folder'**
  String get screensFoldersDialogTitle;

  /// No description provided for @screensFoldersDialogCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get screensFoldersDialogCreate;

  /// No description provided for @screensFoldersDialogDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get screensFoldersDialogDiscard;

  /// No description provided for @screensFoldersErrorDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get screensFoldersErrorDialogTitle;

  /// No description provided for @screensFoldersErrorDialogDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete a Folder which contains notes'**
  String get screensFoldersErrorDialogDeleteContent;

  /// No description provided for @screensFoldersErrorDialogRenameContent.
  ///
  /// In en, this message translates to:
  /// **'Cannot rename Root Folder'**
  String get screensFoldersErrorDialogRenameContent;

  /// No description provided for @screensFoldersErrorDialogOk.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get screensFoldersErrorDialogOk;

  /// No description provided for @screensFoldersActionsRename.
  ///
  /// In en, this message translates to:
  /// **'Rename Folder'**
  String get screensFoldersActionsRename;

  /// No description provided for @screensFoldersActionsSubFolder.
  ///
  /// In en, this message translates to:
  /// **'Create Sub-Folder'**
  String get screensFoldersActionsSubFolder;

  /// No description provided for @screensFoldersActionsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Folder'**
  String get screensFoldersActionsDelete;

  /// No description provided for @screensFoldersActionsDecoration.
  ///
  /// In en, this message translates to:
  /// **'Folder Name'**
  String get screensFoldersActionsDecoration;

  /// No description provided for @screensFoldersActionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get screensFoldersActionsEmpty;

  /// No description provided for @screensTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get screensTagsTitle;

  /// No description provided for @screensTagsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Tags Found'**
  String get screensTagsEmpty;

  /// No description provided for @screensFilesystemIgnoredFileTitle.
  ///
  /// In en, this message translates to:
  /// **'File Ignored'**
  String get screensFilesystemIgnoredFileTitle;

  /// No description provided for @screensFilesystemIgnoredFileOk.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get screensFilesystemIgnoredFileOk;

  /// No description provided for @screensFilesystemIgnoredFileRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get screensFilesystemIgnoredFileRename;

  /// No description provided for @screensFilesystemRenameDecoration.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get screensFilesystemRenameDecoration;

  /// No description provided for @screensFilesystemRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get screensFilesystemRenameTitle;

  /// No description provided for @screensFolderViewEmpty.
  ///
  /// In en, this message translates to:
  /// **'Let\'s add some notes?'**
  String get screensFolderViewEmpty;

  /// No description provided for @screensHomeAllNotes.
  ///
  /// In en, this message translates to:
  /// **'All Notes'**
  String get screensHomeAllNotes;

  /// No description provided for @screensCacheLoadingText.
  ///
  /// In en, this message translates to:
  /// **'Reading Git History ...'**
  String get screensCacheLoadingText;

  /// No description provided for @screensErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get screensErrorTitle;

  /// No description provided for @screensErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'The repo couldn\'t be opened. Please file a bug and recreate the repo.'**
  String get screensErrorMessage;

  /// No description provided for @widgetsRenameYes.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get widgetsRenameYes;

  /// No description provided for @widgetsRenameNo.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get widgetsRenameNo;

  /// No description provided for @widgetsRenameValidatorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get widgetsRenameValidatorEmpty;

  /// No description provided for @widgetsRenameValidatorExists.
  ///
  /// In en, this message translates to:
  /// **'Already Exists'**
  String get widgetsRenameValidatorExists;

  /// No description provided for @widgetsRenameValidatorContains.
  ///
  /// In en, this message translates to:
  /// **'Cannot contain /'**
  String get widgetsRenameValidatorContains;

  /// No description provided for @widgetsRenameNoExt.
  ///
  /// In en, this message translates to:
  /// **'Warning: Extension missing. Will treat file as plain text'**
  String get widgetsRenameNoExt;

  /// No description provided for @widgetsRenameChangeExt.
  ///
  /// In en, this message translates to:
  /// **'Warning: Changing file type from \'{from}\' to \'{to}\''**
  String widgetsRenameChangeExt(Object from, Object to);

  /// No description provided for @widgetsBacklinksTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 Note links to this Note} other{{count} Notes link to this Note}}'**
  String widgetsBacklinksTitle(num count);

  /// No description provided for @widgetsSortingOrderSelectorTitle.
  ///
  /// In en, this message translates to:
  /// **'Sorting Criteria'**
  String get widgetsSortingOrderSelectorTitle;

  /// No description provided for @widgetsPurchaseButtonText.
  ///
  /// In en, this message translates to:
  /// **'Purchase for {price}'**
  String widgetsPurchaseButtonText(Object price);

  /// No description provided for @widgetsPurchaseButtonFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load'**
  String get widgetsPurchaseButtonFail;

  /// No description provided for @widgetsPurchaseButtonFailSend.
  ///
  /// In en, this message translates to:
  /// **'Failed to send purchase request'**
  String get widgetsPurchaseButtonFailSend;

  /// No description provided for @widgetsPurchaseButtonFailPurchase.
  ///
  /// In en, this message translates to:
  /// **'Failed to Purchase - {err}'**
  String widgetsPurchaseButtonFailPurchase(Object err);

  /// No description provided for @widgetsFolderViewSyncError.
  ///
  /// In en, this message translates to:
  /// **'Sync Error {err}'**
  String widgetsFolderViewSyncError(Object err);

  /// No description provided for @widgetsFolderViewHeaderOptionsHeading.
  ///
  /// In en, this message translates to:
  /// **'Header Options'**
  String get widgetsFolderViewHeaderOptionsHeading;

  /// No description provided for @widgetsFolderViewHeaderOptionsAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto Generated Title'**
  String get widgetsFolderViewHeaderOptionsAuto;

  /// No description provided for @widgetsFolderViewHeaderOptionsTitleFileName.
  ///
  /// In en, this message translates to:
  /// **'Title or FileName'**
  String get widgetsFolderViewHeaderOptionsTitleFileName;

  /// No description provided for @widgetsFolderViewHeaderOptionsFileName.
  ///
  /// In en, this message translates to:
  /// **'FileName'**
  String get widgetsFolderViewHeaderOptionsFileName;

  /// No description provided for @widgetsFolderViewHeaderOptionsSummary.
  ///
  /// In en, this message translates to:
  /// **'Show Summary'**
  String get widgetsFolderViewHeaderOptionsSummary;

  /// No description provided for @widgetsFolderViewHeaderOptionsCustomize.
  ///
  /// In en, this message translates to:
  /// **'Customize View'**
  String get widgetsFolderViewHeaderOptionsCustomize;

  /// No description provided for @widgetsFolderViewViewsStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard View'**
  String get widgetsFolderViewViewsStandard;

  /// No description provided for @widgetsFolderViewViewsJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal View'**
  String get widgetsFolderViewViewsJournal;

  /// No description provided for @widgetsFolderViewViewsGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid View'**
  String get widgetsFolderViewViewsGrid;

  /// No description provided for @widgetsFolderViewViewsCard.
  ///
  /// In en, this message translates to:
  /// **'Card View'**
  String get widgetsFolderViewViewsCard;

  /// No description provided for @widgetsFolderViewViewsSelect.
  ///
  /// In en, this message translates to:
  /// **'Select View'**
  String get widgetsFolderViewViewsSelect;

  /// No description provided for @widgetsFolderViewViewsCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar View'**
  String get widgetsFolderViewViewsCalendar;

  /// No description provided for @widgetsFolderViewSortingOptions.
  ///
  /// In en, this message translates to:
  /// **'Sorting Options'**
  String get widgetsFolderViewSortingOptions;

  /// No description provided for @widgetsFolderViewViewOptions.
  ///
  /// In en, this message translates to:
  /// **'View Options'**
  String get widgetsFolderViewViewOptions;

  /// No description provided for @widgetsFolderViewNoteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Note Deleted'**
  String get widgetsFolderViewNoteDeleted;

  /// No description provided for @widgetsFolderViewUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get widgetsFolderViewUndo;

  /// No description provided for @widgetsFolderViewSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'No Search Results Found'**
  String get widgetsFolderViewSearchFailed;

  /// No description provided for @widgetsFolderViewActionsMoveToFolder.
  ///
  /// In en, this message translates to:
  /// **'Move To Folder'**
  String get widgetsFolderViewActionsMoveToFolder;

  /// No description provided for @widgetsFolderViewPinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get widgetsFolderViewPinned;

  /// No description provided for @widgetsFolderViewOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get widgetsFolderViewOthers;

  /// No description provided for @widgetsImageRendererCaption.
  ///
  /// In en, this message translates to:
  /// **'{first} - {second}'**
  String widgetsImageRendererCaption(Object first, Object second);

  /// No description provided for @widgetsImageRendererHttpError.
  ///
  /// In en, this message translates to:
  /// **'Code: {status} for {url}'**
  String widgetsImageRendererHttpError(Object status, Object url);

  /// No description provided for @widgetsNoteDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Do you want to delete this note?} other{Do you want to delete these {count} notes?}}'**
  String widgetsNoteDeleteDialogTitle(num count);

  /// No description provided for @widgetsNotesFolderDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this folder and everything inside it?'**
  String get widgetsNotesFolderDeleteDialogTitle;

  /// No description provided for @widgetsNoteDeleteDialogYes.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get widgetsNoteDeleteDialogYes;

  /// No description provided for @widgetsNoteDeleteDialogNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get widgetsNoteDeleteDialogNo;

  /// No description provided for @widgetsNoteEditorRenameFile.
  ///
  /// In en, this message translates to:
  /// **'Rename File'**
  String get widgetsNoteEditorRenameFile;

  /// No description provided for @widgetsNoteEditorFileName.
  ///
  /// In en, this message translates to:
  /// **'Filename'**
  String get widgetsNoteEditorFileName;

  /// No description provided for @widgetsNoteEditorAddType.
  ///
  /// In en, this message translates to:
  /// **'Adding \'{ext}\' to supported file types'**
  String widgetsNoteEditorAddType(Object ext);

  /// No description provided for @widgetsSyncButtonError.
  ///
  /// In en, this message translates to:
  /// **'Sync Error {err}'**
  String widgetsSyncButtonError(Object err);

  /// No description provided for @widgetsPurchaseWidgetFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase Failed'**
  String get widgetsPurchaseWidgetFailed;

  /// No description provided for @widgetsNoteViewerLinkNotFound.
  ///
  /// In en, this message translates to:
  /// **'Link \'{name}\' not found'**
  String widgetsNoteViewerLinkNotFound(Object name);

  /// No description provided for @widgetsNoteViewerLinkInvalid.
  ///
  /// In en, this message translates to:
  /// **'Link \'{name}\' is invalid.'**
  String widgetsNoteViewerLinkInvalid(Object name);

  /// No description provided for @widgetsFolderSelectionDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a Folder'**
  String get widgetsFolderSelectionDialogTitle;

  /// No description provided for @widgetsFolderTreeViewNotesCount.
  ///
  /// In en, this message translates to:
  /// **'{num} Notes'**
  String widgetsFolderTreeViewNotesCount(Object num);

  /// No description provided for @ignoredFilesDot.
  ///
  /// In en, this message translates to:
  /// **'Starts with a .'**
  String get ignoredFilesDot;

  /// No description provided for @ignoredFilesExt.
  ///
  /// In en, this message translates to:
  /// **'Doesn\'t end with one of the following -'**
  String get ignoredFilesExt;

  /// No description provided for @drawerSetup.
  ///
  /// In en, this message translates to:
  /// **'Setup Git Host'**
  String get drawerSetup;

  /// No description provided for @drawerPro.
  ///
  /// In en, this message translates to:
  /// **'Unlock Pro Version'**
  String get drawerPro;

  /// No description provided for @drawerAll.
  ///
  /// In en, this message translates to:
  /// **'All Notes'**
  String get drawerAll;

  /// No description provided for @drawerFolders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get drawerFolders;

  /// No description provided for @drawerFs.
  ///
  /// In en, this message translates to:
  /// **'File System'**
  String get drawerFs;

  /// No description provided for @drawerTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get drawerTags;

  /// No description provided for @drawerShare.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get drawerShare;

  /// No description provided for @drawerRate.
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get drawerRate;

  /// No description provided for @drawerFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get drawerFeedback;

  /// No description provided for @drawerBug.
  ///
  /// In en, this message translates to:
  /// **'Bug Report'**
  String get drawerBug;

  /// No description provided for @drawerGraph.
  ///
  /// In en, this message translates to:
  /// **'Graph View'**
  String get drawerGraph;

  /// No description provided for @drawerRemote.
  ///
  /// In en, this message translates to:
  /// **'No Git Host'**
  String get drawerRemote;

  /// No description provided for @drawerAddRepo.
  ///
  /// In en, this message translates to:
  /// **'Add Repository'**
  String get drawerAddRepo;

  /// No description provided for @drawerLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get drawerLogin;

  /// No description provided for @drawerHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get drawerHistory;

  /// No description provided for @setupAutoConfigureTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you want to do this?'**
  String get setupAutoConfigureTitle;

  /// No description provided for @setupAutoConfigureAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Setup Automatically'**
  String get setupAutoConfigureAutomatic;

  /// No description provided for @setupAutoConfigureManual.
  ///
  /// In en, this message translates to:
  /// **'Let me do it manually'**
  String get setupAutoConfigureManual;

  /// No description provided for @setupAutoconfigureStep1.
  ///
  /// In en, this message translates to:
  /// **'1. List your existing repos or create a new repo'**
  String get setupAutoconfigureStep1;

  /// No description provided for @setupAutoconfigureStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Generate an SSH Key on this device'**
  String get setupAutoconfigureStep2;

  /// No description provided for @setupAutoconfigureStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Add the key as a deploy key with write access to the repository'**
  String get setupAutoconfigureStep3;

  /// No description provided for @setupAutoconfigureWarning.
  ///
  /// In en, this message translates to:
  /// **'This will require granting GitJournal access to all private and public repos. If you\'re not comfortable with that please go back and chose the manual setup option.'**
  String get setupAutoconfigureWarning;

  /// No description provided for @setupAutoconfigureAuthorize.
  ///
  /// In en, this message translates to:
  /// **'Authorize GitJournal'**
  String get setupAutoconfigureAuthorize;

  /// No description provided for @setupAutoconfigureWaitPerm.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Permissions ...'**
  String get setupAutoconfigureWaitPerm;

  /// No description provided for @setupAutoconfigureReadUser.
  ///
  /// In en, this message translates to:
  /// **'Reading User Info'**
  String get setupAutoconfigureReadUser;

  /// No description provided for @setupRepoSelectorTitle.
  ///
  /// In en, this message translates to:
  /// **'Select or Create a Repository'**
  String get setupRepoSelectorTitle;

  /// No description provided for @setupRepoSelectorHint.
  ///
  /// In en, this message translates to:
  /// **'Type to Search or Create a Repo'**
  String get setupRepoSelectorHint;

  /// No description provided for @setupRepoSelectorCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Private Repo {name}'**
  String setupRepoSelectorCreate(Object name);

  /// No description provided for @setupRepoSelectorLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get setupRepoSelectorLoading;

  /// No description provided for @setupCloneUrlEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter the Git Clone URL'**
  String get setupCloneUrlEnter;

  /// No description provided for @setupCloneUrlValidatorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter some text'**
  String get setupCloneUrlValidatorEmpty;

  /// No description provided for @setupCloneUrlValidatorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid Input'**
  String get setupCloneUrlValidatorInvalid;

  /// No description provided for @setupCloneUrlValidatorOnlySsh.
  ///
  /// In en, this message translates to:
  /// **'Only SSH urls are currently accepted'**
  String get setupCloneUrlValidatorOnlySsh;

  /// No description provided for @setupCloneUrlManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Please create a new git repository -'**
  String get setupCloneUrlManualTitle;

  /// No description provided for @setupCloneUrlManualStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Go to the website, create a repo and copy its git clone URL'**
  String get setupCloneUrlManualStep1;

  /// No description provided for @setupCloneUrlManualStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Enter the Git clone URL'**
  String get setupCloneUrlManualStep2;

  /// No description provided for @setupCloneUrlManualButton.
  ///
  /// In en, this message translates to:
  /// **'Open Create New Repo Webpage'**
  String get setupCloneUrlManualButton;

  /// No description provided for @setupNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get setupNext;

  /// No description provided for @setupFail.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get setupFail;

  /// No description provided for @setupKeyEditorsPublic.
  ///
  /// In en, this message translates to:
  /// **'Invalid Public Key - Doesn\'t start with ssh-rsa or ssh-ed25519'**
  String get setupKeyEditorsPublic;

  /// No description provided for @setupKeyEditorsPrivate.
  ///
  /// In en, this message translates to:
  /// **'Invalid Private Key'**
  String get setupKeyEditorsPrivate;

  /// No description provided for @setupKeyEditorsLoad.
  ///
  /// In en, this message translates to:
  /// **'Load from File'**
  String get setupKeyEditorsLoad;

  /// No description provided for @setupSshKeyGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generating SSH Key'**
  String get setupSshKeyGenerate;

  /// No description provided for @setupSshKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'In order to access this repository, this public key must be copied as a deploy key'**
  String get setupSshKeyTitle;

  /// No description provided for @setupSshKeyStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Copy the key'**
  String get setupSshKeyStep1;

  /// No description provided for @setupSshKeyStep2a.
  ///
  /// In en, this message translates to:
  /// **'2. Open webpage, and paste the deploy key. Make sure it is given Write Access.'**
  String get setupSshKeyStep2a;

  /// No description provided for @setupSshKeyStep2b.
  ///
  /// In en, this message translates to:
  /// **'2. Give this SSH Key access to the git repo. (You need to figure it out yourself)'**
  String get setupSshKeyStep2b;

  /// No description provided for @setupSshKeyStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Try Cloning ..'**
  String get setupSshKeyStep3;

  /// No description provided for @setupSshKeyCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy Key'**
  String get setupSshKeyCopy;

  /// No description provided for @setupSshKeyCopied.
  ///
  /// In en, this message translates to:
  /// **'Public Key copied to Clipboard'**
  String get setupSshKeyCopied;

  /// No description provided for @setupSshKeyRegenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate Key'**
  String get setupSshKeyRegenerate;

  /// No description provided for @setupSshKeyOpenDeploy.
  ///
  /// In en, this message translates to:
  /// **'Open Deploy Key Webpage'**
  String get setupSshKeyOpenDeploy;

  /// No description provided for @setupSshKeyClone.
  ///
  /// In en, this message translates to:
  /// **'Clone Repo'**
  String get setupSshKeyClone;

  /// No description provided for @setupSshKeyAddDeploy.
  ///
  /// In en, this message translates to:
  /// **'Adding as a Deploy Key'**
  String get setupSshKeyAddDeploy;

  /// No description provided for @setupSshKeySave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get setupSshKeySave;

  /// No description provided for @setupSshKeyChoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'We need SSH keys to authenticate -'**
  String get setupSshKeyChoiceTitle;

  /// No description provided for @setupSshKeyChoiceGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate new keys'**
  String get setupSshKeyChoiceGenerate;

  /// No description provided for @setupSshKeyChoiceCustom.
  ///
  /// In en, this message translates to:
  /// **'Provide Custom SSH Keys'**
  String get setupSshKeyChoiceCustom;

  /// No description provided for @setupSshKeyUserProvidedPublic.
  ///
  /// In en, this message translates to:
  /// **'Public Key -'**
  String get setupSshKeyUserProvidedPublic;

  /// No description provided for @setupSshKeyUserProvidedPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private Key -'**
  String get setupSshKeyUserProvidedPrivate;

  /// No description provided for @setupSshKeyUserProvidedPassword.
  ///
  /// In en, this message translates to:
  /// **'Private Key Password'**
  String get setupSshKeyUserProvidedPassword;

  /// No description provided for @setupCloning.
  ///
  /// In en, this message translates to:
  /// **'Cloning ...'**
  String get setupCloning;

  /// No description provided for @setupHostTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a Git Hosting Provider -'**
  String get setupHostTitle;

  /// No description provided for @setupHostCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get setupHostCustom;

  /// No description provided for @purchaseScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Pro Version'**
  String get purchaseScreenTitle;

  /// No description provided for @purchaseScreenDesc.
  ///
  /// In en, this message translates to:
  /// **'GitJournal is completely open source and is the result of significant development work. It has no venture capital or corporation backing and it never will. Your support directly sustains development.   GitJournal operates on a \"pay what you want model (with a minimum)\".'**
  String get purchaseScreenDesc;

  /// No description provided for @purchaseScreenRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchase'**
  String get purchaseScreenRestore;

  /// No description provided for @purchaseScreenOneTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'One Time Purchase'**
  String get purchaseScreenOneTimeTitle;

  /// No description provided for @purchaseScreenOneTimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently enables all Pro features currently in GitJournal and new features added in the following 12 months.'**
  String get purchaseScreenOneTimeDesc;

  /// No description provided for @purchaseScreenMonthlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Installments'**
  String get purchaseScreenMonthlyTitle;

  /// No description provided for @purchaseScreenMonthlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Enables all Pro Features. After 12 months or after paying {minYearlyPurchase}, you will get all the benefits of the \'One Time Purchase\''**
  String purchaseScreenMonthlyDesc(Object minYearlyPurchase);

  /// No description provided for @purchaseScreenThanksTitle.
  ///
  /// In en, this message translates to:
  /// **'Thank You'**
  String get purchaseScreenThanksTitle;

  /// No description provided for @purchaseScreenThanksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re awesome for supporting GitJournal'**
  String get purchaseScreenThanksSubtitle;

  /// No description provided for @purchaseScreenUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get purchaseScreenUnknown;

  /// No description provided for @onBoardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onBoardingSkip;

  /// No description provided for @onBoardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onBoardingNext;

  /// No description provided for @onBoardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onBoardingGetStarted;

  /// No description provided for @onBoardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'An Open Source Note Taking App built on top of Git'**
  String get onBoardingSubtitle;

  /// No description provided for @onBoardingPage2.
  ///
  /// In en, this message translates to:
  /// **'Your Notes are stored in a standard Markdown + YAML Header format'**
  String get onBoardingPage2;

  /// No description provided for @onBoardingPage3.
  ///
  /// In en, this message translates to:
  /// **'Sync your Local Git Repo with any provider'**
  String get onBoardingPage3;

  /// No description provided for @singleJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'Single Journal Entry File per day'**
  String get singleJournalEntry;

  /// No description provided for @exportRepo.
  ///
  /// In en, this message translates to:
  /// **'Export Repository'**
  String get exportRepo;

  /// No description provided for @shareAsZip.
  ///
  /// In en, this message translates to:
  /// **'Share as a ZIP file'**
  String get shareAsZip;

  /// No description provided for @failedToExport.
  ///
  /// In en, this message translates to:
  /// **'Failed to Export'**
  String get failedToExport;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fa',
        'fi',
        'fr',
        'hi',
        'hu',
        'id',
        'it',
        'ja',
        'ko',
        'pl',
        'pt',
        'ru',
        'sv',
        'ta',
        'vi',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
        }
        break;
      }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fa':
      return AppLocalizationsFa();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'hu':
      return AppLocalizationsHu();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'sv':
      return AppLocalizationsSv();
    case 'ta':
      return AppLocalizationsTa();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
