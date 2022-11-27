/*
 * SPDX-FileCopyrightText: 2020-2021 Roland Fredenhagen <important@van-fredenhagen.de>
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/settings/markdown_renderer_config.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/widgets/settings_header.dart';
import 'package:gitjournal/settings/widgets/settings_list_preference.dart';
import 'package:provider/provider.dart';

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
          hintText: context.loc.settingsDisplayImagesCaptionsDoCaptionTagsHint,
          labelText:
              context.loc.settingsDisplayImagesCaptionsDoCaptionTagsLabel,
        ),
        validator: (String? value) {
          value = value!.trim();
          if (parseTags(value).isEmpty) {
            return context
                .loc.settingsDisplayImagesCaptionsDoCaptionTagsValidatorEmpty;
          }

          if (parseTags(value)
              .intersection(settings.doCaptionTags)
              .isNotEmpty) {
            return context
                .loc.settingsDisplayImagesCaptionsDoCaptionTagsValidatorSame;
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
          hintText: context.loc.settingsDisplayImagesCaptionsDoCaptionTagsHint,
          labelText:
              context.loc.settingsDisplayImagesCaptionsDoCaptionTagsLabel,
        ),
        validator: (String? value) {
          if (parseTags(value!).isEmpty) {
            return context
                .loc.settingsDisplayImagesCaptionsDoCaptionTagsValidatorEmpty;
          }

          if (parseTags(value)
              .intersection(settings.doNotCaptionTags)
              .isNotEmpty) {
            return context
                .loc.settingsDisplayImagesCaptionsDoCaptionTagsValidatorSame;
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
        title: context.loc.settingsDisplayImagesCaptionsUseAsCaption,
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
        title: Text(context.loc.settingsDisplayImagesCaptionsOverlayCaption),
        value: settings.overlayCaption,
        onChanged: (bool newVal) {
          settings.overlayCaption = newVal;
          settings.save();
        },
      ),
      if (settings.overlayCaption)
        SwitchListTile(
          title:
              Text(context.loc.settingsDisplayImagesCaptionsTransparentCaption),
          value: settings.transparentCaption,
          onChanged: (bool newVal) {
            settings.transparentCaption = newVal;
            settings.save();
          },
        ),
      if (settings.overlayCaption && settings.transparentCaption)
        SwitchListTile(
          title:
              Text(context.loc.settingsDisplayImagesCaptionsBlurBehindCaption),
          value: settings.blurBehindCaption,
          onChanged: (bool newVal) {
            settings.blurBehindCaption = newVal;
            settings.save();
          },
        ),
      SwitchListTile(
        title: Text(context.loc.settingsDisplayImagesCaptionsTooltipFirstTitle),
        value: settings.tooltipFirst,
        subtitle: settings.tooltipFirst
            ? Text(context.loc.settingsDisplayImagesCaptionsTooltipFirstTooltip)
            : Text(
                context.loc.settingsDisplayImagesCaptionsTooltipFirstAltText),
        onChanged: (bool newVal) {
          settings.tooltipFirst = newVal;
          settings.save();
        },
      ),
      SettingsHeader(
        context.loc.settingsDisplayImagesCaptionsCaptionOverrides,
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Text(context.loc.settingsDisplayImagesCaptionsTagDescription),
      ),
      ListTile(title: doCaptionTagsForm),
      ListTile(title: doNotCaptionTagsForm)
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.settingsDisplayImagesCaptionsTitle),
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
