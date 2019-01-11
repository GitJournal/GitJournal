import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journal/storage/git.dart';

class OnBoardingScreen extends StatefulWidget {
  final Function onBoardingCompletedFunction;

  OnBoardingScreen(this.onBoardingCompletedFunction);

  @override
  OnBoardingScreenState createState() {
    return new OnBoardingScreenState();
  }
}

class OnBoardingScreenState extends State<OnBoardingScreen> {
  var _pageInputUrlDone = false;
  var _pageSshKeyDone = false;

  var pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String publicKey = "Generating ...";

  @override
  Widget build(BuildContext context) {
    var pageCount = 1;
    if (_pageInputUrlDone) {
      pageCount++;
    }
    if (_pageSshKeyDone) {
      pageCount++;
    }

    var pageView = PageView.builder(
      controller: pageController,
      itemBuilder: (BuildContext context, int pos) {
        if (pos == 0) {
          return OnBoardingGitUrl(doneFunction: (String sshUrl) {
            setPageInputUrlDone();
            pageController.nextPage(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeIn,
            );

            SharedPreferences.getInstance().then((SharedPreferences pref) {
              pref.setString("sshCloneUrl", sshUrl);
              this._generateSshKey();
            });
          });
        }
        if (pos == 1) {
          return OnBoardingSshKey(
            doneFunction: () {
              setPageSshKeyDone();
              pageController.nextPage(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeIn,
              );
            },
            publicKey: publicKey,
          );
        }

        if (pos == 2) {
          return OnBoardingGitClone(
            doneFunction: this.widget.onBoardingCompletedFunction,
          );
        }
      },
      itemCount: pageCount,
    );

    return new Scaffold(
      key: _scaffoldKey,
      body: new Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).primaryColor,
        child: pageView,
      ),
    );
  }

  void setPageInputUrlDone() {
    setState(() {
      this._pageInputUrlDone = true;
    });
  }

  void setPageSshKeyDone() {
    setState(() {
      this._pageSshKeyDone = true;
    });
  }

  void _generateSshKey() {
    generateSSHKeys(comment: "GitJournal").then((String _publicKey) {
      setState(() {
        print("Changing the state");
        publicKey = _publicKey;

        Clipboard.setData(ClipboardData(text: publicKey));
        var text = "Public Key copied to Clipboard";
        this
            ._scaffoldKey
            .currentState
            .showSnackBar(new SnackBar(content: new Text(text)));
      });
    });
  }
}

class OnBoardingGitUrl extends StatefulWidget {
  final Function doneFunction;

  OnBoardingGitUrl({@required this.doneFunction});

  @override
  OnBoardingGitUrlState createState() {
    return new OnBoardingGitUrlState();
  }
}

class OnBoardingGitUrlState extends State<OnBoardingGitUrl> {
  final GlobalKey<FormFieldState<String>> sshUrlKey =
      GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final inputFormFocus = FocusNode();

    final formSubmitted = () {
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();

        var url = sshUrlKey.currentState.value;
        this.widget.doneFunction(url);
        inputFormFocus.unfocus();
      }
    };

    var inputForm = Form(
      key: _formKey,
      child: TextFormField(
        key: sshUrlKey,
        textAlign: TextAlign.center,
        autofocus: true,
        style: Theme.of(context).textTheme.title,
        decoration: const InputDecoration(
          hintText: 'Eg: git@github.com:GitJournal/GitJournal.git',
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter some text';
          }
          if (value.startsWith('https://') || value.startsWith('http://')) {
            return 'Only SSH urls are currently accepted';
          }

          RegExp regExp = new RegExp(r"[a-zA-Z0-9.]+@[a-zA-Z0-9.]+:.+");
          if (!regExp.hasMatch(value)) {
            return "Invalid Input";
          }
        },
        focusNode: inputFormFocus,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (String _) => formSubmitted(),
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Enter the Git SSH URL',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.display1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Container(
            color: Theme.of(context).primaryColorLight,
            child: inputForm,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RaisedButton(
            child: Text("Next"),
            onPressed: formSubmitted,
          ),
        )
      ],
    );
  }
}

class OnBoardingSshKey extends StatelessWidget {
  final Function doneFunction;
  final String publicKey;

  OnBoardingSshKey({
    @required this.doneFunction,
    @required this.publicKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          'Deploy Public Key',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          publicKey,
          textAlign: TextAlign.left,
          maxLines: 20,
          style: Theme.of(context).textTheme.body1,
        ),
        RaisedButton(
          child: Text("Start Clone"),
          onPressed: this.doneFunction,
        )
      ],
    );
  }
}

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
    } else {
      this.widget.doneFunction();
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
          style: Theme.of(context).textTheme.display1,
        ),
        CircularProgressIndicator(
          value: null,
        ),
      ];
    } else if (this.errorMessage.isNotEmpty) {
      children = <Widget>[
        Text(
          'Failed',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          this.errorMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1,
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
