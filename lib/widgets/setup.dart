/*
 * SPDX-FileCopyrightText: 2019-2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/widgets.dart';

import 'package:function_types/function_types.dart';
import 'package:git_setup/git_config.dart';
import 'package:git_setup/screens.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/settings/git_config.dart';
import 'package:gitjournal/ssh/keygen.dart';

class GitJournalGitSetupScreen extends StatelessWidget {
  final String repoFolderName;
  final Func2<String, String, Future<void>> onCompletedFunction;

  const GitJournalGitSetupScreen({
    super.key,
    required this.repoFolderName,
    required this.onCompletedFunction,
  });

  @override
  Widget build(BuildContext context) {
    return GitHostSetupScreen(
      repoFolderName: repoFolderName,
      remoteName: "origin",
      onCompletedFunction: onCompletedFunction,
      keygen: GitJournalKeygen(),
      providers: _Providers(),
    );
  }
}

class _Providers implements ISetupProviders {
  @override
  IGitConfig readGitConfig(BuildContext context) {
    return context.read<GitConfig>();
  }
}
