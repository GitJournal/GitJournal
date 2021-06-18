import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:function_types/function_types.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/apis/githost_factory.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/utils/logger.dart';
import 'button.dart';
import 'error.dart';
import 'loading.dart';

class GitHostSetupAutoConfigurePage extends StatefulWidget {
  final GitHostType gitHostType;
  final Func2<GitHost?, UserInfo?, void> onDone;

  GitHostSetupAutoConfigurePage({
    required this.gitHostType,
    required this.onDone,
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
  String _message = tr('setup.autoconfigure.waitPerm');

  void _startAutoConfigure() async {
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

        UserInfo? userInfo;
        try {
          setState(() {
            _message = tr('setup.autoconfigure.readUser');
          });

          var userInfo = await gitHost!.getUserInfo().getOrThrow();
          var settings = Provider.of<Settings>(context, listen: false);
          if (userInfo.name.isNotEmpty) {
            settings.gitAuthor = userInfo.name;
          }
          if (userInfo.email.isNotEmpty) {
            settings.gitAuthorEmail = userInfo.email;
          }
          settings.save();
        } on Exception catch (e, stacktrace) {
          _handleGitHostException(e, stacktrace);
          return;
        }
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
    }
  }

  void _handleGitHostException(Exception e, StackTrace stacktrace) {
    Log.d("GitHostSetupAutoConfigure: " + e.toString());
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
          tr('setup.autoconfigure.title'),
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 32.0),

        // Step 1
        Text(
          tr('setup.autoconfigure.step1'),
          style: Theme.of(context).textTheme.bodyText1,
        ),
        const SizedBox(height: 8.0),
        Text(
          tr('setup.autoconfigure.step2'),
          style: Theme.of(context).textTheme.bodyText1,
        ),
        const SizedBox(height: 8.0),
        Text(
          tr('setup.autoconfigure.step3'),
          style: Theme.of(context).textTheme.bodyText1,
        ),
        const SizedBox(height: 32.0),
        Text(
          tr('setup.autoconfigure.warning'),
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontStyle: FontStyle.italic,
              ),
        ),
        const SizedBox(height: 32.0),

        GitHostSetupButton(
          text: tr('setup.autoconfigure.authorize'),
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
