import 'package:flutter/material.dart';

/// A Scroll view which occupies the full height of the parent, and doesn't
/// show the overflow animation.
class EditorScrollView extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  EditorScrollView({
    @required this.child,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (
      BuildContext context,
      BoxConstraints constraints,
    ) {
      return NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overScroll) {
          overScroll.disallowGlow();
          return false;
        },
        child: SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              minWidth: constraints.maxWidth,
            ),
            child: child,
          ),
        ),
      );
    });
  }
}
