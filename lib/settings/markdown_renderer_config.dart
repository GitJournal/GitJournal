/*
 * SPDX-FileCopyrightText: 2020-2021 Roland Fredenhagen <important@van-fredenhagen.de>
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/widgets.dart';
import 'package:gitjournal/core/folder/sorting_mode.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/settings/settings_sharedpref.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarkdownRendererConfig extends ChangeNotifier with SettingsSharedPref {
  MarkdownRendererConfig(this.id, this.pref);

  @override
  final String id;

  @override
  final SharedPreferences pref;

  // Display - Image
  bool rotateImageGestures = false;
  double maxImageZoom = 10;

  // Display - Image - Theming
  var themeRasterGraphics = false;
  var themeOverrideTagLocation = SettingsImageTextType.Default;
  var doNotThemeTags = {"notheme", "!nt"};
  var doThemeTags = {"dotheme", "!dt"};
  var themeVectorGraphics = SettingsThemeVectorGraphics.Default;
  var themeSvgWithBackground = false;
  var matchCanvasColor = true;
  var vectorGraphicsAdjustColors = SettingsVectorGraphicsAdjustColors.Default;

  // Display - Image - Caption
  var overlayCaption = true;
  var transparentCaption = true;
  var blurBehindCaption = true;
  var tooltipFirst = false;
  var useAsCaption = SettingsImageTextType.Default;
  var doNotCaptionTags = {"nocaption", "!nc"};
  var doCaptionTags = {"docaption", "!dc"};

  void load() {
    // Display - Image
    rotateImageGestures = getBool("rotateImageGestures") ?? rotateImageGestures;
    maxImageZoom = getDouble("maxImageZoom") ?? maxImageZoom;

    // Display - Image - Theming
    themeRasterGraphics = getBool("themeRasterGraphics") ?? themeRasterGraphics;
    themeOverrideTagLocation = SettingsImageTextType.fromInternalString(
        getString("themeOverrideTagLocation"));
    doNotThemeTags = getStringSet("doNotThemeTags") ?? doNotThemeTags;
    doThemeTags = getStringSet("doThemeTags") ?? doThemeTags;
    themeVectorGraphics = SettingsThemeVectorGraphics.fromInternalString(
        getString("themeVectorGraphics"));
    themeSvgWithBackground =
        getBool("themeSvgWithBackground") ?? themeSvgWithBackground;
    matchCanvasColor = getBool("matchCanvasColor") ?? matchCanvasColor;
    vectorGraphicsAdjustColors =
        SettingsVectorGraphicsAdjustColors.fromInternalString(
            getString("vectorGraphicsAdjustColors"));

    // Display - Image - Caption
    overlayCaption = getBool("overlayCaption") ?? overlayCaption;
    transparentCaption = getBool("transparentCaption") ?? transparentCaption;
    blurBehindCaption = getBool("blurBehindCaption") ?? blurBehindCaption;
    tooltipFirst = getBool("tooltipFirst") ?? tooltipFirst;
    useAsCaption =
        SettingsImageTextType.fromInternalString(getString("useAsCaption"));
    doNotCaptionTags = getStringSet("doNotCaptionTag") ?? doNotCaptionTags;
    doCaptionTags = getStringSet("doCaptionTag") ?? doCaptionTags;
  }

  Future<void> save() async {
    var def = MarkdownRendererConfig(id, pref);

    // Display - Image
    await setBool(
        "rotateImageGestures", rotateImageGestures, def.rotateImageGestures);
    await setDouble("maxImageZoom", maxImageZoom, def.maxImageZoom);

    // Display - Image - Theme
    await setBool(
        "themeRasterGraphics", themeRasterGraphics, def.themeRasterGraphics);
    await setString(
        "themeOverrideTagLocation",
        themeOverrideTagLocation.toInternalString(),
        def.themeOverrideTagLocation.toInternalString());
    await setStringSet("doNotThemeTags", doNotThemeTags, def.doNotThemeTags);
    await setStringSet("doThemeTags", doThemeTags, def.doThemeTags);
    await setString(
        "themeVectorGraphics",
        themeVectorGraphics.toInternalString(),
        def.themeVectorGraphics.toInternalString());
    await setBool("themeSvgWithBackground", themeSvgWithBackground,
        def.themeSvgWithBackground);
    await setBool("matchCanvasColor", matchCanvasColor, def.matchCanvasColor);
    await setString(
        "vectorGraphicsAdjustColors",
        vectorGraphicsAdjustColors.toInternalString(),
        def.vectorGraphicsAdjustColors.toInternalString());

    // Display - Image - Caption
    await setBool("overlayCaption", overlayCaption, def.overlayCaption);
    await setBool(
        "transparentCaption", transparentCaption, def.transparentCaption);
    await setBool(
        "blurBehindCaption", blurBehindCaption, def.blurBehindCaption);
    await setBool("tooltipFirst", tooltipFirst, def.tooltipFirst);
    await setString("useAsCaption", useAsCaption.toInternalString(),
        def.useAsCaption.toInternalString());
    await setStringSet(
        "doNotCaptionTag", doNotCaptionTags, def.doNotCaptionTags);
    await setStringSet("doCaptionTag", doCaptionTags, def.doCaptionTags);

    notifyListeners();
  }

  Map<String, String> toLoggableMap() {
    return <String, String>{
      // Display - Image
      'rotateImageGestures': rotateImageGestures.toString(),
      'maxImageZoom': maxImageZoom.toString(),
      // Display - Image - Theming
      'themeRasterGraphics': themeRasterGraphics.toString(),
      'themeOverrideTagLocation': themeOverrideTagLocation.toInternalString(),
      'doNotThemeTags': csvTags(doNotThemeTags),
      'doThemeTags': csvTags(doThemeTags),
      'themeVectorGraphics': themeVectorGraphics.toInternalString(),
      'themeSvgWithBackground': themeSvgWithBackground.toString(),
      'matchCanvasColor': matchCanvasColor.toString(),
      'vectorGraphicsAdjustColors':
          vectorGraphicsAdjustColors.toInternalString(),
      // Display - Image - Caption
      'overlayCaption': overlayCaption.toString(),
      'transparentCaption': transparentCaption.toString(),
      'blurBehindCaption': blurBehindCaption.toString(),
      'tooltipFirst': tooltipFirst.toString(),
      'useAsCaption': useAsCaption.toInternalString(),
      'doNotCaptionTag': csvTags(doNotCaptionTags),
      'doCaptionTag': csvTags(doCaptionTags),
    };
  }
}

String csvTags(Set<String> tags) {
  return tags.join(", ");
}

class SettingsThemeVectorGraphics extends GjSetting {
  static const On = SettingsThemeVectorGraphics(
      Lk.settingsDisplayImagesThemingThemeVectorGraphicsOn, "on");
  static const Off = SettingsThemeVectorGraphics(
      Lk.settingsDisplayImagesThemingThemeVectorGraphicsOff, "off");
  static const Filter = SettingsThemeVectorGraphics(
      Lk.settingsDisplayImagesThemingThemeVectorGraphicsFilter, "filter");
  static const Default = On;

  const SettingsThemeVectorGraphics(super.lk, super.str);

  static const options = <SettingsThemeVectorGraphics>[
    On,
    Off,
    Filter,
  ];

  static SettingsThemeVectorGraphics fromInternalString(String? str) =>
      GjSetting.fromInternalString(options, Default, str)
          as SettingsThemeVectorGraphics;

  static SettingsThemeVectorGraphics fromPublicString(
          BuildContext context, String str) =>
      GjSetting.fromPublicString(context, options, Default, str)
          as SettingsThemeVectorGraphics;
}

class SettingsVectorGraphicsAdjustColors extends GjSetting {
  static const All = SettingsVectorGraphicsAdjustColors(
      Lk.settingsDisplayImagesThemingAdjustColorsAll, "all");
  static const BnW = SettingsVectorGraphicsAdjustColors(
      Lk.settingsDisplayImagesThemingAdjustColorsBlackAndWhite,
      "black_and_white");
  static const Grays = SettingsVectorGraphicsAdjustColors(
      Lk.settingsDisplayImagesThemingAdjustColorsGrays, "grays");
  static const Default = All;

  const SettingsVectorGraphicsAdjustColors(super.lk, super.str);

  static const options = <SettingsVectorGraphicsAdjustColors>[
    BnW,
    Grays,
    All,
  ];

  static SettingsVectorGraphicsAdjustColors fromInternalString(String? str) =>
      GjSetting.fromInternalString(options, Default, str)
          as SettingsVectorGraphicsAdjustColors;

  static SettingsVectorGraphicsAdjustColors fromPublicString(
          BuildContext context, String str) =>
      GjSetting.fromPublicString(context, options, Default, str)
          as SettingsVectorGraphicsAdjustColors;
}

class SettingsImageTextType extends GjSetting {
  static const AltTool = SettingsImageTextType(
      Lk.settingsDisplayImagesImageTextTypeAltAndTooltip, "alt_and_tooltip");
  static const Tooltip = SettingsImageTextType(
      Lk.settingsDisplayImagesImageTextTypeTooltip, "tooltip");
  static const Alt =
      SettingsImageTextType(Lk.settingsDisplayImagesImageTextTypeAlt, "alt");
  static const None =
      SettingsImageTextType(Lk.settingsDisplayImagesImageTextTypeNone, "none");
  static const Default = AltTool;

  const SettingsImageTextType(super.lk, super.str);

  static const options = <SettingsImageTextType>[
    AltTool,
    Tooltip,
    Alt,
    None,
  ];

  static SettingsImageTextType fromInternalString(String? str) =>
      GjSetting.fromInternalString(options, Default, str)
          as SettingsImageTextType;

  static SettingsImageTextType fromPublicString(
          BuildContext context, String str) =>
      GjSetting.fromPublicString(context, options, Default, str)
          as SettingsImageTextType;
}
