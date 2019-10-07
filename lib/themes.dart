import 'package:flutter/material.dart';

class Themes {
  static final light = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFF66bb6a),
    primaryColorLight: Color(0xFF98ee99),
    primaryColorDark: Color(0xFF338a3e),
    accentColor: Color(0xff6d4c41),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xff212121),
    accentColor: Color(0xff689f38),
  );
}
