/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/widgets/settings_list_preference.dart';
import 'package:language_picker/languages.dart';
import 'package:provider/provider.dart';

extension LocaleToStringHelper on Locale {
  /// Convert [locale] to String with custom separator
  String toStringWithSeparator({String separator = '_'}) {
    return toString().split('_').join(separator);
  }
}

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    if (foundation.kDebugMode) {
      _checkLangTags(context);
    }

    var supportedLocales = context
        .findAncestorWidgetOfExactType<MaterialApp>()!
        .supportedLocales
        .toList();

    final appLocale = Localizations.localeOf(context);

    return ListPreference(
      title: context.loc.settingsDisplayLang,
      currentOption: Language.fromIsoCode(
        appLocale.toStringWithSeparator(),
      ).name,
      options: supportedLocales
          .map((l) => Language.fromIsoCode(l.toStringWithSeparator()).name)
          // .map((l) => l.toLanguageTag())
          .toList(),
      onChange: (String languageName) {
        var lang = Languages.defaultLanguages
            .firstWhere((l) => l.name == languageName);
        var locale = supportedLocales
            .firstWhere((e) => e.toStringWithSeparator() == lang.isoCode);

        var settings = context.read<Settings>();
        settings.locale = locale.toStringWithSeparator();
        settings.save();
      },
    );
  }

  void _checkLangTags(BuildContext context) {
    var supportedLocales = context
        .findAncestorWidgetOfExactType<MaterialApp>()!
        .supportedLocales
        .toList();

    for (var locale in supportedLocales) {
      var lang = Languages.defaultLanguages
          .firstWhereOrNull((l) => l.isoCode == locale.toStringWithSeparator());
      if (lang == null) {
        assert(false, "Language not found for ${locale.toLanguageTag()}");
      }
    }
  }
}
