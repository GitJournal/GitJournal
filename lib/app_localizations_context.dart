/*
 * SPDX-FileCopyrightText: 2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

extension LocalizedBuildContext on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
}

// Arranged Alphabetically
// Remember to update Info.plist
const gitJournalSupportedLocales = [
  Locale('de'),
  Locale('en'),
  Locale('es'),
  Locale('fr'),
  Locale('hu'),
  Locale('id'),
  Locale('it'),
  Locale('ja'),
  Locale('ko'),
  Locale('pl'),
  Locale('pt'),
  Locale('ru'),
  Locale('sv'),
  Locale('vi'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
];

Iterable<LocalizationsDelegate<dynamic>> buildDelegates(BuildContext context) {
  var easyLocale = EasyLocalization.of(context);

  return [
    if (easyLocale != null) ...easyLocale.delegates,
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}
