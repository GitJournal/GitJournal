/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:function_types/function_types.dart';
import 'package:git_setup/git_config.dart';
import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/logger/logger.dart';

import 'apis/githost_factory.dart';
import 'button.dart';
import 'error.dart';
import 'loading.dart';

class GitHostSetupAutoConfigurePage extends StatefulWidget {
  final GitHostType gitHostType;
  final Func2<GitHost?, UserInfo?, void> onDone;
  final ISetupProviders providers;

  const GitHostSetupAutoConfigurePage({
    required this.gitHostType,
    required this.onDone,
    required this.providers,
    super.key,
  });

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
  String _message = "";

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
            _message = context.loc.setupAutoconfigureReadUser;
          });

          Log.d("Starting to fetch userInfo");
          userInfo = await gitHost!.getUserInfo().getOrThrow();
          Log.d("Got UserInfo - $userInfo");

          var gitConfig = widget.providers.readGitConfig(context);
          if (userInfo.name.isNotEmpty) {
            gitConfig.gitAuthor = userInfo.name;
          } else if (userInfo.username.isNotEmpty) {
            gitConfig.gitAuthor = userInfo.username;
          }
          if (userInfo.email.isNotEmpty) {
            gitConfig.gitAuthorEmail = userInfo.email;
          }
          await gitConfig.save();
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
    if (_message.isEmpty) _message = context.loc.setupAutoconfigureWaitPerm;

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
          context.loc.setupAutoConfigureTitle,
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 32.0),

        // Step 1
        Text(
          context.loc.setupAutoconfigureStep1,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        const SizedBox(height: 8.0),
        Text(
          context.loc.setupAutoconfigureStep2,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        const SizedBox(height: 8.0),
        Text(
          context.loc.setupAutoconfigureStep3,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        const SizedBox(height: 32.0),
        Text(
          context.loc.setupAutoconfigureWarning,
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontStyle: FontStyle.italic,
              ),
        ),
        const SizedBox(height: 32.0),

        GitHostSetupButton(
          text: context.loc.setupAutoconfigureAuthorize,
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
