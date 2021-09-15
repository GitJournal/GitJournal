/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class IconDismissable extends Dismissible {
  final Color backgroundColor;
  final IconData iconData;

  IconDismissable({
    required Key key,
    required this.backgroundColor,
    required this.iconData,
    required Function(DismissDirection) onDismissed,
    required Widget child,
  }) : super(
          key: key,
          child: child,
          onDismissed: onDismissed,
          background: Container(
            color: backgroundColor,
            alignment: AlignmentDirectional.centerStart,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
          secondaryBackground: Container(
            color: backgroundColor,
            alignment: AlignmentDirectional.centerEnd,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 0.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
          dismissThresholds: {
            DismissDirection.horizontal: 0.60,
            DismissDirection.endToStart: 0.60,
            DismissDirection.startToEnd: 0.60,
          },
        );
}
