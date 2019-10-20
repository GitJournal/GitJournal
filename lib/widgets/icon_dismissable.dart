import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class IconDismissable extends Dismissible {
  final Color backgroundColor;
  final IconData iconData;

  IconDismissable({
    @required Key key,
    @required this.backgroundColor,
    @required this.iconData,
    @required Function onDismissed,
    @required Widget child,
  }) : super(
          key: key,
          child: child,
          onDismissed: onDismissed,
          background: Container(
            color: backgroundColor,
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
          secondaryBackground: Container(
            color: backgroundColor,
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 0.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
        );
}
