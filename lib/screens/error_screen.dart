/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:gitjournal/settings/settings_git_remote.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
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
          style: Theme.of(context).textTheme.headline4,
        ),
      );
    }

    var children = <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          LocaleKeys.screens_error_message.tr(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.subtitle1,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          repoManager.currentRepoError.toString(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ),
      const SizedBox(height: 64),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          child: Text(LocaleKeys.drawer_addRepo.tr()),
          onPressed: () async {
            var r = await repoManager.addRepoAndSwitch();
            Navigator.pop(context);

            var route =
                r.isFailure ? ErrorScreen.routePath : HomeScreen.routePath;

            var _ = Navigator.of(context).pushNamedAndRemoveUntil(
              route,
              (r) => true,
            );
          },
        ),
      ),
      RedButton(
        text: tr(LocaleKeys.settings_deleteRepo),
        onPressed: () async {
          var ok = await showDialog(
            context: context,
            builder: (_) => IrreversibleActionConfirmationDialog(
              title: LocaleKeys.settings_deleteRepo.tr(),
              subtitle: LocaleKeys.settings_gitRemote_changeHost_subtitle.tr(),
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
        title: Text(LocaleKeys.screens_error_title.tr()),
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
