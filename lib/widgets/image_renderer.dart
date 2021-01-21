import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/settings.dart';
import 'package:gitjournal/widgets/blend_mask.dart';

class ThemableImage extends StatelessWidget {
  final double width;
  final double height;
  final String altText;
  final String tooltip;
  final Future<dynamic> data;

  ThemableImage._(
      this.data, this.width, this.height, this.altText, this.tooltip);

  factory ThemableImage(Uri uri, String imageDirectory,
      {double width, double height, String altText, String titel}) {
    final file = ((uri.isScheme('http') || uri.isScheme('https'))
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
    ThemeOverride override;
    if (altText != null &&
        (settings.themeOverrideTagLocation ==
                SettingsThemeOverrideTagLocation.Alt ||
            settings.themeOverrideTagLocation ==
                SettingsThemeOverrideTagLocation.AltTool)) {
      if (altText.toLowerCase().contains(settings.doThemeTag.toLowerCase())) {
        override = ThemeOverride.doTheme;
      } else if (altText
          .toLowerCase()
          .contains(settings.doNotThemeTag.toLowerCase())) {
        override = ThemeOverride.noTheme;
      }
    }
    if (tooltip != null &&
        (settings.themeOverrideTagLocation ==
                SettingsThemeOverrideTagLocation.Tooltip ||
            settings.themeOverrideTagLocation ==
                SettingsThemeOverrideTagLocation.AltTool)) {
      if (tooltip.toLowerCase().contains(settings.doThemeTag.toLowerCase())) {
        override = ThemeOverride.doTheme;
      } else if (tooltip
          .toLowerCase()
          .contains(settings.doNotThemeTag.toLowerCase())) {
        override = ThemeOverride.noTheme;
      }
    }
    return FutureBuilder(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Icon(Icons.error, color: Theme.of(context).errorColor);
            } else if (snapshot.hasData) {
              if (snapshot.data is String) {
                return _handleSvg(
                    snapshot.data, width, height, context, override);
              } else {
                if ((override != ThemeOverride.noTheme &&
                            settings.themeRasterGraphics ||
                        override == ThemeOverride.doTheme) &&
                    theme.brightness == Brightness.dark) {
                  return themeFilter(
                      Image.file(snapshot.data, width: width, height: height),
                      theme.canvasColor);
                } else {
                  return Image.file(snapshot.data,
                      width: width, height: height);
                }
              }
            }
          }
          return const CircularProgressIndicator();
        });
  }
}

Widget _handleSvg(final String string, double width, final double height,
    final BuildContext context, final ThemeOverride override) {
  final settings = Provider.of<Settings>(context);
  final theme = Theme.of(context);
  width ??= MediaQuery.of(context).size.width;
  final dark = theme.brightness == Brightness.dark;
  if (settings.themeVectorGraphics == SettingsThemeVectorGraphics.Off &&
          override != ThemeOverride.doTheme ||
      override == ThemeOverride.noTheme) {
    return SvgPicture.string(string, width: width, height: height);
  }
  if (settings.themeVectorGraphics == SettingsThemeVectorGraphics.Filter) {
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
  return Stack(children: [
    ColorFiltered(
        colorFilter: ColorFilter.matrix(<double>[
          -(lightness / 255), 0, 0, 0, 255, // R
          0, -(lightness / 255), 0, 0, 255, // G
          0, 0, -(lightness / 255), 0, 255, // B
          0, 0, 0, 1, 0 // A
        ]),
        child: widget),
    BlendMask(blendMode: BlendMode.color, child: widget)
  ]);
}

enum ThemeOverride { none, doTheme, noTheme }
