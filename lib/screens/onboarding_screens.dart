import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:function_types/function_types.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/settings.dart';

class OnBoardingScreen extends StatefulWidget {
  OnBoardingScreen();

  @override
  OnBoardingScreenState createState() {
    return OnBoardingScreenState();
  }
}

class OnBoardingScreenState extends State<OnBoardingScreen> {
  var pageController = PageController();
  int _currentPageIndex = 0;

  final _bottomBarHeight = 50.0;

  @override
  Widget build(BuildContext context) {
    var pages = <Widget>[
      OnBoardingPage1(),
      OnBoardingPage2(),
      OnBoardingPage3(),
    ];
    var pageView = PageView(
      controller: pageController,
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
            text: "Skip",
            onPressed: _finish,
          ),
          Expanded(
            child: Row(
              children: [
                DotsIndicator(
                  dotsCount: pages.length,
                  position: _currentPageIndex,
                  decorator: DotsDecorator(
                    activeColor: Theme.of(context).primaryColorDark,
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
          OnBoardingBottomButton(
            key: const ValueKey("Next"),
            text: "Next",
            onPressed: _nextPage,
          ),
        ],
      );

      bottomBar = Container(
        child: SizedBox(
          width: double.infinity,
          height: _bottomBarHeight,
          child: row,
        ),
        color: Colors.grey[200],
      );
    } else {
      bottomBar = SizedBox(
        width: double.infinity,
        height: _bottomBarHeight,
        child: RaisedButton(
          key: const ValueKey("GetStarted"),
          child: Text(
            "Get Started",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.button,
          ),
          color: Theme.of(context).primaryColor,
          onPressed: _finish,
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: pageView,
        padding: const EdgeInsets.all(16.0),
      ),
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: bottomBar,
      ),
    );
  }

  void _finish() {
    var settings = Provider.of<Settings>(context);
    settings.onBoardingCompleted = true;
    settings.save();

    Navigator.pop(context);
    Navigator.pushNamed(context, "/");
  }

  void _nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
  }
}

class OnBoardingBottomButton extends StatelessWidget {
  final Func0<void> onPressed;
  final String text;

  OnBoardingBottomButton({
    Key key,
    @required this.text,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      key: key,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.button,
      ),
      //color: Colors.grey[200],
      onPressed: onPressed,
    );
  }
}

class OnBoardingPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var headerTextStyle = textTheme.headline2.copyWith(fontFamily: "Lato");
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

    return Container(
      child: Column(
        children: <Widget>[
          Center(child: header),
          const SizedBox(height: 64.0),
          AutoSizeText(
            "A Open Source Note Taking App\nbuilt on top of Git",
            style: textTheme.headline5,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
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

    return Container(
      child: Column(
        children: <Widget>[
          Center(child: header),
          const SizedBox(height: 64.0),
          AutoSizeText(
            "Your Notes are stored in a\nstandard Markdown + YAML\nHeader format",
            style: textTheme.headline5,
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
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

    return Container(
      child: Column(
        children: <Widget>[
          Center(child: header),
          const SizedBox(height: 64.0),
          AutoSizeText(
            "Sync your Local Git Repo\nwith any provider",
            style: textTheme.headline5,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }
}
