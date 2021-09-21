/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'error.dart';
import 'loading.dart';

class GitHostSetupLoadingErrorPage extends StatelessWidget {
  final String? errorMessage;
  final String loadingMessage;

  const GitHostSetupLoadingErrorPage({
    required this.errorMessage,
    required this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null || errorMessage!.isEmpty) {
      return GitHostSetupLoadingPage(loadingMessage);
    }

    return GitHostSetupErrorPage(errorMessage!);
  }
}
