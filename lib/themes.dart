import 'package:flutter/material.dart';

class Themes {
  static final light = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.green,
    ).copyWith(
      primary: const Color(0xFF66bb6a),
      secondary: const Color(0xff6d4c41),
    ),
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

  static final dark = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.grey,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xff212121),
      secondary: const Color(0xff689f38),
    ),
    brightness: Brightness.dark,
    primaryColor: const Color(0xff212121),
    accentColor: const Color(0xff689f38),
    toggleableActiveColor: const Color(0xFF66bb6a),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color(0xFF66bb6a),
      selectionHandleColor: Color(0xFF66bb6a),
    ),
  );
}
