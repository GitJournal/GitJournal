import 'package:flutter/material.dart';

import 'package:monarch_annotations/monarch_annotations.dart';

@MonarchTheme('Light Theme', isDefault: true)
final monarchLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF66bb6a),
  primaryColorLight: const Color(0xFF98ee99),
  primaryColorDark: const Color(0xFF338a3e),
  accentColor: const Color(0xff6d4c41),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color(0xFF338a3e),
    selectionHandleColor: Color(0xFF66bb6a),
  ),
);

@MonarchTheme('Dark Theme')
final monarchDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xff212121),
  accentColor: const Color(0xff689f38),
  toggleableActiveColor: const Color(0xFF66bb6a),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color(0xFF66bb6a),
    selectionHandleColor: Color(0xFF66bb6a),
  ),
);

class Themes {
  static final light = monarchLightTheme;
  static final dark = monarchDarkTheme;
}
