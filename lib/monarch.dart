import 'dart:async';

import 'package:flutter/material.dart';

import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:gitjournal/themes.dart';
import 'package:monarch_annotations/monarch_annotations.dart';

// ignore_for_file: implementation_imports

/// Only used with Monarch
class MonarchLocalizationsDelegate extends LocalizationsDelegate<Localization> {
  const MonarchLocalizationsDelegate();

  @override
  Future<Localization> load(Locale locale) async {
    var assetLoader = YamlAssetLoader();
    var data = await assetLoader.load('assets/langs', locale);
    var translations = Translations(data);

    Localization.load(locale, translations: translations);
    return Localization.instance;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<Localization> old) => false;

  @override
  bool isSupported(Locale locale) => [
        'de',
        'en',
        'es',
        'id',
        'pl',
        'pr',
        'ru',
        'sv',
        'zh',
      ].contains(locale.languageCode);
}

@MonarchLocalizations([
  MonarchLocale('en'),

  // In Alphabetical order
  MonarchLocale('de'),
  MonarchLocale('es'),
  MonarchLocale('id'),
  MonarchLocale('pl'),
  MonarchLocale('pr'),
  MonarchLocale('ru'),
  MonarchLocale('sv'),
  MonarchLocale('zh'),
])
const myEasyLocalizationsDelegate = MonarchLocalizationsDelegate();

@MonarchTheme('Light Theme', isDefault: true)
final monarchLightTheme = Themes.light;

@MonarchTheme('Dark Theme')
final monarchDarkTheme = Themes.dark;
