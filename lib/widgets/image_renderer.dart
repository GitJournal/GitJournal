/*
Copyright 2020-2021 Roland Fredenhagen <important@van-fredenhagen.de>

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

import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gitjournal/utils/logger.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils/hero_dialog.dart';

class ThemableImage extends StatelessWidget {
  final double width;
  final double height;
  final String altText;
  final String tooltip;
  final Future<dynamic> data;

  ThemableImage._(this.data, this.width, this.height, altText, tooltip)
      : altText = altText ?? "",
        tooltip = tooltip ?? "";

  factory ThemableImage(Uri uri, String imageDirectory,
      {double width, double height, String altText, String titel}) {
    final file = ((uri.isScheme("http") || uri.isScheme("https"))
        ? DefaultCacheManager().getSingleFile(uri.toString())
        : Future.sync(
            () => File.fromUri(Uri.parse(imageDirectory + uri.toString()))));

    final data = file.then(
        (value) => value.path.endsWith(".svg") ? value.readAsString() : file);

    return ThemableImage._(data, width, height, altText, titel);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<Settings>(context);
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    ThemeOverride override = ThemeOverride.None;
    if (settings.themeOverrideTagLocation == SettingsImageTextType.Alt ||
        settings.themeOverrideTagLocation == SettingsImageTextType.AltTool) {
      if (hasTag(altText, settings.doThemeTags)) {
        override = ThemeOverride.Do;
      } else if (hasTag(altText, settings.doNotThemeTags)) {
        override = ThemeOverride.No;
      }
    }
    if (settings.themeOverrideTagLocation == SettingsImageTextType.Tooltip ||
        settings.themeOverrideTagLocation == SettingsImageTextType.AltTool) {
      if (hasTag(tooltip, settings.doThemeTags)) {
        override = ThemeOverride.Do;
      } else if (hasTag(tooltip, settings.doNotThemeTags)) {
        override = ThemeOverride.No;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final small =
            constraints.maxWidth < MediaQuery.of(context).size.width - 40;
        final image = FutureBuilder(
            future: data,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                String errorMessage = snapshot.error.toString();
                Log.e(errorMessage);
                if (snapshot.error is HttpExceptionWithStatus) {
                  final httpError = snapshot.error as HttpExceptionWithStatus;
                  errorMessage = tr("widgets.imageRenderer.httpError",
                      namedArgs: {
                        "status": httpError.statusCode.toString(),
                        "url": httpError.uri.toString()
                      });
                }
                return SizedBox(
                  width: width,
                  height: height,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error,
                              color: theme.errorColor,
                              size: 36,
                            ),
                            Text(
                              errorMessage,
                              style: theme.textTheme.bodyText1
                                  .copyWith(color: theme.errorColor),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          ]),
                    ),
                  ),
                );
              }

              if (snapshot.hasData) {
                Widget im;
                if (snapshot.data is String) {
                  im = _handleSvg(
                      snapshot.data, width, height, context, override);
                } else {
                  im = Image.file(snapshot.data, width: width, height: height);
                  if ((settings.themeRasterGraphics ||
                          override == ThemeOverride.Do) &&
                      override != ThemeOverride.No &&
                      dark) {
                    im = themeFilter(im, theme.canvasColor);
                  }
                }

                if (small) {
                  return GestureDetector(
                    child: Hero(tag: im, child: im),
                    onTap: () {
                      Navigator.push(
                          context,
                          HeroDialogRoute(
                            builder: (context) => GestureDetector(
                              child: Hero(tag: im, child: im),
                              onTap: () => Navigator.pop(context),
                            ),
                          ));
                    },
                  );
                }

                return im;
              }

              return SizedBox(
                  width: width,
                  height: height,
                  child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator())));
            });

        if (small || !settings.overlayCaption) {
          final caption = _imageCaption(context, altText, tooltip, false);
          return Column(children: [image, if (caption != null) caption]);
        }
        final caption = _imageCaption(context, altText, tooltip, true);
        return Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [image, if (caption != null) caption]);
      },
    );
  }
}

String _cleanCaption(BuildContext context, String caption) {
  final settings = Provider.of<Settings>(context);
  final tags = [
    ...settings.doThemeTags,
    ...settings.doNotThemeTags,
    ...settings.doCaptionTags,
    ...settings.doNotCaptionTags
  ];
  return caption
      .replaceAll(
          RegExp(
              r"\s*(?<=\s|\b)(" +
                  tags.map(RegExp.escape).join("|") +
                  r")(?=\s|\b)\s*",
              caseSensitive: false),
          " ")
      .trim();
}

Widget _imageCaption(
    BuildContext context, String altText, String tooltip, bool overlay) {
  final theme = Theme.of(context);
  final settings = Provider.of<Settings>(context);
  final dark = theme.brightness == Brightness.dark;

  bool altTextCaption =
      settings.useAsCaption == SettingsImageTextType.AltTool ||
          settings.useAsCaption == SettingsImageTextType.AltTool;
  if (hasTag(altText, settings.doCaptionTags)) {
    altTextCaption = true;
  } else if (hasTag(altText, settings.doNotCaptionTags)) {
    altTextCaption = false;
  }

  bool tooltipCaption =
      settings.useAsCaption == SettingsImageTextType.Tooltip ||
          settings.useAsCaption == SettingsImageTextType.AltTool;
  if (hasTag(tooltip, settings.doCaptionTags)) {
    tooltipCaption = true;
  } else if (hasTag(tooltip, settings.doNotCaptionTags)) {
    tooltipCaption = false;
  }

  altText = altTextCaption ? _cleanCaption(context, altText) : "";
  tooltip = tooltipCaption ? _cleanCaption(context, tooltip) : "";
  String text = "";
  if (altText.isNotEmpty && tooltip.isNotEmpty) {
    text = tr("widgets.imageRenderer.caption",
        namedArgs: settings.tooltipFirst
            ? {"first": tooltip, "second": altText}
            : {"first": altText, "second": tooltip});
  } else {
    text = altText + tooltip;
  }

  if (text.isNotEmpty) {
    if (!overlay) {
      return Text(text, style: theme.textTheme.caption);
    }

    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = constraints.constrainWidth(200);
      const padding = 6.0, margin = 4.0, borderRadius = 5.0;
      final blur = settings.blurBehindCaption ? 2.0 : 0.0;

      final overflown = (TextPainter(
              text: TextSpan(text: text),
              maxLines: 2,
              textScaleFactor: MediaQuery.of(context).textScaleFactor,
              textDirection: Directionality.of(context))
            ..layout(maxWidth: maxWidth - 2 * (padding + margin)))
          .didExceedMaxLines;

      final bColor = settings.transparentCaption
          ? (dark ? Colors.black : Colors.white).withAlpha(150)
          : theme.canvasColor;
      final box = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            color: bColor,
            child: Padding(
                padding: const EdgeInsets.all(padding),
                child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyText2,
                )),
          ),
        ),
      );
      if (!overflown) {
        return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(margin: const EdgeInsets.all(margin), child: box));
      }

      final caption = Hero(tag: "caption", child: box);

      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.all(margin),
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, HeroDialogRoute(builder: (context) {
                return Dialog(
                    backgroundColor: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: caption,
                    ));
              }));
            },
            child: caption,
          ),
        ),
      );
    });
  }

  return null;
}

Widget _handleSvg(final String string, double width, final double height,
    final BuildContext context, final ThemeOverride override) {
  final settings = Provider.of<Settings>(context);
  final theme = Theme.of(context);
  width ??= MediaQuery.of(context).size.width;
  final dark = theme.brightness == Brightness.dark;
  if (settings.themeVectorGraphics == SettingsThemeVectorGraphics.Off &&
          override != ThemeOverride.Do ||
      override == ThemeOverride.No) {
    return SvgPicture.string(string, width: width, height: height);
  }
  if (settings.themeVectorGraphics == SettingsThemeVectorGraphics.Filter &&
      dark) {
    return themeFilter(SvgPicture.string(string, width: width, height: height),
        theme.canvasColor);
  }
  final transformColor = dark
      ? themeDark(theme.canvasColor, settings.vectorGraphicsAdjustColors)
      : settings.matchCanvasColor
          ? whiteToCanvas(theme.canvasColor)
          : noTheme;
  return SvgPicture(
    StringPicture((data, colorFilter, key) async {
      DrawableRoot svgRoot = await svg.fromSvgString(data, key);
      if (settings.themeSvgWithBackground ||
          override == ThemeOverride.Do ||
          !hasBackground(svgRoot, svgRoot.viewport.viewBox.width,
              svgRoot.viewport.viewBox.height)) {
        svgRoot = themeDrawable(svgRoot, transformColor);
      }
      final Picture pic = svgRoot.toPicture(
        clipToViewBox: false,
        colorFilter: colorFilter,
      );
      return PictureInfo(
        picture: pic,
        viewport: svgRoot.viewport.viewBoxRect,
        size: svgRoot.viewport.size,
      );
    },
        string +
            '<?theme darkMode="$dark" ' +
            'override="$override" ' +
            'opaqueBackground="${settings.themeSvgWithBackground}" ' +
            'whiteToCanvas="${settings.matchCanvasColor}" ' +
            'adjustColors="${settings.vectorGraphicsAdjustColors.toInternalString()}"?>'),
    width: width,
    height: height,
  );
}

Color Function(Color color) whiteToCanvas(Color canvasColor) =>
    (Color color) => color.value == 0xffffffff ? canvasColor : color;

Color noTheme(Color color) => color;

Color Function(Color color) themeDark(
        Color canvasColor, SettingsVectorGraphicsAdjustColors adjustColors) =>
    (Color color) {
      final hslColor = HSLColor.fromColor(color);
      final backGroundLightness = HSLColor.fromColor(canvasColor).lightness;
      if (adjustColors == SettingsVectorGraphicsAdjustColors.BnW) {
        if (hslColor.lightness > 0.95 && hslColor.saturation < 0.02) {
          return HSLColor.fromAHSL(hslColor.alpha, 0, 0, backGroundLightness)
              .toColor();
        }
        if (hslColor.lightness < 0.02) {
          return HSLColor.fromAHSL(hslColor.alpha, 0, 0, 1).toColor();
        }
        return color;
      }
      if (adjustColors == SettingsVectorGraphicsAdjustColors.Grays) {
        if (hslColor.saturation < 0.02 || hslColor.lightness < 0.02) {
          return HSLColor.fromAHSL(hslColor.alpha, 0, 0,
                  1 - (hslColor.lightness * (1 - backGroundLightness)))
              .toColor();
        }
        return color;
      }

      return HSLColor.fromAHSL(
              hslColor.alpha,
              hslColor.hue,
              hslColor.saturation,
              1 - (hslColor.lightness * (1 - backGroundLightness)))
          .toColor();
    };

bool hasBackground(Drawable draw, double width, double height) {
  if (draw is DrawableShape) {
    final drawShape = draw;
    return drawShape.style.fill != null &&
        drawShape.style.fill.color.alpha > 0.99 &&
        [
          Offset(0 + width * 0.01, 0 + height * 0.01),
          Offset(width - width * 0.01, 0 + height * 0.01),
          Offset(width - width * 0.01, height - height * 0.01),
          Offset(0 + width * 0.01, height - height * 0.01),
        ].every(drawShape.path.contains);
  }
  if (draw is DrawableParent) {
    final drawParent = draw;
    return drawParent.children
        .any((element) => hasBackground(element, width, height));
  }
  return false;
}

bool hasTag(String text, Set<String> tags) {
  return tags
      .map((e) => RegExp(r"(?<=\s|\b)" + RegExp.escape(e) + r"(?=\s|\b)",
          caseSensitive: false))
      .any((e) => e.hasMatch(text));
}

Drawable themeDrawable(
    Drawable draw, Color Function(Color color) transformColor) {
  if (draw is DrawableStyleable && !(draw is DrawableGroup)) {
    final DrawableStyleable drawStylable = draw;
    draw = drawStylable.mergeStyle(DrawableStyle(
        stroke: drawStylable.style.stroke != null &&
                drawStylable.style.stroke.color != null
            ? DrawablePaint.merge(
                DrawablePaint(drawStylable.style.stroke.style,
                    color: transformColor(drawStylable.style.stroke.color)),
                drawStylable.style.stroke)
            : null,
        fill: drawStylable.style.fill != null &&
                drawStylable.style.fill.color != null
            ? DrawablePaint.merge(
                DrawablePaint(drawStylable.style.fill.style,
                    color: transformColor(drawStylable.style.fill.color)),
                drawStylable.style.fill)
            : null));
  }
  if (draw is DrawableParent) {
    final DrawableParent drawParent = draw;
    final children = drawParent.children
        .map((e) => themeDrawable(e, transformColor))
        .toList(growable: false);
    if (draw is DrawableRoot) {
      final DrawableRoot drawRoot = draw;
      draw = DrawableRoot(drawRoot.id, drawRoot.viewport, children,
          drawRoot.definitions, drawRoot.style,
          transform: drawRoot.transform);
    } else if (draw is DrawableGroup) {
      final DrawableGroup drawGroup = draw;
      draw = DrawableGroup(drawGroup.id, children, drawGroup.style,
          transform: drawGroup.transform);
    }
  }
  return draw;
}

Widget themeFilter(Widget widget, Color background) {
  final lightness = (1 - HSLColor.fromColor(background).lightness) * 255;
  // TODO Switch to HSL Filter, when availible (https://github.com/flutter/flutter/issues/76729)
  final stack = ColorFiltered(
      colorFilter: ColorFilter.matrix(<double>[
        -(lightness / 255), 0, 0, 0, 255, // R
        0, -(lightness / 255), 0, 0, 255, // G
        0, 0, -(lightness / 255), 0, 255, // B
        0, 0, 0, 1, 0 // A
      ]),
      child: widget);
  return stack;
}

enum ThemeOverride { None, Do, No }
