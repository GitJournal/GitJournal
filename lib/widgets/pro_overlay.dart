import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/settings.dart';

class ProOverlay extends StatelessWidget {
  final Widget child;

  ProOverlay({@required this.child});

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<Settings>(context);
    if (settings.proMode) {
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
      },
    );
  }
}
