/*
 * SPDX-FileCopyrightText: 2020-2021 Roland Fredenhagen <important@van-fredenhagen.de>
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/markdown_renderer_config.dart';
import 'package:gitjournal/widgets/images/image_caption.dart';
import 'package:gitjournal/widgets/images/image_details.dart';
import 'package:gitjournal/widgets/images/themable_image.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:universal_io/io.dart';

class MarkdownImage extends StatelessWidget {
  final double? width;
  final double? height;
  final double widthFactor;
  final String altText;
  final String tooltip;

  // FIXME: Avoid using dynamic!
  final Future<dynamic> data;

  const MarkdownImage._(this.data, this.width, this.height, this.widthFactor,
      String? altText, String? tooltip)
      : altText = altText ?? "",
        tooltip = tooltip ?? "";

  factory MarkdownImage(Uri uri, String imageDirectory,
      {double? width, double? height, String? altText, String? titel}) {
    final imageUri = uri.fragment.isEmpty ? uri : uri.replace(fragment: '');
    final widthFactor =
        _parseWidthFactor(titel) ?? _parseWidthFactor(uri.fragment) ?? 1.0;
    final file = ((imageUri.isScheme("http") || imageUri.isScheme("https"))
        ? DefaultCacheManager().getSingleFile(imageUri.toString())
        : Future.sync(() => File(p.join(imageDirectory, imageUri.path))));

    final data = file.then(
        (value) => value.path.endsWith(".svg") ? value.readAsString() : file);

    return MarkdownImage._(
      data,
      width,
      height,
      widthFactor,
      altText,
      titel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<MarkdownRendererConfig>();
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
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final effectiveWidth = width ?? maxWidth * widthFactor;
        final image = FutureBuilder(
            future: data,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                String errorMessage = snapshot.error.toString();
                Log.e(errorMessage);
                if (snapshot.error is HttpExceptionWithStatus) {
                  final httpError = snapshot.error as HttpExceptionWithStatus;
                  errorMessage = context.loc.widgetsImageRendererHttpError(
                      httpError.statusCode.toString(),
                      httpError.uri.toString());
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
                              color: theme.colorScheme.error,
                              size: 36,
                            ),
                            Text(
                              errorMessage,
                              style: theme.textTheme.bodyLarge!
                                  .copyWith(color: theme.colorScheme.error),
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
                    width: effectiveWidth,
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
                    width: effectiveWidth,
                    height: height,
                    doTheme: (settings.themeRasterGraphics ||
                            override == ThemeOverride.Do) &&
                        override != ThemeOverride.No &&
                        dark,
                    bg: theme.canvasColor,
                  );
                }

                return GestureDetector(
                  child: im,
                  onTap: () {
                    Navigator.push(
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

Color getOverlayBackgroundColor(
    MarkdownRendererConfig settings, ThemeData theme,
    {Color? light, Color? dark}) {
  return theme.brightness == Brightness.dark
      ? settings.transparentCaption
          ? Colors.black.withAlpha(100)
          : dark ?? theme.canvasColor
      : settings.transparentCaption
          ? Colors.white.withAlpha(100)
          : light ?? theme.canvasColor;
}

enum ThemeOverride { None, Do, No }

double? _parseWidthFactor(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  var normalized = value.trim();
  if (normalized.endsWith('%')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }

  final parsedSize = int.tryParse(normalized);
  if (parsedSize == null) {
    return null;
  }

  if (parsedSize == 25 ||
      parsedSize == 50 ||
      parsedSize == 75 ||
      parsedSize == 100) {
    return parsedSize / 100;
  }

  return null;
}
