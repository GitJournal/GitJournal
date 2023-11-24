/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:gitjournal/settings/settings_git_remote.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';

class ErrorScreen extends StatelessWidget {
  static const routePath = '/error';

  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var repoManager = context.watch<RepositoryManager>();
    // assert(repoManager.currentRepo == null);

    if (repoManager.currentRepo != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "This screen should never be visible",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      );
    }

    var children = <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          context.loc.screensErrorMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          repoManager.currentRepoError.toString(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      const SizedBox(height: 64),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          child: Text(context.loc.drawerAddRepo),
          onPressed: () async {
            try {
              await repoManager.addRepoAndSwitch();
            } catch (ex) {
              Navigator.pop(context);
              Navigator.of(context).pushNamedAndRemoveUntil(
                ErrorScreen.routePath,
                (r) => true,
              );
            }

            Navigator.pop(context);
            Navigator.of(context).pushNamedAndRemoveUntil(
              HomeScreen.routePath,
              (r) => true,
            );
          },
        ),
      ),
      RedButton(
        text: context.loc.settingsDeleteRepo,
        onPressed: () async {
          var ok = await showDialog(
            context: context,
            builder: (_) => IrreversibleActionConfirmationDialog(
              title: context.loc.settingsDeleteRepo,
              subtitle: context.loc.settingsGitRemoteChangeHostSubtitle,
            ),
          );
          if (ok == null) {
            return;
          }

          var repoManager = context.read<RepositoryManager>();
          await repoManager.deleteCurrent();

          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
    ];

    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text(context.loc.screensErrorTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}

//
// * Add a file bug buttton
// * Add text on how to recover the data
//
