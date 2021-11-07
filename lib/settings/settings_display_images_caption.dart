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
    var settings = Provider.of<MarkdownRendererConfig>(context);
    void saveDoNotCaptionTag(String? doNotCaptionTags) {
      if (doNotCaptionTags == null) {
        return;
      }
      settings.doNotCaptionTags = parseTags(doNotCaptionTags);
      settings.save();
    }

    var doNotCaptionTagsForm = Form(
      child: TextFormField(
        key: doNotCaptionTagsKey,
        style: Theme.of(context).textTheme.headline6,
        decoration: InputDecoration(
          hintText: tr(
              LocaleKeys.settings_display_images_captions_doCaptionTags_hint),
          labelText: tr(
              LocaleKeys.settings_display_images_captions_doCaptionTags_label),
        ),
        validator: (String? value) {
          value = value!.trim();
          if (parseTags(value).isEmpty) {
            return tr(LocaleKeys
                .settings_display_images_captions_doCaptionTags_validator_empty);
          }

          if (parseTags(value)
              .intersection(settings.doCaptionTags)
              .isNotEmpty) {
            return tr(LocaleKeys
                .settings_display_images_captions_doCaptionTags_validator_same);
          }

          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: saveDoNotCaptionTag,
        onSaved: saveDoNotCaptionTag,
        initialValue: csvTags(settings.doNotCaptionTags),
      ),
      onChanged: () {
        if (!doNotCaptionTagsKey.currentState!.validate()) return;
        saveDoNotCaptionTag(doNotCaptionTagsKey.currentState!.value);
      },
    );

    var saveDoThemeTag = (String? doCaptionTags) {
      if (doCaptionTags == null) {
        return;
      }
      settings.doCaptionTags = parseTags(doCaptionTags);
      settings.save();
      var _ = doNotCaptionTagsForm.createState();
    };
    var doCaptionTagsForm = Form(
      child: TextFormField(
        key: doCaptionTagsKey,
        style: Theme.of(context).textTheme.headline6,
        decoration: InputDecoration(
          hintText: tr(
              LocaleKeys.settings_display_images_captions_doCaptionTags_hint),
          labelText: tr(
              LocaleKeys.settings_display_images_captions_doCaptionTags_label),
        ),
        validator: (String? value) {
          if (parseTags(value!).isEmpty) {
            return tr(LocaleKeys
                .settings_display_images_captions_doCaptionTags_validator_empty);
          }

          if (parseTags(value)
              .intersection(settings.doNotCaptionTags)
              .isNotEmpty) {
            return tr(LocaleKeys
                .settings_display_images_captions_doCaptionTags_validator_same);
          }

          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: saveDoThemeTag,
        onSaved: saveDoThemeTag,
        initialValue: csvTags(settings.doCaptionTags),
      ),
      onChanged: () {
        if (!doCaptionTagsKey.currentState!.validate()) return;
        saveDoThemeTag(doCaptionTagsKey.currentState!.value);
      },
    );

    var body = ListView(children: <Widget>[
      ListPreference(
        title: tr(LocaleKeys.settings_display_images_captions_useAsCaption),
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
        title: Text(
            tr(LocaleKeys.settings_display_images_captions_overlayCaption)),
        value: settings.overlayCaption,
        onChanged: (bool newVal) {
          settings.overlayCaption = newVal;
          settings.save();
        },
      ),
      if (settings.overlayCaption)
        SwitchListTile(
          title: Text(tr(
              LocaleKeys.settings_display_images_captions_transparentCaption)),
          value: settings.transparentCaption,
          onChanged: (bool newVal) {
            settings.transparentCaption = newVal;
            settings.save();
          },
        ),
      if (settings.overlayCaption && settings.transparentCaption)
        SwitchListTile(
          title: Text(tr(
              LocaleKeys.settings_display_images_captions_blurBehindCaption)),
          value: settings.blurBehindCaption,
          onChanged: (bool newVal) {
            settings.blurBehindCaption = newVal;
            settings.save();
          },
        ),
      SwitchListTile(
        title: Text(
            tr(LocaleKeys.settings_display_images_captions_tooltipFirst_title)),
        value: settings.tooltipFirst,
        subtitle: settings.tooltipFirst
            ? Text(tr(LocaleKeys
                .settings_display_images_captions_tooltipFirst_tooltip))
            : Text(tr(LocaleKeys
                .settings_display_images_captions_tooltipFirst_altText)),
        onChanged: (bool newVal) {
          settings.tooltipFirst = newVal;
          settings.save();
        },
      ),
      SettingsHeader(
        tr(LocaleKeys.settings_display_images_captions_captionOverrides),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Text(
            tr(LocaleKeys.settings_display_images_captions_tagDescription)),
      ),
      ListTile(title: doCaptionTagsForm),
      ListTile(title: doNotCaptionTagsForm)
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(LocaleKeys.settings_display_images_captions_title)),
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
