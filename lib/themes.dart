/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'settings/settings.dart';

class Themes {
  static final _light = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.green,
    ).copyWith(
      primary: const Color(0xFF66bb6a),
      secondary: const Color(0xff6d4c41),
      onPrimary: Colors.black,
    ),
    brightness: Brightness.light,
    primaryColor: const Color(0xFF66bb6a),
    primaryColorLight: const Color(0xFF98ee99),
    primaryColorDark: const Color(0xFF338a3e),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: const Color(0xFF338a3e),
      selectionHandleColor: const Color(0xFF66bb6a),
      selectionColor: Colors.grey[400],
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
    }),
    useMaterial3: false,
  );

  static final _dark = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.grey,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xff212121),
      secondary: const Color(0xff689f38),
    ),
    brightness: Brightness.dark,
    primaryColor: const Color(0xff212121),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color(0xFF66bb6a),
      selectionHandleColor: Color(0xFF66bb6a),
      selectionColor: Color(0xff689f38),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
    }),
    checkboxTheme: CheckboxThemeData(
      fillColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF66bb6a);
        }
        return null;
      }),
    ),
    radioTheme: RadioThemeData(
      fillColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF66bb6a);
        }
        return null;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF66bb6a);
        }
        return null;
      }),
      trackColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF66bb6a);
        }
        return null;
      }),
    ),
    useMaterial3: false,
  );

  static ThemeData fromName(String name) {
    switch (name) {
      case DEFAULT_LIGHT_THEME_NAME:
        return _light;
      case DEFAULT_DARK_THEME_NAME:
        return _dark;
      default:
        throw Exception("Theme not found - $name");
    }
  }
}
