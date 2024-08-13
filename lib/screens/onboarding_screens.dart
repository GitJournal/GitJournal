/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:function_types/function_types.dart';
import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/screens/home_screen.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:time/time.dart';

class OnBoardingScreen extends StatefulWidget {
  static const routePath = "/onBoarding";

  final bool skipPage1;
  final bool skipPage2;
  final bool skipPage3;

  const OnBoardingScreen({
    super.key,
    this.skipPage1 = false,
    this.skipPage2 = false,
    this.skipPage3 = false,
  });

  @override
  OnBoardingScreenState createState() {
    return OnBoardingScreenState();
  }
}

class OnBoardingScreenState extends State<OnBoardingScreen> {
  final _pageController = PageController();
  int _currentPageIndex = 0;

  final _bottomBarHeight = 50.0;

  @override
  void initState() {
    super.initState();

    () async {
      var info = await PackageInfo.fromPlatform();

      logEvent(Event.AppFirstOpen, parameters: {
        "version": info.version,
        "app_name": info.appName,
        "package_name": info.packageName,
        "build_number": info.buildNumber,
      });
    }();
  }

  @override
  Widget build(BuildContext context) {
    var pages = <Widget>[
      if (!widget.skipPage1) OnBoardingPage1(),
      if (!widget.skipPage2) OnBoardingPage2(),
      if (!widget.skipPage3) OnBoardingPage3(),
    ];
    var pageView = PageView(
      controller: _pageController,
      children: pages,
      onPageChanged: (int pageNum) {
        setState(() {
          _currentPageIndex = pageNum;
        });
      },
    );

    Widget bottomBar;
    if (_currentPageIndex != pages.length - 1) {
      var row = Row(
        children: <Widget>[
          OnBoardingBottomButton(
            key: const ValueKey("Skip"),
            text: context.loc.onBoardingSkip,
            onPressed: _finish,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DotsIndicator(
                  dotsCount: pages.length,
                  position: _currentPageIndex.toDouble(),
                  decorator: DotsDecorator(
                    activeColor: Theme.of(context).primaryColorDark,
                  ),
                ),
              ],
            ),
          ),
          OnBoardingBottomButton(
            key: const ValueKey("Next"),
            text: context.loc.onBoardingNext,
            onPressed: _nextPage,
          ),
        ],
      );

      bottomBar = Container(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.grey[200]
            : Theme.of(context).primaryColor,
        child: SizedBox(
          width: double.infinity,
          height: _bottomBarHeight,
          child: row,
        ),
      );
    } else {
      bottomBar = SizedBox(
        width: double.infinity,
        height: _bottomBarHeight,
        child: ElevatedButton(
          key: const ValueKey("GetStarted"),
          style: ButtonStyle(
            backgroundColor:
                WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
          ),
          onPressed: _finish,
          child: Text(
            context.loc.onBoardingGetStarted,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: pageView,
      ),
      bottomNavigationBar: AnimatedSwitcher(
        duration: 300.milliseconds,
        child: bottomBar,
      ),
    );
  }

  void _finish() {
    var appConfig = context.read<AppConfig>();
    appConfig.onBoardingCompleted = true;
    appConfig.save();

    Navigator.popAndPushNamed(context, HomeScreen.routePath);
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: 200.milliseconds,
      curve: Curves.easeIn,
    );
  }
}

class OnBoardingBottomButton extends StatelessWidget {
  final Func0<void> onPressed;
  final String text;

  const OnBoardingBottomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    var isDark = Theme.of(context).brightness == Brightness.dark;

    return TextButton(
      key: key,
      onPressed: onPressed,
      style: isDark
          ? ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(
                Theme.of(context).primaryColor,
              ),
            )
          : null,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

class OnBoardingPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var headerTextStyle = textTheme.displayMedium!.copyWith(fontFamily: "Lato");
    var header = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'assets/icon/icon.png',
          height: 200,
          fit: BoxFit.fill,
        ),
        const SizedBox(height: 16.0),
        Text(
          "GitJournal",
          style: headerTextStyle,
        ),
      ],
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(child: header),
        const SizedBox(height: 64.0),
        AutoSizeText(
          context.loc.onBoardingSubtitle,
          style: textTheme.headlineSmall,
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }
}

class OnBoardingPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var header = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'assets/OnBoardingMarkdown.png',
          //height: 200,
          fit: BoxFit.fill,
        ),
        const SizedBox(height: 16.0),
      ],
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(child: header),
        const SizedBox(height: 64.0),
        AutoSizeText(
          context.loc.onBoardingPage2,
          style: textTheme.headlineSmall,
          textAlign: TextAlign.center,
          maxLines: 3,
        ),
      ],
    );
  }
}

class OnBoardingPage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var header = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'assets/OnBoardingGitProviders.png',
          //height: 200,
          fit: BoxFit.fill,
        ),
        const SizedBox(height: 16.0),
      ],
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(child: header),
        const SizedBox(height: 64.0),
        AutoSizeText(
          context.loc.onBoardingPage3,
          style: textTheme.headlineSmall,
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }
}
