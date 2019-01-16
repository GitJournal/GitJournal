import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:path/path.dart' as p;

import 'package:journal/analytics.dart';
import 'package:journal/state_container.dart';
import 'package:journal/storage/git.dart';

class OnBoardingGitClone extends StatefulWidget {
  final Function doneFunction;

  OnBoardingGitClone({@required this.doneFunction});

  @override
  OnBoardingGitCloneState createState() {
    return new OnBoardingGitCloneState();
  }
}

class OnBoardingGitCloneState extends State<OnBoardingGitClone> {
  String errorMessage = "";

  @override
  void initState() {
    super.initState();

    // FIXME: This is throwing an exception!
    _initStateAsync();
  }

  void _initStateAsync() async {
    var pref = await SharedPreferences.getInstance();
    String sshCloneUrl = pref.getString("sshCloneUrl");

    // Just in case it was half cloned because of an error
    await _removeExistingClone();

    String error = await gitClone(sshCloneUrl, "journal");
    if (error != null && error.isNotEmpty) {
      setState(() {
        getAnalytics().logEvent(
          name: "onboarding_gitClone_error",
          parameters: <String, dynamic>{
            'error': error,
          },
        );
        errorMessage = error;
      });
    } else {
      this.widget.doneFunction();
    }
  }

  Future _removeExistingClone() async {
    var baseDir = await getNotesDir();
    var dotGitDir = new Directory(p.join(baseDir.path, ".git"));
    bool exists = await dotGitDir.exists();
    if (exists) {
      await baseDir.delete(recursive: true);
      await baseDir.create();
    }
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    if (this.errorMessage.isEmpty) {
      children = <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Cloning ...',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.display1,
          ),
        ),
        SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircularProgressIndicator(
            value: null,
          ),
        ),
      ];
    } else if (this.errorMessage.isNotEmpty) {
      children = <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Failed',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.display1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            this.errorMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.display1,
          ),
        ),
      ];
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}
