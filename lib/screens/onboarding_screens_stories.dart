import 'package:flutter/material.dart';

import 'onboarding_screens.dart';

Widget page1() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: OnBoardingPage1(),
  );
}

Widget page2() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: OnBoardingPage2(),
  );
}

Widget page3() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: OnBoardingPage3(),
  );
}

Widget all() => OnBoardingScreen();
