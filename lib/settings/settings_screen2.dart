/*
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';

class SettingsScreen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var list = ListView(
      children: [
        _SettingsSearchBar(),
        _SettingsTile(
          iconData: FontAwesomeIcons.paintBrush,
          title: LocaleKeys.settings_list_userInterface_title.tr(),
          subtitle: LocaleKeys.settings_list_userInterface_subtitle.tr(),
        ),
        _SettingsTile(
          iconData: FontAwesomeIcons.git,
          title: LocaleKeys.settings_list_git_title.tr(),
          subtitle: LocaleKeys.settings_list_git_subtitle.tr(),
        ),
        _SettingsTile(
          iconData: FontAwesomeIcons.edit,
          title: LocaleKeys.settings_list_editor_title.tr(),
          subtitle: LocaleKeys.settings_list_editor_subtitle.tr(),
        ),
        _SettingsTile(
          iconData: FontAwesomeIcons.sdCard,
          title: LocaleKeys.settings_list_storage_title.tr(),
          subtitle: LocaleKeys.settings_list_storage_subtitle.tr(),
        ),
        _SettingsTile(
          iconData: FontAwesomeIcons.chartArea,
          title: "Analytics",
          subtitle: "Configure what Analytics are collected and when",
        ),
        _SettingsTile(
          iconData: FontAwesomeIcons.wrench,
          title: "Debug",
          subtitle: "Peek inside the inner working of GitJournal",
        ),
        const Divider(),
        _SettingsHeader("Project"),
        _SettingsTile(
          iconData: Icons.question_answer_outlined,
          title: "Documentation & Support",
        ),
        _SettingsTile(
          iconData: Icons.bug_report,
          title: LocaleKeys.drawer_bug.tr(),
        ),
        _SettingsTile(
          iconData: Icons.feedback,
          title: LocaleKeys.drawer_feedback.tr(),
        ),
        _SettingsTile(
          iconData: FontAwesomeIcons.solidHeart,
          title: "Contribute",
        ),
        _SettingsTile(
          iconData: Icons.info_outline,
          title: "About",
        ),
      ],
      padding: const EdgeInsets.symmetric(vertical: 16.0),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.settings_title.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: list,
    );
  }
}

class _SettingsSearchBar extends StatelessWidget {
  const _SettingsSearchBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 1.0,
        borderRadius: BorderRadius.circular(25.0),
        child: TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            hintText: "Search",
            fillColor: Colors.white70,
            prefixIcon: Icon(Icons.search),
            // This content padding has no effect if 'prefixIcon' is set!!
            contentPadding: EdgeInsets.fromLTRB(205.0, 15.0, 20.0, 15.0),
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData iconData;
  final String title;
  final String? subtitle;

  const _SettingsTile({
    Key? key,
    required this.iconData,
    required this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var listTileTheme = ListTileTheme.of(context);

    var textStyle = theme.textTheme.subtitle1!.copyWith(
      color: listTileTheme.textColor,
    );

    var icon = iconData is FontAwesomeIcons
        ? Icon(iconData, color: textStyle.color)
        : FaIcon(iconData, color: textStyle.color);

    return ListTile(
      leading: icon,
      title: Text(title, style: textStyle),
      subtitle: subtitle != null ? Text(subtitle!) : null,
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final String text;
  const _SettingsHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 20.0),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
