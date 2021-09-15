/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

class GJAppBarMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appBarMenuButton = IconButton(
      key: const ValueKey("DrawerButton"),
      icon: const Icon(Icons.menu),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    );

    return appBarMenuButton;
  }
}
