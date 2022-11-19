/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/app_localizations_context.dart';

import 'package:provider/provider.dart';

import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/features.dart';
import 'package:gitjournal/settings/app_config.dart';

class ProOverlay extends StatelessWidget {
  final Widget child;
  final Feature feature;

  ProOverlay({required this.child, required this.feature}) {
    assert(feature.pro == true);
  }

  @override
  Widget build(BuildContext context) {
    var appConfig = Provider.of<AppConfig>(context);

    if (appConfig.paidForFeature(feature)) {
      return child;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Banner(
        message: context.loc.pro,
        location: BannerLocation.topEnd,
        color: Theme.of(context).disabledColor,
        child: IgnorePointer(child: Opacity(opacity: 0.5, child: child)),
      ),
      onTap: () {
        var _ = Navigator.pushNamed(context, "/purchase");

        logEvent(
          Event.PurchaseScreenOpen,
          parameters: {"from": feature.featureName},
        );
      },
    );
  }
}
