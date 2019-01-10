import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journal/app.dart';
import 'package:journal/state_container.dart';

void main() async {
  var pref = await SharedPreferences.getInstance();
  var onBoardingCompleted = pref.getBool("onBoardingCompleted") ?? false;

  runApp(new StateContainer(
    onBoardingCompleted: onBoardingCompleted,
    child: JournalApp(),
  ));
}
