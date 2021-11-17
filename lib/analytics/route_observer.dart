/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/widgets.dart';

import 'package:gitjournal/logger/logger.dart';
import 'analytics.dart';

class AnalyticsRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  Future<void> _sendScreenView(PageRoute<dynamic> route) async {
    var screenName = route.settings.name;
    if (route.runtimeType.toString().startsWith("_SearchPageRoute")) {
      screenName = "/search";
    }

    if (screenName == null) {
      screenName = 'Unknown';
      return;
    }

    try {
      await Analytics.instance?.setCurrentScreen(screenName: screenName);
    } catch (e, stackTrace) {
      Log.e("AnalyticsRouteObserver", ex: e, stacktrace: stackTrace);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _sendScreenView(route);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _sendScreenView(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);
    }
  }
}
