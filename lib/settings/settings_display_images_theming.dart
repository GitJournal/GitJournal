/*
 * SPDX-FileCopyrightText: 2020-2021 Roland Fredenhagen <important@van-fredenhagen.de>
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/settings/markdown_renderer_config.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/widgets/settings_header.dart';
import 'package:gitjournal/settings/widgets/settings_list_preference.dart';

class SettingsDisplayImagesThemingScreen extends StatefulWidget {
  @override
  SettingsDisplayImagesThemingScreenState createState() =>
      SettingsDisplayImagesThemingScreenState();
}

class SettingsDisplayImagesThemingScreenState
    extends State<SettingsDisplayImagesThemingScreen> {
  final doNotThemeTagsKey = GlobalKey<FormFieldState<String>>();
  final doThemeTagsKey = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<MarkdownRendererConfig>(context);

    void saveDoNotThemeTag(String? doNotThemeTags) {
      settings.doNotThemeTags = parseTags(doNotThemeTags!);
      settings.save();
    }

    var doNotThemeTagsForm = Form(
      child: TextFormField(
        key: doNotThemeTagsKey,
        style: Theme.of(context).textTheme.headline6,
        decoration: InputDecoration(
          hintText:
              tr(LocaleKeys.settings_display_images_theming_doThemeTags_hint),
          labelText:
              tr(LocaleKeys.settings_display_images_theming_doThemeTags_label),
        ),
        validator: (String? value) {
          value = value!.trim();
          if (parseTags(value).isEmpty) {
            return tr(LocaleKeys
                .settings_display_images_theming_doThemeTags_validator_empty);
          }

          if (parseTags(value).intersection(settings.doThemeTags).isNotEmpty) {
            return tr(LocaleKeys
                .settings_display_images_theming_doThemeTags_validator_same);
          }

          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: saveDoNotThemeTag,
        onSaved: saveDoNotThemeTag,
        initialValue: csvTags(settings.doNotThemeTags),
      ),
      onChanged: () {
        if (!doNotThemeTagsKey.currentState!.validate()) return;
        saveDoNotThemeTag(doNotThemeTagsKey.currentState!.value);
      },
    );

    void saveDoThemeTag(String? doThemeTags) {
      settings.doThemeTags = parseTags(doThemeTags!);
      settings.save();
    }

    var doThemeTagsForm = Form(
      child: TextFormField(
        key: doThemeTagsKey,
        style: Theme.of(context).textTheme.headline6,
        decoration: InputDecoration(
          hintText:
              tr(LocaleKeys.settings_display_images_theming_doThemeTags_hint),
          labelText:
              tr(LocaleKeys.settings_display_images_theming_doThemeTags_label),
        ),
        validator: (String? value) {
          if (parseTags(value!).isEmpty) {
            return tr(LocaleKeys
                .settings_display_images_theming_doThemeTags_validator_empty);
          }

          if (parseTags(value)
              .intersection(settings.doNotThemeTags)
              .isNotEmpty) {
            return tr(LocaleKeys
                .settings_display_images_theming_doThemeTags_validator_same);
          }

          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: saveDoThemeTag,
        onSaved: saveDoThemeTag,
        initialValue: csvTags(settings.doThemeTags),
      ),
      onChanged: () {
        if (!doThemeTagsKey.currentState!.validate()) return;
        saveDoThemeTag(doThemeTagsKey.currentState!.value);
      },
    );
    var body = ListView(children: <Widget>[
      SwitchListTile(
        title: Text(tr('settings.display.images.theming.themeRasterGraphics')),
        value: settings.themeRasterGraphics,
        onChanged: (bool newVal) {
          settings.themeRasterGraphics = newVal;
          settings.save();
        },
      ),
      SettingsHeader(tr('settings.display.images.theming.themeOverrides')),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Text(tr("settings.display.images.theming.tagDescription")),
      ),
      ListPreference(
        title: tr("settings.display.images.theming.themeOverrideTagLocation"),
        currentOption: settings.themeOverrideTagLocation.toPublicString(),
        options: SettingsImageTextType.options
            .map((e) => e.toPublicString())
            .toList(),
        onChange: (String publicStr) {
          settings.themeOverrideTagLocation =
              SettingsImageTextType.fromPublicString(publicStr);
          settings.save();
          setState(() {});
        },
      ),
      ListTile(title: doThemeTagsForm),
      ListTile(title: doNotThemeTagsForm),
      SettingsHeader(tr('settings.display.images.theming.vectorGraphics')),
      ListPreference(
        title: tr("settings.display.images.theming.themeVectorGraphics.title"),
        currentOption: settings.themeVectorGraphics.toPublicString(),
        options: SettingsThemeVectorGraphics.options
            .map((e) => e.toPublicString())
            .toList(),
        onChange: (String publicStr) {
          settings.themeVectorGraphics =
              SettingsThemeVectorGraphics.fromPublicString(publicStr);
          settings.save();
          setState(() {});
        },
      ),
      if (settings.themeVectorGraphics == SettingsThemeVectorGraphics.On)
        SwitchListTile(
          title: Text(
              tr('settings.display.images.theming.themeSvgWithBackground')),
          value: settings.themeSvgWithBackground,
          onChanged: (bool newVal) {
            settings.themeSvgWithBackground = newVal;
            settings.save();
          },
        ),
      if (settings.themeVectorGraphics == SettingsThemeVectorGraphics.On)
        SwitchListTile(
          title: Text(
              tr('settings.display.images.theming.matchCanvasColor.title')),
          subtitle: Text(
              tr('settings.display.images.theming.matchCanvasColor.subtitle')),
          value: settings.matchCanvasColor,
          onChanged: (bool newVal) {
            settings.matchCanvasColor = newVal;
            settings.save();
          },
        ),
      if (settings.themeVectorGraphics == SettingsThemeVectorGraphics.On)
        ListPreference(
          title:
              tr("settings.display.images.theming.vectorGraphicsAdjustColors"),
          currentOption: settings.vectorGraphicsAdjustColors.toPublicString(),
          options: SettingsVectorGraphicsAdjustColors.options
              .map((e) => e.toPublicString())
              .toList(),
          onChange: (String publicStr) {
            settings.vectorGraphicsAdjustColors =
                SettingsVectorGraphicsAdjustColors.fromPublicString(publicStr);
            settings.save();
            setState(() {});
          },
        ),
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(LocaleKeys.settings_display_images_theming_title)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: body,
    );
  }
}
