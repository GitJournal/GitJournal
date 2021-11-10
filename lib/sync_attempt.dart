/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:dart_git/plumbing/git_hash.dart';

enum SyncStatus {
  Unknown,
  Done,
  Pulling,
  Merging,
  Pushing,
  Error,
}

class SyncAttemptPart {
  final SyncStatus status;
  final DateTime when;
  final Exception? exception;

  /// The headHash before the SyncStatus was started
  final GitHash? headHash;

  SyncAttemptPart(this.status, this.headHash, [this.exception])
      : when = DateTime.now();
}

class SyncAttempt {
  var parts = <SyncAttemptPart>[];
  void add(SyncStatus status, [Exception? exception]) {
    var part = SyncAttemptPart(status, GitHash.zero(), exception);
    parts.add(part);
  }

  SyncStatus get status => parts.last.status;
  DateTime get when => parts.last.when;
}
