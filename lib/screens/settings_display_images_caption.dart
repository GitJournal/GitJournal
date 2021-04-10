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

class SettingsDisplayImagesCaptionScreen extends StatefulWidget {
  @override
  SettingsDisplayImagesCaptionScreenState createState() =>
      SettingsDisplayImagesCaptionScreenState();
}

class SettingsDisplayImagesCaptionScreenState
    extends State<SettingsDisplayImagesCaptionScreen> {
  final doNotCaptionTagsKey = GlobalKey<FormFieldState<String>>();
  final doCaptionTagsKey = GlobalKey<FormFieldState<String>>();
  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<Settings>(context);
    var saveDoNotCaptionTag = (String doNotCaptionTags) {
      settings.doNotCaptionTags = parseTags(doNotCaptionTags);
      settings.save();
    };
    var doNotCaptionTagsForm = Form(
      child: TextFormField(
        key: doNotCaptionTagsKey,
        style: Theme.of(context).textTheme.headline6,
        decoration: InputDecoration(
          hintText:
              tr('settings.display.images.captions.doNotCaptionTags.hint'),
          labelText:
              tr('settings.display.images.captions.doNotCaptionTags.label'),
        ),
        validator: (String value) {
          value = value.trim();
          if (parseTags(value).isEmpty) {
            return tr(
                'settings.display.images.captions.doNotCaptionTags.validator.empty');
          }

          if (parseTags(value)
              .intersection(settings.doCaptionTags)
              .isNotEmpty) {
            return tr(
                'settings.display.images.captions.doNotCaptionTags.validator.same');
          }

          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: saveDoNotCaptionTag,
        onSaved: saveDoNotCaptionTag,
        initialValue: csvTags(settings.doNotCaptionTags),
      ),
      onChanged: () {
        if (!doNotCaptionTagsKey.currentState.validate()) return;
        saveDoNotCaptionTag(doNotCaptionTagsKey.currentState.value);
      },
    );

    var saveDoThemeTag = (String doCaptionTags) {
      settings.doCaptionTags = parseTags(doCaptionTags);
      settings.save();
      doNotCaptionTagsForm.createState();
    };
    var doCaptionTagsForm = Form(
      child: TextFormField(
        key: doCaptionTagsKey,
        style: Theme.of(context).textTheme.headline6,
        decoration: InputDecoration(
          hintText: tr('settings.display.images.captions.doCaptionTags.hint'),
          labelText: tr('settings.display.images.captions.doCaptionTags.label'),
        ),
        validator: (String value) {
          if (parseTags(value).isEmpty) {
            return tr(
                'settings.display.images.captions.doCaptionTags.validator.empty');
          }

          if (parseTags(value)
              .intersection(settings.doNotCaptionTags)
              .isNotEmpty) {
            return tr(
                'settings.display.images.captions.doCaptionTags.validator.same');
          }

          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: saveDoThemeTag,
        onSaved: saveDoThemeTag,
        initialValue: csvTags(settings.doCaptionTags),
      ),
      onChanged: () {
        if (!doCaptionTagsKey.currentState.validate()) return;
        saveDoThemeTag(doCaptionTagsKey.currentState.value);
      },
    );

    var body = ListView(children: <Widget>[
      ListPreference(
        title: tr("settings.display.images.captions.useAsCaption"),
        currentOption: settings.useAsCaption.toPublicString(),
        options: SettingsImageTextType.options
            .map((e) => e.toPublicString())
            .toList(),
        onChange: (String publicStr) {
          settings.useAsCaption =
              SettingsImageTextType.fromPublicString(publicStr);
          settings.save();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: Text(tr('settings.display.images.captions.overlayCaption')),
        value: settings.overlayCaption,
        onChanged: (bool newVal) {
          settings.overlayCaption = newVal;
          settings.save();
        },
      ),
      if (settings.overlayCaption)
        SwitchListTile(
          title:
              Text(tr('settings.display.images.captions.transparentCaption')),
          value: settings.transparentCaption,
          onChanged: (bool newVal) {
            settings.transparentCaption = newVal;
            settings.save();
          },
        ),
      if (settings.overlayCaption && settings.transparentCaption)
        SwitchListTile(
          title: Text(tr('settings.display.images.captions.blurBehindCaption')),
          value: settings.blurBehindCaption,
          onChanged: (bool newVal) {
            settings.blurBehindCaption = newVal;
            settings.save();
          },
        ),
      SwitchListTile(
        title: Text(tr('settings.display.images.captions.tooltipFirst.title')),
        value: settings.tooltipFirst,
        subtitle: settings.tooltipFirst
            ? Text(tr('settings.display.images.captions.tooltipFirst.tooltip'))
            : Text(tr('settings.display.images.captions.tooltipFirst.altText')),
        onChanged: (bool newVal) {
          settings.tooltipFirst = newVal;
          settings.save();
        },
      ),
      SettingsHeader(tr('settings.display.images.captions.captionOverrides')),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Text(tr("settings.display.images.captions.tagDescription")),
      ),
      ListTile(title: doCaptionTagsForm),
      ListTile(title: doNotCaptionTagsForm)
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('settings.display.images.captions.title')),
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
