import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:path/path.dart' as p;
import 'package:dots_indicator/dots_indicator.dart';

import 'package:journal/analytics.dart';
import 'package:journal/state_container.dart';
import 'package:journal/apis/git.dart';

import 'package:journal/screens/onboarding_git_url.dart';
import 'package:journal/screens/onboarding_git_clone.dart';

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

  var _gitCloneUrl = "";
  String gitCloneErrorMessage = "";

  var pageController = PageController();
  int _currentPageIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String publicKey = "";
  bool _canLaunchDeployKeyPage = false;

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

            // We aren't calling setState as this isn't being used for rendering
            _gitCloneUrl = sshUrl.trim();

            this._generateSshKey();

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

              var appState = StateContainer.of(context).appState;
              _startGitClone(appState.gitBaseDirectory);

              getAnalytics().logEvent(
                name: "onboarding_public_key_copied",
                parameters: <String, dynamic>{},
              );
            },
            publicKey: publicKey,
            copyKeyFunction: _copyKeyToClipboard,
            openDeployKeyPage: _launchDeployKeyPage,
            canOpenDeployKeyPage: _canLaunchDeployKeyPage,
          );
        }

        if ((pos == 4 && _createNewRepo) || pos == 3) {
          return OnBoardingGitClone(errorMessage: gitCloneErrorMessage);
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

        setState(() {
          _currentPageIndex = pageNum;
        });
      },
    );

    var scaffold = new Scaffold(
      key: _scaffoldKey,
      body: new Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: FractionalOffset.bottomCenter,
          children: <Widget>[
            pageView,
            new DotsIndicator(
              numberOfDot: pageCount,
              position: _currentPageIndex,
              dotActiveColor: Theme.of(context).primaryColorDark,
            )
          ],
        ),
        padding: EdgeInsets.all(16.0),
      ),
    );

    return new WillPopScope(
      onWillPop: () {
        if (_currentPageIndex != 0) {
          pageController.previousPage(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
        } else {
          Navigator.pop(context);
        }
      },
      child: scaffold,
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
    generateSSHKeys(comment: "GitJournal").then((String publicKey) {
      setState(() {
        this.publicKey = publicKey;
        this._canLaunchDeployKeyPage =
            _gitCloneUrl.startsWith("git@github.com:") ||
                _gitCloneUrl.startsWith("git@gitlab.com:");

        _copyKeyToClipboard();
      });
    });
  }

  void _copyKeyToClipboard() {
    Clipboard.setData(ClipboardData(text: publicKey));
    var text = "Public Key copied to Clipboard";
    this._scaffoldKey.currentState
      ..removeCurrentSnackBar()
      ..showSnackBar(new SnackBar(content: new Text(text)));
  }

  void _launchDeployKeyPage() async {
    var lastIndex = _gitCloneUrl.lastIndexOf(".git");
    if (lastIndex == -1) {
      lastIndex = _gitCloneUrl.length;
    }

    var repoName =
        _gitCloneUrl.substring(_gitCloneUrl.lastIndexOf(":") + 1, lastIndex);

    final gitHubUrl = 'https://github.com/' + repoName + '/settings/keys/new';
    final gitLabUrl = 'https://gitlab.com/' + repoName + '/settings/repository';

    try {
      if (_gitCloneUrl.startsWith("git@github.com:")) {
        await launch(gitHubUrl);
      } else if (_gitCloneUrl.startsWith("git@gitlab.com:")) {
        await launch(gitLabUrl);
      }
    } catch (err, stack) {
      print('_launchDeployKeyPage: ' + err.toString());
      print(stack.toString());
    }
  }

  void _startGitClone(String basePath) async {
    // Just in case it was half cloned because of an error
    await _removeExistingClone(basePath);

    String error = await gitClone(_gitCloneUrl, "journal");
    if (error != null && error.isNotEmpty) {
      setState(() {
        getAnalytics().logEvent(
          name: "onboarding_gitClone_error",
          parameters: <String, dynamic>{
            'error': error,
          },
        );
        gitCloneErrorMessage = error;
      });
    } else {
      getAnalytics().logEvent(
        name: "onboarding_complete",
        parameters: <String, dynamic>{},
      );
      this.widget.onBoardingCompletedFunction();
    }
  }

  Future _removeExistingClone(String baseDirPath) async {
    var baseDir = new Directory(baseDirPath);
    var dotGitDir = new Directory(p.join(baseDir.path, "journal", ".git"));
    bool exists = await dotGitDir.exists();
    if (exists) {
      await baseDir.delete(recursive: true);
      await baseDir.create();
    }
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
    FocusScope.of(context).requestFocus(new FocusNode());

    var headerTextStyle =
        Theme.of(context).textTheme.display3.copyWith(fontFamily: "Lato");
    var header = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'assets/icon/icon.png',
          height: 200,
          fit: BoxFit.fill,
        ),
        SizedBox(height: 8.0),
        Text(
          "GitJournal",
          style: headerTextStyle,
        ),
      ],
    );

    return Container(
      child: Column(
        children: <Widget>[
          Center(child: header),
          SizedBox(height: 64.0),
          Text(
            "We need a Git Repo to store the data -",
            style: Theme.of(context).textTheme.headline,
          ),
          SizedBox(height: 8.0),
          OnBoardingButton(
            text: "Create a New Repo",
            onPressed: onCreateNewRepo,
          ),
          SizedBox(height: 8.0),
          OnBoardingButton(
            text: "I already have one",
            onPressed: onExistingRepo,
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
    FocusScope.of(context).requestFocus(new FocusNode());

    return Container(
      child: Column(
        children: <Widget>[
          Text(
            "Select a provider -",
            style: Theme.of(context).textTheme.headline,
          ),
          SizedBox(height: 16.0),
          OnBoardingButton(
            text: "GitHub",
            iconUrl: 'assets/icon/github-icon.png',
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
          SizedBox(height: 8.0),
          OnBoardingButton(
            text: "GitLab",
            iconUrl: 'assets/icon/gitlab-icon.png',
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
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}

class OnBoardingSshKey extends StatelessWidget {
  final Function doneFunction;
  final Function copyKeyFunction;
  final String publicKey;

  final Function openDeployKeyPage;
  final bool canOpenDeployKeyPage;

  OnBoardingSshKey({
    @required this.doneFunction,
    @required this.copyKeyFunction,
    @required this.openDeployKeyPage,
    @required this.publicKey,
    @required this.canOpenDeployKeyPage,
  });

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());

    Widget copyAndDepoyWidget;
    Widget cloneButton;
    if (this.publicKey.isEmpty) {
      copyAndDepoyWidget = Container();
      cloneButton = Container();
    } else {
      cloneButton = OnBoardingButton(
        text: "Clone Repo",
        onPressed: this.doneFunction,
      );

      if (canOpenDeployKeyPage) {
        copyAndDepoyWidget = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: RaisedButton(
                child: Text(
                  "Copy Key",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.button,
                ),
                color: Theme.of(context).primaryColor,
                onPressed: copyKeyFunction,
              ),
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: RaisedButton(
                child: Text(
                  "Open Deploy Key Webpage",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.button,
                ),
                color: Theme.of(context).primaryColor,
                onPressed: openDeployKeyPage,
              ),
            ),
          ],
        );
      } else {
        copyAndDepoyWidget = OnBoardingButton(
          text: "Copy Key",
          onPressed: this.copyKeyFunction,
        );
      }
    }

    String publicKeyStr = "";
    if (this.publicKey == null || this.publicKey.isEmpty) {
      publicKeyStr = "Generating ...";
    } else {
      publicKeyStr = this.publicKey;
    }

    var publicKeyWidget = SizedBox(
      width: double.infinity,
      height: 160.0,
      child: Container(
        color: Theme.of(context).buttonColor,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              publicKeyStr,
              textAlign: TextAlign.left,
              maxLines: null,
              style: Theme.of(context).textTheme.body1,
            ),
          ),
        ),
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Deploy Public Key',
          style: Theme.of(context).textTheme.headline,
        ),
        SizedBox(height: 16.0),
        publicKeyWidget,
        SizedBox(height: 8.0),
        copyAndDepoyWidget,
        cloneButton,
      ],
    );
  }
}
