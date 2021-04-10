// @dart=2.9

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

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/screens/settings_screen.dart';
import 'package:gitjournal/screens/settings_widgets.dart';
import 'package:gitjournal/settings.dart';

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
    var settings = Provider.of<Settings>(context);

    var saveDoNotThemeTag = (String doNotThemeTags) {
      settings.doNotThemeTags = parseTags(doNotThemeTags);
      settings.save();
    };
    var doNotThemeTagsForm = Form(
      child: TextFormField(
        key: doNotThemeTagsKey,
        style: Theme.of(context).textTheme.headline6,
        decoration: InputDecoration(
          hintText: tr('settings.display.images.theming.doNotThemeTags.hint'),
          labelText: tr('settings.display.images.theming.doNotThemeTags.label'),
        ),
        validator: (String value) {
          value = value.trim();
          if (parseTags(value).isEmpty) {
            return tr(
                'settings.display.images.theming.doNotThemeTags.validator.empty');
          }

          if (parseTags(value).intersection(settings.doThemeTags).isNotEmpty) {
            return tr(
                'settings.display.images.theming.doNotThemeTags.validator.same');
          }

          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: saveDoNotThemeTag,
        onSaved: saveDoNotThemeTag,
        initialValue: csvTags(settings.doNotThemeTags),
      ),
      onChanged: () {
        if (!doNotThemeTagsKey.currentState.validate()) return;
        saveDoNotThemeTag(doNotThemeTagsKey.currentState.value);
      },
    );

    var saveDoThemeTag = (String doThemeTags) {
      settings.doThemeTags = parseTags(doThemeTags);
      settings.save();
    };
    var doThemeTagsForm = Form(
      child: TextFormField(
        key: doThemeTagsKey,
        style: Theme.of(context).textTheme.headline6,
        decoration: InputDecoration(
          hintText: tr('settings.display.images.theming.doThemeTags.hint'),
          labelText: tr('settings.display.images.theming.doThemeTags.label'),
        ),
        validator: (String value) {
          if (parseTags(value).isEmpty) {
            return tr(
                'settings.display.images.theming.doThemeTags.validator.empty');
          }

          if (parseTags(value)
              .intersection(settings.doNotThemeTags)
              .isNotEmpty) {
            return tr(
                'settings.display.images.theming.doThemeTags.validator.same');
          }

          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: saveDoThemeTag,
        onSaved: saveDoThemeTag,
        initialValue: csvTags(settings.doThemeTags),
      ),
      onChanged: () {
        if (!doThemeTagsKey.currentState.validate()) return;
        saveDoThemeTag(doThemeTagsKey.currentState.value);
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
        title: Text(tr('settings.display.images.theming.title')),
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
