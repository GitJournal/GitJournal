import 'package:flutter/material.dart';

class ScrollViewWithoutAnimation extends StatelessWidget {
  final Widget child;
  final Axis scrollDirection;

  ScrollViewWithoutAnimation({
    @required this.child,
    this.scrollDirection,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (OverscrollIndicatorNotification overScroll) {
        overScroll.disallowGlow();
        return false;
      },
      child: SingleChildScrollView(
        scrollDirection: scrollDirection,
        child: child,
      ),
    );
  }
}
