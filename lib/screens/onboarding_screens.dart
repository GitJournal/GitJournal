import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:path/path.dart' as p;

import 'package:journal/analytics.dart';
import 'package:journal/state_container.dart';
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
  var _createNewRepo = false;

  var _pageInitalScreenDone = false;
  var _pageCreateNewRepoDone = false;
  var _pageInputUrlDone = false;
  var _pageSshKeyDone = false;

  var pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String publicKey = "Generating ...";

  @override
  Widget build(BuildContext context) {
    var pageCount = 1;
    if (_pageInitalScreenDone) {
      pageCount++;
    }
    if (_pageCreateNewRepoDone) {
      pageCount++;
    }
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
          return OnBoardingInitialChoice(
            onCreateNewRepo: () {
              setState(() {
                _createNewRepo = true;
                _pageInitalScreenDone = true;

                pageController.nextPage(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                );
              });
            },
            onExistingRepo: () {
              setState(() {
                _createNewRepo = false;
                _pageInitalScreenDone = true;

                pageController.nextPage(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                );
              });
            },
          );
        }

        if (pos == 1 && _createNewRepo) {
          return OnBoardingCreateRepo(
            onDone: () {
              setState(() {
                _createNewRepo = true;
                _pageCreateNewRepoDone = true;

                pageController.nextPage(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                );
              });
            },
          );
        }

        if ((pos == 2 && _createNewRepo) || pos == 1) {
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

            getAnalytics().logEvent(
              name: "onboarding_git_url_enterred",
              parameters: <String, dynamic>{},
            );
          });
        }
        if ((pos == 3 && _createNewRepo) || pos == 2) {
          return OnBoardingSshKey(
            doneFunction: () {
              setPageSshKeyDone();
              pageController.nextPage(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeIn,
              );

              getAnalytics().logEvent(
                name: "onboarding_public_key_copied",
                parameters: <String, dynamic>{},
              );
            },
            publicKey: publicKey,
          );
        }

        if ((pos == 4 && _createNewRepo) || pos == 3) {
          return OnBoardingGitClone(
            doneFunction: () {
              getAnalytics().logEvent(
                name: "onboarding_complete",
                parameters: <String, dynamic>{},
              );
              this.widget.onBoardingCompletedFunction();
            },
          );
        }
      },
      itemCount: pageCount,
      onPageChanged: (int pageNum) {
        print("PageView onPageChanged: " + pageNum.toString());
        String pageName = "";
        switch (pageNum) {
          case 0:
            pageName = "OnBoardingGitUrl";
            break;

          case 1:
            pageName = "OnBoardingSshKey";
            break;

          case 2:
            pageName = "OnBoardingGitClone";
            break;
        }
        getAnalytics().logEvent(
          name: "onboarding_page_changed",
          parameters: <String, dynamic>{
            'page_num': pageNum,
            'page_name': pageName,
          },
        );
      },
    );

    return new Scaffold(
      key: _scaffoldKey,
      body: new Container(
        width: double.infinity,
        height: double.infinity,
        //color: Theme.of(context).primaryColor,
        child: pageView,
        padding: EdgeInsets.all(16.0),
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

class OnBoardingInitialChoice extends StatelessWidget {
  final Function onCreateNewRepo;
  final Function onExistingRepo;

  OnBoardingInitialChoice({
    @required this.onCreateNewRepo,
    @required this.onExistingRepo,
  });

  @override
  Widget build(BuildContext context) {
    var headerTextStyle =
        Theme.of(context).textTheme.display3.copyWith(fontFamily: "Lato");
    var header = Row(
      children: <Widget>[
        Image.asset(
          'assets/icon/icon.png',
          height: 200,
          fit: BoxFit.fill,
        ),
        SizedBox(width: 24.0),
        Text(
          "GitJournal",
          style: headerTextStyle,
        ),
      ],
    );

    return Container(
      child: Column(
        children: <Widget>[
          header,
          SizedBox(height: 64.0),
          Text(
            "We need a Git Repo to store the data -",
            style: Theme.of(context).textTheme.headline,
          ),
          SizedBox(height: 8.0),
          SizedBox(
            width: double.infinity,
            child: RaisedButton(
              child: Text(
                "Create a Rew Repo",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.button,
              ),
              color: Theme.of(context).primaryColor,
              onPressed: onCreateNewRepo,
            ),
          ),
          SizedBox(height: 8.0),
          SizedBox(
            width: double.infinity,
            child: RaisedButton(
              child: Text(
                "I already have one",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.button,
              ),
              color: Theme.of(context).primaryColor,
              onPressed: onExistingRepo,
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}

class OnBoardingCreateRepo extends StatelessWidget {
  final Function onDone;

  OnBoardingCreateRepo({@required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            "Select a provider -",
            style: Theme.of(context).textTheme.headline,
          ),
          SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            child: RaisedButton.icon(
              label: Text(
                "GitHub",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.button,
              ),
              icon: Image.asset(
                'assets/icon/github-icon.png',
                width: 32,
                height: 32,
              ),
              color: Theme.of(context).primaryColor,
              onPressed: () async {
                try {
                  await launch("https://github.com/new");
                } catch (err, stack) {
                  // FIXME: Error handling?
                  print(err);
                  print(stack);
                }
                onDone();
              },
            ),
          ),
          SizedBox(height: 8.0),
          SizedBox(
            width: double.infinity,
            child: RaisedButton.icon(
              label: Text(
                "GitLab",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.button,
              ),
              icon: Image.asset(
                'assets/icon/gitlab-icon.png',
                width: 32,
                height: 32,
              ),
              color: Theme.of(context).primaryColor,
              onPressed: () async {
                try {
                  await launch("https://gitlab.com/projects/new");
                } catch (err, stack) {
                  // FIXME: Error handling?
                  print(err);
                  print(stack);
                }
                onDone();
              },
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Deploy Public Key',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.display1,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          color: Theme.of(context).primaryColorLight,
          child: Text(
            publicKey,
            textAlign: TextAlign.left,
            maxLines: 20,
            style: Theme.of(context).textTheme.body1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RaisedButton(
            child: Text("Start Clone"),
            onPressed: this.doneFunction,
          ),
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
