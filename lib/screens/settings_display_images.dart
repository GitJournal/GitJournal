import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/screens/settings_widgets.dart';
import 'package:gitjournal/screens/settings_screen.dart';
import 'package:gitjournal/settings.dart';

class SettingsDisplayImagesScreen extends StatefulWidget {
  @override
  SettingsDisplayImagesScreenState createState() =>
      SettingsDisplayImagesScreenState();
}

class SettingsDisplayImagesScreenState
    extends State<SettingsDisplayImagesScreen> {
  final doNotThemeTagKey = GlobalKey<FormFieldState<String>>();
  final doThemeTagKey = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<Settings>(context);

    var saveDoNotThemeTag = (String doNotThemeTag) {
      settings.doNotThemeTag = doNotThemeTag;
      settings.save();
    };
    var doNotThemeTagForm = Form(
      child: TextFormField(
        key: doNotThemeTagKey,
        style: Theme.of(context).textTheme.headline6,
        decoration: InputDecoration(
          hintText: tr('settings.display.images.doNotThemeTag.hint'),
          labelText: tr('settings.display.images.doNotThemeTag.label'),
        ),
        validator: (String value) {
          value = value.trim();
          if (value.isEmpty) {
            return tr('settings.display.images.doNotThemeTag.validator.empty');
          }

          if (value == settings.doThemeTag) {
            return tr('settings.display.images.doNotThemeTag.validator.same');
          }

          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: saveDoNotThemeTag,
        onSaved: saveDoNotThemeTag,
        initialValue: settings.doNotThemeTag,
      ),
      onChanged: () {
        if (!doNotThemeTagKey.currentState.validate()) return;
        var gitAuthorEmail = doNotThemeTagKey.currentState.value;
        saveDoNotThemeTag(gitAuthorEmail);
      },
    );

    var saveDoThemeTag = (String doThemeTag) {
      settings.doThemeTag = doThemeTag;
      settings.save();
    };
    var doThemeTagForm = Form(
      child: TextFormField(
        key: doThemeTagKey,
        style: Theme.of(context).textTheme.headline6,
        decoration: InputDecoration(
          hintText: tr('settings.display.images.doThemeTag.hint'),
          labelText: tr('settings.display.images.doThemeTag.label'),
        ),
        validator: (String value) {
          value = value.trim();
          if (value.isEmpty) {
            return tr('settings.display.images.doThemeTag.validator.empty');
          }

          if (value == settings.doNotThemeTag) {
            return tr('settings.display.images.doThemeTag.validator.same');
          }

          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: saveDoThemeTag,
        onSaved: saveDoThemeTag,
        initialValue: settings.doThemeTag,
      ),
      onChanged: () {
        if (!doThemeTagKey.currentState.validate()) return;
        var gitAuthorEmail = doThemeTagKey.currentState.value;
        saveDoThemeTag(gitAuthorEmail);
      },
    );
    var body = ListView(children: <Widget>[
      SwitchListTile(
        title: Text(tr('settings.display.images.themeRasterGraphics')),
        value: settings.themeRasterGraphics,
        onChanged: (bool newVal) {
          settings.themeRasterGraphics = newVal;
          settings.save();
        },
      ),
      SettingsHeader(tr('settings.display.images.themeOverrides')),
      ListPreference(
        title: tr("settings.display.images.themeOverrideTagLocation.title"),
        currentOption: settings.themeOverrideTagLocation.toPublicString(),
        options: SettingsThemeOverrideTagLocation.options
            .map((e) => e.toPublicString())
            .toList(),
        onChange: (String publicStr) {
          settings.themeOverrideTagLocation =
              SettingsThemeOverrideTagLocation.fromPublicString(publicStr);
          settings.save();
          setState(() {});
        },
      ),
      ListTile(title: doThemeTagForm),
      ListTile(title: doNotThemeTagForm),
      SettingsHeader(tr('settings.display.images.vectorGraphics')),
      ListPreference(
        title: tr("settings.display.images.themeVectorGraphics.title"),
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
          title: Text(tr('settings.display.images.themeSvgWithBackground')),
          value: settings.themeSvgWithOpaqueBackground,
          onChanged: (bool newVal) {
            settings.themeSvgWithOpaqueBackground = newVal;
            settings.save();
          },
        ),
      if (settings.themeVectorGraphics == SettingsThemeVectorGraphics.On)
        SwitchListTile(
          title: Text(tr('settings.display.images.matchCanvasColor.title')),
          subtitle:
              Text(tr('settings.display.images.matchCanvasColor.subtitle')),
          value: settings.matchCanvasColor,
          onChanged: (bool newVal) {
            settings.matchCanvasColor = newVal;
            settings.save();
          },
        ),
      if (settings.themeVectorGraphics == SettingsThemeVectorGraphics.On)
        ListPreference(
          title: tr("settings.display.images.vectorGraphicsAdjustColors"),
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
        title: Text(tr('settings.display.images.title')),
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
