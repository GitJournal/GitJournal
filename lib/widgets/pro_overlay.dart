import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/features.dart';
import 'package:gitjournal/settings/app_settings.dart';

class ProOverlay extends StatelessWidget {
  final Widget child;
  final Feature feature;

  ProOverlay({required this.child, required this.feature}) {
    assert(feature.pro == true);
  }

  @override
  Widget build(BuildContext context) {
    var appSettings = Provider.of<AppSettings>(context);

    if (appSettings.proMode) {
      return child;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Banner(
        message: tr('pro'),
        location: BannerLocation.topEnd,
        color: Theme.of(context).accentColor,
        child: IgnorePointer(child: Opacity(opacity: 0.5, child: child)),
      ),
      onTap: () {
        Navigator.pushNamed(context, "/purchase");

        logEvent(
          Event.PurchaseScreenOpen,
          parameters: {"from": feature.featureName},
        );
      },
    );
  }
}
