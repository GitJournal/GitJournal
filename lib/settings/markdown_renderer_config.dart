/*
 * SPDX-FileCopyrightText: 2020-2021 Roland Fredenhagen <important@van-fredenhagen.de>
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/foundation.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/settings/settings_sharedpref.dart';

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

class SettingsThemeVectorGraphics {
  static const On = SettingsThemeVectorGraphics(
      "settings.display.images.theming.themeVectorGraphics.on", "on");
  static const Off = SettingsThemeVectorGraphics(
      "settings.display.images.theming.themeVectorGraphics.off", "off");
  static const Filter = SettingsThemeVectorGraphics(
      "settings.display.images.theming.themeVectorGraphics.filter", "filter");
  static const Default = On;

  final String _str;
  final String _publicString;
  const SettingsThemeVectorGraphics(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicString);
  }

  static const options = <SettingsThemeVectorGraphics>[
    On,
    Off,
    Filter,
  ];

  static SettingsThemeVectorGraphics fromInternalString(String? str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static SettingsThemeVectorGraphics fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }

  @override
  String toString() {
    assert(
        false, "SettingsThemeVectorGraphics toString should never be called");
    return "";
  }
}

class SettingsVectorGraphicsAdjustColors {
  static const All = SettingsVectorGraphicsAdjustColors(
      "settings.display.images.theming.adjustColors.all", "all");
  static const BnW = SettingsVectorGraphicsAdjustColors(
      "settings.display.images.theming.adjustColors.blackAndWhite",
      "black_and_white");
  static const Grays = SettingsVectorGraphicsAdjustColors(
      "settings.display.images.theming.adjustColors.grays", "grays");
  static const Default = All;

  final String _str;
  final String _publicString;
  const SettingsVectorGraphicsAdjustColors(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicString);
  }

  static const options = <SettingsVectorGraphicsAdjustColors>[
    BnW,
    Grays,
    All,
  ];

  static SettingsVectorGraphicsAdjustColors fromInternalString(String? str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static SettingsVectorGraphicsAdjustColors fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }

  @override
  String toString() {
    assert(false,
        "SettingsVectorGraphicsAdjustColors toString should never be called");
    return "";
  }
}

class SettingsImageTextType {
  static const AltTool = SettingsImageTextType(
      "settings.display.images.imageTextType.altAndTooltip", "alt_and_tooltip");
  static const Tooltip = SettingsImageTextType(
      "settings.display.images.imageTextType.tooltip", "tooltip");
  static const Alt =
      SettingsImageTextType("settings.display.images.imageTextType.alt", "alt");
  static const None = SettingsImageTextType(
      "settings.display.images.imageTextType.none", "none");
  static const Default = AltTool;

  final String _str;
  final String _publicString;
  const SettingsImageTextType(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicString);
  }

  static const options = <SettingsImageTextType>[
    AltTool,
    Tooltip,
    Alt,
    None,
  ];

  static SettingsImageTextType fromInternalString(String? str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static SettingsImageTextType fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }

  @override
  String toString() {
    assert(false,
        "SettingsThemeOverrideTagLocation toString should never be called");
    return "";
  }
}
