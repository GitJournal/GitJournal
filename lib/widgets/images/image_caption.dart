/*
 * SPDX-FileCopyrightText: 2020-2021 Roland Fredenhagen <important@van-fredenhagen.de>
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/settings/markdown_renderer_config.dart';
import 'package:gitjournal/utils/hero_dialog.dart';

class ImageCaption extends StatelessWidget {
  final String altText;
  final String tooltip;
  final bool overlay;
  const ImageCaption(this.altText, this.tooltip, this.overlay);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = Provider.of<MarkdownRendererConfig>(context);

    final text = captionText(context, altText, tooltip);

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

      final box = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            color: _overlayBackgroundColor(context),
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
              var _ = Navigator.push(
                context,
                HeroDialogRoute(builder: (context) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: caption,
                    ),
                  );
                }),
              );
            },
            child: caption,
          ),
        ),
      );
    });
  }
}

bool hasTag(String text, Set<String> tags) {
  return tags
      .map((e) => RegExp(r"(?<=^|\s|\b)" + RegExp.escape(e) + r"(?=$|\s|\b)",
          caseSensitive: false))
      .any((e) => e.hasMatch(text));
}

bool shouldCaption(BuildContext context, String altText, String tooltip) {
  return captionText(context, altText, tooltip).isNotEmpty;
}

String captionText(BuildContext context, String altText, String tooltip) {
  final settings = Provider.of<MarkdownRendererConfig>(context);

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

  String _altText = altTextCaption ? _cleanCaption(context, altText) : "";
  String _tooltip = tooltipCaption ? _cleanCaption(context, tooltip) : "";
  String text = "";
  if (_altText.isNotEmpty && _tooltip.isNotEmpty) {
    text = tr(LocaleKeys.widgets_imageRenderer_caption,
        namedArgs: settings.tooltipFirst
            ? {"first": _tooltip, "second": _altText}
            : {"first": _altText, "second": _tooltip});
  } else {
    text = _altText + _tooltip;
  }

  return text;
}

String _cleanCaption(BuildContext context, String caption) {
  final settings = Provider.of<MarkdownRendererConfig>(context);
  final tags = [
    ...settings.doThemeTags,
    ...settings.doNotThemeTags,
    ...settings.doCaptionTags,
    ...settings.doNotCaptionTags
  ];
  return caption
      .replaceAll(
          RegExp(
              r"\s*(?<=^|\s|\b)(" +
                  tags.map(RegExp.escape).join("|") +
                  r")(?=$|\s|\b)\s*",
              caseSensitive: false),
          " ")
      .trim();
}

Color _overlayBackgroundColor(context) {
  final settings = Provider.of<MarkdownRendererConfig>(context);
  final theme = Theme.of(context);
  return settings.transparentCaption
      ? (theme.brightness == Brightness.dark ? Colors.black : Colors.white)
          .withAlpha(100)
      : theme.canvasColor;
}
