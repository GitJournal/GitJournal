/*
Copyright 2020-2021 Vishesh Handa <me@vhanda.in>
                    Roland Fredenhagen <important@van-fredenhagen.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import 'package:flutter/foundation.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/settings/settings_sharedpref.dart';

class MarkdownRendererSettings extends ChangeNotifier with SettingsSharedPref {
  MarkdownRendererSettings(this.id);

  @override
  final String id;

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

  void load(SharedPreferences pref) {
    // Display - Image
    rotateImageGestures =
        getBool(pref, "rotateImageGestures") ?? rotateImageGestures;
    maxImageZoom = getDouble(pref, "maxImageZoom") ?? maxImageZoom;

    // Display - Image - Theming
    themeRasterGraphics =
        getBool(pref, "themeRasterGraphics") ?? themeRasterGraphics;
    themeOverrideTagLocation = SettingsImageTextType.fromInternalString(
        getString(pref, "themeOverrideTagLocation"));
    doNotThemeTags = getStringSet(pref, "doNotThemeTags") ?? doNotThemeTags;
    doThemeTags = getStringSet(pref, "doThemeTags") ?? doThemeTags;
    themeVectorGraphics = SettingsThemeVectorGraphics.fromInternalString(
        getString(pref, "themeVectorGraphics"));
    themeSvgWithBackground =
        getBool(pref, "themeSvgWithBackground") ?? themeSvgWithBackground;
    matchCanvasColor = getBool(pref, "matchCanvasColor") ?? matchCanvasColor;
    vectorGraphicsAdjustColors =
        SettingsVectorGraphicsAdjustColors.fromInternalString(
            getString(pref, "vectorGraphicsAdjustColors"));

    // Display - Image - Caption
    overlayCaption = getBool(pref, "overlayCaption") ?? overlayCaption;
    transparentCaption =
        getBool(pref, "transparentCaption") ?? transparentCaption;
    blurBehindCaption = getBool(pref, "blurBehindCaption") ?? blurBehindCaption;
    tooltipFirst = getBool(pref, "tooltipFirst") ?? tooltipFirst;
    useAsCaption = SettingsImageTextType.fromInternalString(
        getString(pref, "useAsCaption"));
    doNotCaptionTags =
        getStringSet(pref, "doNotCaptionTag") ?? doNotCaptionTags;
    doCaptionTags = getStringSet(pref, "doCaptionTag") ?? doCaptionTags;
  }

  Future<void> save() async {
    var pref = await SharedPreferences.getInstance();
    var defaultSet = MarkdownRendererSettings(id);

    // Display - Image
    await setBool(pref, "rotateImageGestures", rotateImageGestures,
        defaultSet.rotateImageGestures);
    await setDouble(
        pref, "maxImageZoom", maxImageZoom, defaultSet.maxImageZoom);

    // Display - Image - Theme
    await setBool(pref, "themeRasterGraphics", themeRasterGraphics,
        defaultSet.themeRasterGraphics);
    await setString(
        pref,
        "themeOverrideTagLocation",
        themeOverrideTagLocation.toInternalString(),
        defaultSet.themeOverrideTagLocation.toInternalString());
    await setStringSet(
        pref, "doNotThemeTags", doNotThemeTags, defaultSet.doNotThemeTags);
    await setStringSet(
        pref, "doThemeTags", doThemeTags, defaultSet.doThemeTags);
    await setString(
        pref,
        "themeVectorGraphics",
        themeVectorGraphics.toInternalString(),
        defaultSet.themeVectorGraphics.toInternalString());
    await setBool(pref, "themeSvgWithBackground", themeSvgWithBackground,
        defaultSet.themeSvgWithBackground);
    await setBool(pref, "matchCanvasColor", matchCanvasColor,
        defaultSet.matchCanvasColor);
    await setString(
        pref,
        "vectorGraphicsAdjustColors",
        vectorGraphicsAdjustColors.toInternalString(),
        defaultSet.vectorGraphicsAdjustColors.toInternalString());

    // Display - Image - Caption
    await setBool(
        pref, "overlayCaption", overlayCaption, defaultSet.overlayCaption);
    await setBool(pref, "transparentCaption", transparentCaption,
        defaultSet.transparentCaption);
    await setBool(pref, "blurBehindCaption", blurBehindCaption,
        defaultSet.blurBehindCaption);
    await setBool(pref, "tooltipFirst", tooltipFirst, defaultSet.tooltipFirst);
    await setString(pref, "useAsCaption", useAsCaption.toInternalString(),
        defaultSet.useAsCaption.toInternalString());
    await setStringSet(
        pref, "doNotCaptionTag", doNotCaptionTags, defaultSet.doNotCaptionTags);
    await setStringSet(
        pref, "doCaptionTag", doCaptionTags, defaultSet.doCaptionTags);
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
