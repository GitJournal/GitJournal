import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journal/storage/git.dart';

class OnBoardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var pageController = PageController();
    return PageView(
      controller: pageController,
      children: <Widget>[
        OnBoardingGitUrl(doneFunction: (String sshUrl) {
          pageController.nextPage(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );

          SharedPreferences.getInstance().then((SharedPreferences pref) {
            pref.setString("sshCloneUrl", sshUrl);
          });
        }),
        OnBoardingSshKey(doneFunction: () {
          pageController.nextPage(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
        }),
        OnBoardingGitClone(),
      ],
    );
  }
}

class OnBoardingGitUrl extends StatefulWidget {
  final Function doneFunction;

  OnBoardingGitUrl({@required this.doneFunction});

  @override
  OnBoardingGitUrlState createState() {
    return new OnBoardingGitUrlState(doneFunction: this.doneFunction);
  }
}

class OnBoardingGitUrlState extends State<OnBoardingGitUrl> {
  final Function doneFunction;

  final GlobalKey<FormFieldState<String>> sshUrlKey =
      GlobalKey<FormFieldState<String>>();

  OnBoardingGitUrlState({@required this.doneFunction});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.green[400],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Enter the Git SSH URL -',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 38),
            ),
            Form(
              child: TextFormField(
                key: sshUrlKey,
                textAlign: TextAlign.center,
                autofocus: true,
              ),
            ),
            RaisedButton(
              child: Text("Next"),
              onPressed: () {
                var url = sshUrlKey.currentState.value;
                this.doneFunction(url);
              },
            )
          ],
        ),
      ),
    );
  }
}

class OnBoardingSshKey extends StatefulWidget {
  final Function doneFunction;

  OnBoardingSshKey({@required this.doneFunction});

  @override
  OnBoardingSshKeyState createState() {
    return new OnBoardingSshKeyState(doneFunction: this.doneFunction);
  }
}

class OnBoardingSshKeyState extends State<OnBoardingSshKey> {
  final Function doneFunction;

  String publicKey = "Generating ...";

  OnBoardingSshKeyState({@required this.doneFunction});

  void initState() {
    super.initState();
    generateSSHKeys().then((String _publicKey) {
      setState(() {
        print("Changing the state");
        publicKey = _publicKey;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.green[400],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Deploy Public Key',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 38),
            ),
            Text(
              publicKey,
              textAlign: TextAlign.center,
              maxLines: 10,
              style: TextStyle(fontSize: 10),
            ),
            RaisedButton(
              child: Text("Start Clone"),
              onPressed: this.doneFunction,
            )
          ],
        ),
      ),
    );
  }
}

class OnBoardingGitClone extends StatefulWidget {
  @override
  OnBoardingGitCloneState createState() {
    return new OnBoardingGitCloneState();
  }
}

class OnBoardingGitCloneState extends State<OnBoardingGitClone> {
  String errorMessage = "";

  @override
  void initState() {
    _initStateAsync();
  }

  void _initStateAsync() async {
    var pref = await SharedPreferences.getInstance();
    String sshCloneUrl = pref.getString("sshCloneUrl");

    String error = await gitClone(sshCloneUrl, "journal");
    if (error != null && error.isNotEmpty) {
      setState(() {
        errorMessage = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    if (this.errorMessage.isEmpty) {
      children = <Widget>[
        Text(
          'Cloning ...',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 38),
        ),
        CircularProgressIndicator(
          value: null,
        ),
      ];
    } else {
      children = <Widget>[
        Text(
          'Failed',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 38),
        ),
        Text(
          this.errorMessage,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ];
    }

    return new Scaffold(
      body: new Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.green[400],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
