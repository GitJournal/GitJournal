import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

import 'githostsetup_button.dart';

class OnBoardingScreen extends StatefulWidget {
  final Function onCompletedFunction;

  OnBoardingScreen(this.onCompletedFunction);

  @override
  OnBoardingScreenState createState() {
    return OnBoardingScreenState();
  }
}

class OnBoardingScreenState extends State<OnBoardingScreen> {
  var pageController = PageController();
  int _currentPageIndex = 0;

  Widget _buildPage(String text) {
    return Column(
      children: <Widget>[
        Text(text),
        GitHostSetupButton(
          text: 'Take me to the App',
          onPressed: () {
            widget.onCompletedFunction();

            Navigator.pop(context);
            Navigator.pushNamed(context, "/");
          },
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    var pages = <Widget>[
      _buildPage("Page 1"),
      _buildPage("Page 2"),
      _buildPage("Page 3"),
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

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: FractionalOffset.bottomCenter,
          children: <Widget>[
            pageView,
            DotsIndicator(
              numberOfDot: pages.length,
              position: _currentPageIndex,
              dotActiveColor: Theme.of(context).primaryColorDark,
            )
          ],
        ),
        padding: EdgeInsets.all(16.0),
      ),
    );
  }
}
