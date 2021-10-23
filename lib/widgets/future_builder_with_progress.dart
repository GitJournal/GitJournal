/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

class FutureBuilderWithProgress<T> extends StatelessWidget {
  final Future<T> future;

  const FutureBuilderWithProgress({
    Key? key,
    required this.future,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      builder: (context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasData) {
          return snapshot.data as Widget;
        }
        return const Center(child: CircularProgressIndicator());
      },
      future: future,
    );
  }
}
