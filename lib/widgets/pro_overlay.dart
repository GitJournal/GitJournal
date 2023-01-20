/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:provider/provider.dart';

class ProOverlay extends StatelessWidget {
  final Widget child;

  const ProOverlay({required this.child});

  @override
  Widget build(BuildContext context) {
    var appConfig = context.watch<AppConfig>();
    if (appConfig.proMode) return child;

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
      },
    );
  }
}
