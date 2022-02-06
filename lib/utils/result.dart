/*
 * SPDX-FileCopyrightText: 2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

export 'package:dart_git/utils/result.dart';

import 'package:dart_git/utils/result.dart';

class WrappedException implements Exception {
  final String message;

  final Object exception;
  final StackTrace stackTrace;

  WrappedException(Result r, this.message)
      : exception = r.error!,
        stackTrace = r.stackTrace!;

  @override
  String toString() => "$message: $exception";
}
