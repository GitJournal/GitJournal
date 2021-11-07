/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:language_picker/languages.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/settings/widgets/settings_list_preference.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var easyLocale = EasyLocalization.of(context)!;

    if (foundation.kDebugMode) {
      _checkLangTags(context);
    }

    return ListPreference(
      title: tr(LocaleKeys.settings_display_lang),
      currentOption: Language.fromIsoCode(
        easyLocale.currentLocale!.toStringWithSeparator(),
      ).name,
      options: easyLocale.supportedLocales
          .map((l) => Language.fromIsoCode(l.toStringWithSeparator()).name)
          // .map((l) => l.toLanguageTag())
          .toList(),
      onChange: (String languageName) {
        var lang = Languages.defaultLanguages
            .firstWhere((l) => l.name == languageName);
        var locale = easyLocale.supportedLocales
            .firstWhere((e) => e.toStringWithSeparator() == lang.isoCode);
        easyLocale.setLocale(locale);
      },
    );
  }

  void _checkLangTags(BuildContext context) {
    var easyLocale = EasyLocalization.of(context)!;

    for (var locale in easyLocale.supportedLocales) {
      var lang = Languages.defaultLanguages
          .firstWhereOrNull((l) => l.isoCode == locale.toStringWithSeparator());
      if (lang == null) {
        assert(false, "Language not found for ${locale.toLanguageTag()}");
      }
    }
  }
}
