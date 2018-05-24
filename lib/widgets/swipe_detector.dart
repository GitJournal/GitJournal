import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class SwipeDetector extends StatelessWidget {
  final VoidCallback onLeftSwipe;
  final VoidCallback onRightSwipe;
  final Widget child;

  SwipeDetector({
    @required this.onLeftSwipe,
    @required this.onRightSwipe,
    @required this.child,
  });

  @override
  Widget build(BuildContext context) {
    double primaryDelta;

    return new GestureDetector(
      child: child,
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        primaryDelta = details.primaryDelta;
      },
      onHorizontalDragEnd: (DragEndDetails _) {
        if (primaryDelta > 0) {
          onRightSwipe();
        } else {
          onLeftSwipe();
        }
      },
    );
  }
}
