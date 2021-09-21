/*
 * SPDX-FileCopyrightText: 2020-2021 Roland Fredenhagen <important@van-fredenhagen.de>
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:universal_io/io.dart';

class ThemableImage extends StatelessWidget {
  final double? width;
  final double? height;
  final File? file;
  final String string;
  final ThemingMethod themingMethod;
  final ThemingCondition themingCondition;
  final ColorCondition colorCondition;
  final Color bg;

  const ThemableImage.image(
    this.file, {
    this.width,
    this.height,
    doTheme = false,
    this.bg = Colors.white,
  })  : string = "",
        themingMethod = doTheme ? ThemingMethod.filter : ThemingMethod.none,
        themingCondition = ThemingCondition.none,
        colorCondition = ColorCondition.all;

  const ThemableImage.svg(
    this.string, {
    this.width,
    this.height,
    this.themingMethod = ThemingMethod.none,
    this.bg = Colors.white,
    this.themingCondition = ThemingCondition.none,
    this.colorCondition = ColorCondition.all,
  }) : file = null;

  ThemableImage.from(
    ThemableImage ti, {
    double? width,
    double? height,
    ThemingMethod? themingMethod,
    ThemingCondition? themingCondition,
    ColorCondition? colorCondition,
    Color? bg,
  })  : file = ti.file,
        string = ti.string,
        width = width ?? ti.width,
        height = height ?? ti.height,
        themingMethod = themingMethod ?? ti.themingMethod,
        themingCondition = themingCondition ?? ti.themingCondition,
        colorCondition = colorCondition ?? ti.colorCondition,
        bg = bg ?? ti.bg;

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (file != null) {
      image = Image.file(file!, width: width, height: height);
    } else if (string.isNotEmpty) {
      image = SvgPicture(
          StringPicture(
              _transformSVG,
              string +
                  '<?theme '
                      'themingMethod="$themingMethod" '
                      'themingCondition="$themingCondition" '
                      'colorCondition="$colorCondition" '
                      'backgroundColor="$bg" '
                      '?>'),
          width: width,
          height: height);
    } else {
      throw Exception("Tried to render an image without File or SVG string");
    }
    return themingMethod == ThemingMethod.filter
        ? _themeFilter(image, bg)
        : image;
  }

  Future<PictureInfo> _transformSVG(data, colorFilter, key) async {
    DrawableRoot svgRoot = await svg.fromSvgString(data, key);
    if (themingCondition != ThemingCondition.noBackground ||
        !_hasBackground(svgRoot, svgRoot.viewport.viewBox.width,
            svgRoot.viewport.viewBox.height) ||
        themingMethod == ThemingMethod.wToBg) {
      svgRoot = _themeDrawable(svgRoot, (Color? color) {
        switch (themingMethod) {
          case ThemingMethod.wToBg:
            return color == Colors.white ? bg : color;

          case ThemingMethod.none:
          case ThemingMethod.filter:
            return color;

          case ThemingMethod.invertBrightness:
            final hslColor = HSLColor.fromColor(color!);
            final backGroundLightness = HSLColor.fromColor(bg).lightness;
            switch (colorCondition) {
              case ColorCondition.all:
                return HSLColor.fromAHSL(
                        hslColor.alpha,
                        hslColor.hue,
                        hslColor.saturation,
                        1 - (hslColor.lightness * (1 - backGroundLightness)))
                    .toColor();

              case ColorCondition.bw:
                if (hslColor.lightness > 0.95 && hslColor.saturation < 0.02) {
                  return HSLColor.fromAHSL(
                          hslColor.alpha, 0, 0, backGroundLightness)
                      .toColor();
                }
                return color;

              case ColorCondition.gray:
                if (hslColor.saturation < 0.02 || hslColor.lightness < 0.02) {
                  return HSLColor.fromAHSL(hslColor.alpha, 0, 0,
                          1 - (hslColor.lightness * (1 - backGroundLightness)))
                      .toColor();
                }
                return color;
            }
        }
      }) as DrawableRoot;
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
  }
}

enum ThemingMethod { none, filter, wToBg, invertBrightness }

enum ThemingCondition { none, noBackground }

enum ColorCondition { all, bw, gray }

/// Tests if the [Drawable] [draw] has a non transparent background
///
/// [width] and [height] specify the area for a drawable to fill to be a valid background.
/// Use [minAlpha] and [maxBorder] to accept imperfect Backgrounds.
/// [maxBorder] is the fraction of the [width]/[height] that does not need to be filled.
/// Use [maxDepth] to controll how deep the Tree is traversed to find a background,
/// `maxDepth = -1` will traverse the whole Tree.
bool _hasBackground(Drawable draw, double width, double height,
    {minAlpha = 0.99, maxBorder = 0.01, maxDepth = 10}) {
  if (maxDepth == 0) {
    if (draw is DrawableShape) {
      final drawShape = draw;
      return drawShape.style.fill != null &&
          drawShape.style.fill!.color!.alpha > minAlpha &&
          [
            Offset(width * maxBorder, height * maxBorder),
            Offset(width - width * maxBorder, height * maxBorder),
            Offset(width - width * maxBorder, height - height * maxBorder),
            Offset(width * maxBorder, height - height * maxBorder),
          ].every(drawShape.path.contains);
    }
    // TODO Allow for two shapes to be the background together
    if (draw is DrawableParent) {
      final drawParent = draw;
      return drawParent.children!.any((element) => _hasBackground(
          element, width, height,
          minAlpha: minAlpha, maxBorder: maxBorder, maxDepth: maxDepth - 1));
    }
  }
  return false;
}

Drawable _themeDrawable(
    Drawable draw, Color? Function(Color? color) transformColor) {
  if (draw is DrawableStyleable && draw is! DrawableGroup) {
    final DrawableStyleable drawStylable = draw;
    draw = drawStylable.mergeStyle(DrawableStyle(
        stroke: drawStylable.style!.stroke != null &&
                drawStylable.style!.stroke!.color != null
            ? DrawablePaint.merge(
                DrawablePaint(drawStylable.style!.stroke!.style,
                    color: transformColor(drawStylable.style!.stroke!.color)),
                drawStylable.style!.stroke)
            : null,
        fill: drawStylable.style!.fill != null &&
                drawStylable.style!.fill!.color != null
            ? DrawablePaint.merge(
                DrawablePaint(drawStylable.style!.fill!.style,
                    color: transformColor(drawStylable.style!.fill!.color)),
                drawStylable.style!.fill)
            : null));
  }
  if (draw is DrawableParent) {
    final DrawableParent drawParent = draw;
    final children = drawParent.children!
        .map((e) => _themeDrawable(e, transformColor))
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

Widget _themeFilter(Widget widget, Color background) {
  final lightness = (1 - HSLColor.fromColor(background).lightness) * 255;
  // TODO Switch to HSL Filter, when available (https://github.com/flutter/flutter/issues/76729)
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
