/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

// FIXME: Discard the old analytics, if there are way too many!
// TODO: Take network connectivity into account
// TODO: Take connection type (wifi vs mobile) into account

// TODO: Only allow one call of _sendAnalytics at a time

import 'package:function_types/function_types.dart';

import 'storage.dart';

class AnalyticsController {
  final AnalyticsStorage storage;
  final Func0<bool> isEnabled;

  AnalyticsController({required this.storage, required this.isEnabled});

  Future<bool> shouldSend() async {
    if (!isEnabled()) {
      return false;
    }

    var oldestEvent = await storage.oldestEvent();
    if (DateTime.now().difference(oldestEvent) < const Duration(hours: 1)) {
      return false;
    }

    return true;
  }
}
