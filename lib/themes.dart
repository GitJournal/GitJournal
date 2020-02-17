import 'package:flutter/material.dart';

class Themes {
  static final light = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF66bb6a),
    primaryColorLight: const Color(0xFF98ee99),
    primaryColorDark: const Color(0xFF338a3e),
    accentColor: const Color(0xff6d4c41),
    cursorColor: const Color(0xFF66bb6a),
    textSelectionHandleColor: const Color(0xFF66bb6a),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xff212121),
    accentColor: const Color(0xff689f38),
    cursorColor: const Color(0xFF66bb6a),
    textSelectionHandleColor: const Color(0xFF66bb6a),
    toggleableActiveColor: const Color(0xFF66bb6a),
  );
}
