/*
 * SPDX-FileCopyrightText: 2019-2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/widgets.dart';

import 'package:git_setup/keygen.dart';

abstract class IGitConfig {
  String get gitAuthor;
  String get gitAuthorEmail;
  String get sshPublicKey;
  String get sshPrivateKey;
  String get sshPassword;
  SshKeyType get sshKeyType;

  set gitAuthor(String x);
  set gitAuthorEmail(String x);
  set sshPublicKey(String x);
  set sshPrivateKey(String x);
  set sshPassword(String x);
  set sshKeyType(SshKeyType x);

  Future<void> save();
}

abstract class ISetupProviders {
  IGitConfig readGitConfig(BuildContext context);
}
