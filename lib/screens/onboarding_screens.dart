import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

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

  final _bottomBarHeight = 50.0;

  Widget _buildPage(String text) {
    return Column(
      children: <Widget>[
        Text(text),
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

    Widget bottomBar;
    if (_currentPageIndex != pages.length - 1) {
      var row = Row(
        children: <Widget>[
          OnBoardingBottomButton(text: "Skip", onPressed: _finish),
          Expanded(
            child: Row(
              children: [
                DotsIndicator(
                  numberOfDot: pages.length,
                  position: _currentPageIndex,
                  dotActiveColor: Theme.of(context).primaryColorDark,
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
          OnBoardingBottomButton(text: "Next", onPressed: _nextPage),
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
        padding: EdgeInsets.all(16.0),
      ),
      bottomNavigationBar: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: bottomBar,
      ),
    );
  }

  void _finish() {
    widget.onCompletedFunction();

    Navigator.pop(context);
    Navigator.pushNamed(context, "/");
  }

  void _nextPage() {
    pageController.nextPage(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
  }
}

class OnBoardingBottomButton extends StatelessWidget {
  final Function onPressed;
  final String text;

  OnBoardingBottomButton({@required this.text, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
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
