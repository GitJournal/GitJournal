/*
 * SPDX-FileCopyrightText: 2020-2021 Roland Fredenhagen <important@van-fredenhagen.de>
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:universal_io/io.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/markdown_renderer_config.dart';
import 'package:gitjournal/widgets/images/image_caption.dart';
import 'package:gitjournal/widgets/images/image_details.dart';
import 'package:gitjournal/widgets/images/themable_image.dart';

class MarkdownImage extends StatelessWidget {
  final double? width;
  final double? height;
  final String altText;
  final String tooltip;

  // FIXME: Avoid using dynamic!
  final Future<dynamic> data;

  const MarkdownImage._(
      this.data, this.width, this.height, String? altText, String? tooltip)
      : altText = altText ?? "",
        tooltip = tooltip ?? "";

  factory MarkdownImage(Uri uri, String imageDirectory,
      {double? width, double? height, String? altText, String? titel}) {
    final file = ((uri.isScheme("http") || uri.isScheme("https"))
        ? DefaultCacheManager().getSingleFile(uri.toString())
        : Future.sync(
            () => File.fromUri(Uri.parse(imageDirectory + uri.toString()))));

    final data = file.then(
        (value) => value.path.endsWith(".svg") ? value.readAsString() : file);

    return MarkdownImage._(data, width, height, altText, titel);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<MarkdownRendererConfig>(context);
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    // Test for override tags in AltText/Tooltip
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
                  errorMessage = tr(LocaleKeys.widgets_imageRenderer_httpError,
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
                              style: theme.textTheme.bodyText1!
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
                  im = ThemableImage.svg(
                    snapshot.data as String,
                    width: width ?? MediaQuery.of(context).size.width,
                    height: height,
                    themingMethod: override == ThemeOverride.No ||
                            settings.themeVectorGraphics ==
                                    SettingsThemeVectorGraphics.Off &&
                                override != ThemeOverride.Do
                        ? ThemingMethod.none
                        : dark
                            ? settings.themeVectorGraphics ==
                                    SettingsThemeVectorGraphics.Filter
                                ? ThemingMethod.filter
                                : ThemingMethod.invertBrightness
                            : settings.matchCanvasColor
                                ? ThemingMethod.wToBg
                                : ThemingMethod.none,
                    themingCondition: settings.themeSvgWithBackground ||
                            override == ThemeOverride.Do
                        ? ThemingCondition.none
                        : ThemingCondition.noBackground,
                    colorCondition: settings.vectorGraphicsAdjustColors ==
                            SettingsVectorGraphicsAdjustColors.All
                        ? ColorCondition.all
                        : settings.vectorGraphicsAdjustColors ==
                                SettingsVectorGraphicsAdjustColors.BnW
                            ? ColorCondition.bw
                            : ColorCondition.gray,
                    bg: settings.matchCanvasColor
                        ? theme.canvasColor
                        : Colors.black,
                  );
                } else {
                  im = ThemableImage.image(
                    snapshot.data as File,
                    width: width,
                    height: height,
                    doTheme: (settings.themeRasterGraphics ||
                            override == ThemeOverride.Do) &&
                        override != ThemeOverride.No &&
                        dark,
                    bg: theme.canvasColor,
                  );
                }

                return GestureDetector(
                  child: Hero(tag: im, child: im),
                  onTap: () {
                    var _ = Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageDetails(
                          im as ThemableImage,
                          captionText(context, altText, tooltip),
                        ),
                      ),
                    );
                  },
                );
              }

              return SizedBox(
                  width: width,
                  height: height,
                  child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator())));
            });

        if (shouldCaption(context, altText, tooltip)) {
          if (small || !settings.overlayCaption) {
            return Column(
                children: [image, ImageCaption(altText, tooltip, false)]);
          } else {
            return Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [image, ImageCaption(altText, tooltip, true)]);
          }
        }
        return image;
      },
    );
  }
}

Color getOverlayBackgroundColor(BuildContext context,
    {Color? light, Color? dark}) {
  final settings = Provider.of<MarkdownRendererConfig>(context);
  final theme = Theme.of(context);
  return theme.brightness == Brightness.dark
      ? settings.transparentCaption
          ? Colors.black.withAlpha(100)
          : dark ?? theme.canvasColor
      : settings.transparentCaption
          ? Colors.white.withAlpha(100)
          : light ?? theme.canvasColor;
}

enum ThemeOverride { None, Do, No }
