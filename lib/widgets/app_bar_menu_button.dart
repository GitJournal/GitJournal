import 'package:flutter/material.dart';
import 'package:badges/badges.dart';

import 'package:gitjournal/state_container.dart';

class GJAppBarMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    final appState = container.appState;

    bool shouldShowBadge =
        !appState.remoteGitRepoConfigured && appState.hasJournalEntries;
    var appBarMenuButton = BadgeIconButton(
      key: const ValueKey("DrawerButton"),
      icon: const Icon(Icons.menu),
      itemCount: shouldShowBadge ? 1 : 0,
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    );

    return appBarMenuButton;
  }
}
