/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

// FIXME: Why are you scrollable!!
class EmptyTextSliver extends StatelessWidget {
  const EmptyTextSliver({
    Key? key,
    required this.emptyText,
  }) : super(key: key);

  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Text(
          emptyText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.w300,
            color: Colors.grey[350],
          ),
        ),
      ),
      hasScrollBody: false,
      fillOverscroll: false,
    );
  }
}
