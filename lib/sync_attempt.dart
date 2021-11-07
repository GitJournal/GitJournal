/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

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

  SyncAttemptPart(this.status, [this.exception]) : when = DateTime.now();
}

class SyncAttempt {
  var parts = <SyncAttemptPart>[];
  void add(SyncStatus status, [Exception? exception]) {
    var part = SyncAttemptPart(status, exception);
    parts.add(part);
  }

  SyncStatus get status => parts.last.status;
  DateTime get when => parts.last.when;
}
