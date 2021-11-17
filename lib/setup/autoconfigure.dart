/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:function_types/function_types.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/apis/githost_factory.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/git_config.dart';
import 'button.dart';
import 'error.dart';
import 'loading.dart';

class GitHostSetupAutoConfigurePage extends StatefulWidget {
  final GitHostType gitHostType;
  final Func2<GitHost?, UserInfo?, void> onDone;

  const GitHostSetupAutoConfigurePage({
    required this.gitHostType,
    required this.onDone,
    Key? key,
  }) : super(key: key);

  @override
  GitHostSetupAutoConfigurePageState createState() {
    return GitHostSetupAutoConfigurePageState();
  }
}

class GitHostSetupAutoConfigurePageState
    extends State<GitHostSetupAutoConfigurePage> {
  GitHost? gitHost;
  String errorMessage = "";

  bool _configuringStarted = false;
  String _message = tr(LocaleKeys.setup_autoconfigure_waitPerm);

  Future<void> _startAutoConfigure() async {
    Log.d("Starting autoconfigure");
    setState(() {
      _configuringStarted = true;
    });

    gitHost = createGitHost(widget.gitHostType);
    try {
      gitHost!.init((Exception? error) async {
        if (error != null) {
          if (mounted) {
            setState(() {
              errorMessage = error.toString();
            });
          }

          logException(error, StackTrace.current);
          return;
        }
        Log.d("GitHost Initalized: " + widget.gitHostType.toString());

        if (!mounted) {
          Log.d("AutoConfigure not mounted any more");
          return;
        }

        UserInfo? userInfo;
        try {
          setState(() {
            _message = tr(LocaleKeys.setup_autoconfigure_readUser);
          });

          Log.d("Starting to fetch userInfo");
          userInfo = await gitHost!.getUserInfo().getOrThrow();
          Log.d("Got UserInfo - $userInfo");

          var gitConfig = Provider.of<GitConfig>(context, listen: false);
          if (userInfo.name.isNotEmpty) {
            gitConfig.gitAuthor = userInfo.name;
          } else if (userInfo.username.isNotEmpty) {
            gitConfig.gitAuthor = userInfo.username;
          }
          if (userInfo.email.isNotEmpty) {
            gitConfig.gitAuthorEmail = userInfo.email;
          }
          gitConfig.save();
        } on Exception catch (e, stacktrace) {
          _handleGitHostException(e, stacktrace);
          return;
        } on Error catch (e, stacktrace) {
          _handleGitHostException(Exception(e.toString()), stacktrace);
          return;
        }
        Log.i('Got User Info: $userInfo');
        widget.onDone(gitHost, userInfo);
      });

      try {
        await gitHost!.launchOAuthScreen();
      } on PlatformException catch (e, stack) {
        Log.d("LaunchOAuthScreen: Caught platform exception:",
            ex: e, stacktrace: stack);
        Log.d("Ignoring it, since I don't know what else to do");
      }
    } on Exception catch (e, stacktrace) {
      _handleGitHostException(e, stacktrace);
    } on Error catch (e, stacktrace) {
      _handleGitHostException(Exception(e.toString()), stacktrace);
      return;
    }
  }

  void _handleGitHostException(Exception e, StackTrace stacktrace) {
    Log.e("GitHostSetupAutoConfigure", ex: e, stacktrace: stacktrace);
    setState(() {
      errorMessage = widget.gitHostType.toString() + ": " + e.toString();
      logEvent(
        Event.GitHostSetupError,
        parameters: <String, String>{
          'errorMessage': errorMessage,
        },
      );

      logException(e, stacktrace);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_configuringStarted) {
      if (errorMessage.isNotEmpty) {
        return GitHostSetupErrorPage(errorMessage);
      }

      return GitHostSetupLoadingPage(_message);
    }

    var columns = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          tr(LocaleKeys.setup_autoconfigure_title),
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 32.0),

        // Step 1
        Text(
          tr(LocaleKeys.setup_autoconfigure_step1),
          style: Theme.of(context).textTheme.bodyText1,
        ),
        const SizedBox(height: 8.0),
        Text(
          tr(LocaleKeys.setup_autoconfigure_step2),
          style: Theme.of(context).textTheme.bodyText1,
        ),
        const SizedBox(height: 8.0),
        Text(
          tr(LocaleKeys.setup_autoconfigure_step3),
          style: Theme.of(context).textTheme.bodyText1,
        ),
        const SizedBox(height: 32.0),
        Text(
          tr(LocaleKeys.setup_autoconfigure_warning),
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontStyle: FontStyle.italic,
              ),
        ),
        const SizedBox(height: 32.0),

        GitHostSetupButton(
          text: tr(LocaleKeys.setup_autoconfigure_authorize),
          onPressed: _startAutoConfigure,
        ),
      ],
    );

    return Center(
      child: SingleChildScrollView(
        child: columns,
      ),
    );
  }
}
