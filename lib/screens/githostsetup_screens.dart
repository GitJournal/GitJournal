import 'dart:io';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:journal/analytics.dart';
import 'package:journal/apis/git.dart';
import 'package:journal/apis/githost_factory.dart';
import 'package:journal/state_container.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import 'githostsetup_autoconfigure.dart';
import 'githostsetup_clone.dart';
import 'githostsetup_url.dart';

class GitHostSetupScreen extends StatefulWidget {
  final Function onCompletedFunction;

  GitHostSetupScreen(this.onCompletedFunction);

  @override
  GitHostSetupScreenState createState() {
    return GitHostSetupScreenState();
  }
}

class GitHostSetupScreenState extends State<GitHostSetupScreen> {
  var _createNewRepo = false;

  var _pageInitalScreenDone = false;
  var _pageCreateNewRepoDone = false;
  var _pageInputUrlDone = false;
  var _pageSshKeyDone = false;
  var _autoConfigureStarted = false;
  var _autoConfigureDone = false;
  GitHostType _gitHostType;

  var _gitCloneUrl = "";
  String gitCloneErrorMessage = "";

  var pageController = PageController();
  int _currentPageIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String publicKey = "";
  bool _canLaunchDeployKeyPage = false;

  @override
  Widget build(BuildContext context) {
    var pageCount = 1;
    if (_pageInitalScreenDone) {
      pageCount = 2;
    }
    if (_pageCreateNewRepoDone) {
      pageCount = 3;
    }
    if (_autoConfigureDone) {
      pageCount = 4;
    }
    if (_pageInputUrlDone) {
      pageCount++;
    }
    if (_pageSshKeyDone) {
      pageCount++;
    }
    print("_pageInitalScreenDone: " + _pageInitalScreenDone.toString());
    print("_pageCreateNewRepoDone: " + _pageCreateNewRepoDone.toString());
    print("_autoConfigureDone: " + _autoConfigureDone.toString());
    print("_pageInputUrlDone: " + _pageInputUrlDone.toString());
    print("_pageSshKeyDone: " + _pageSshKeyDone.toString());

    var pageView = PageView.builder(
      controller: pageController,
      itemBuilder: (BuildContext context, int pos) {
        if (pos == 0) {
          return GitHostSetupInitialChoice(
            onCreateNewRepo: () {
              setState(() {
                _createNewRepo = true;
                _pageInitalScreenDone = true;

                _autoConfigureStarted = false;
                _autoConfigureDone = false;
                _pageSshKeyDone = false;

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

                _autoConfigureStarted = false;
                _autoConfigureDone = false;
                _pageSshKeyDone = false;

                pageController.nextPage(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                );
              });
            },
          );
        }

        if (_createNewRepo) {
          if (pos == 1) {
            return GitHostSetupCreateRepo(
              onDone: (GitHostType gitHostType, bool autoConfigure) {
                if (!autoConfigure) {
                  _launchCreateRepoPage(gitHostType);
                }

                setState(() {
                  _createNewRepo = true;
                  _pageCreateNewRepoDone = true;
                  _autoConfigureStarted = autoConfigure;
                  _autoConfigureDone = false;
                  _gitHostType = gitHostType;

                  pageController.nextPage(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeIn,
                  );
                });
              },
            );
          }

          if (_autoConfigureStarted) {
            if (pos == 2) {
              return GitHostSetupAutoConfigure(
                gitHostType: _gitHostType,
                onDone: (String gitCloneUrl) {
                  setState(() {
                    _gitCloneUrl = gitCloneUrl;
                    _autoConfigureDone = true;

                    pageController.nextPage(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeIn,
                    );

                    var appState = StateContainer.of(context).appState;
                    _startGitClone(context, appState.gitBaseDirectory);
                  });
                },
              );
            }

            if (pos == 3 && _autoConfigureDone) {
              return GitHostSetupGitClone(errorMessage: gitCloneErrorMessage);
            }
          } else {
            if (pos == 2) {
              return GitHostSetupUrl(doneFunction: (String sshUrl) {
                setPageInputUrlDone();
                pageController.nextPage(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                );

                // We aren't calling setState as this isn't being used for rendering
                _gitCloneUrl = sshUrl.trim();

                this._generateSshKey();
              });
            }

            if (pos == 3) {
              return GitHostSetupSshKey(
                doneFunction: () {
                  setPageSshKeyDone();
                  pageController.nextPage(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeIn,
                  );

                  var appState = StateContainer.of(context).appState;
                  _startGitClone(context, appState.gitBaseDirectory);

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

            if (pos == 4) {
              return GitHostSetupGitClone(errorMessage: gitCloneErrorMessage);
            }
          }
        } // create new repo

        if (pos == 1) {
          return GitHostSetupUrl(doneFunction: (String sshUrl) {
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
        if (pos == 2) {
          return GitHostSetupSshKey(
            doneFunction: () {
              setPageSshKeyDone();
              pageController.nextPage(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeIn,
              );

              var appState = StateContainer.of(context).appState;
              _startGitClone(context, appState.gitBaseDirectory);

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

        if (pos == 3) {
          return GitHostSetupGitClone(errorMessage: gitCloneErrorMessage);
        }
      },
      itemCount: pageCount,
      onPageChanged: (int pageNum) {
        print("PageView onPageChanged: " + pageNum.toString());
        /*
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
        */

        setState(() {
          _currentPageIndex = pageNum;
        });
      },
    );

    var scaffold = Scaffold(
      key: _scaffoldKey,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: FractionalOffset.bottomCenter,
          children: <Widget>[
            pageView,
            DotsIndicator(
              numberOfDot: pageCount,
              position: _currentPageIndex,
              dotActiveColor: Theme.of(context).primaryColorDark,
            )
          ],
        ),
        padding: EdgeInsets.all(16.0),
      ),
    );

    return WillPopScope(
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
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _launchDeployKeyPage() async {
    var lastIndex = _gitCloneUrl.lastIndexOf(".git");
    if (lastIndex == -1) {
      lastIndex = _gitCloneUrl.length;
    }

    var repoName =
        _gitCloneUrl.substring(_gitCloneUrl.lastIndexOf(":") + 1, lastIndex);

    final gitHubUrl = 'https://github.com/' + repoName + '/settings/keys/new';
    final gitLabUrl = 'https://gitlab.com/' +
        repoName +
        '/settings/repository/#js-deploy-keys-settings';

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

  void _launchCreateRepoPage(GitHostType hostType) async {
    try {
      if (hostType == GitHostType.GitHub) {
        await launch("https://github.com/new");
      } else if (hostType == GitHostType.GitLab) {
        await launch("https://gitlab.com/projects/new");
      }
    } catch (err, stack) {
      // FIXME: Error handling?
      print("_launchCreateRepoPage: " + err.toString());
      print(stack);
    }
  }

  void _startGitClone(BuildContext context, String basePath) async {
    // Just in case it was half cloned because of an error
    await _removeExistingClone(basePath);

    String error;
    try {
      await gitClone(_gitCloneUrl, "journal");
    } catch (e) {
      error = e.message;
    }

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
      Navigator.pop(context);
      this.widget.onCompletedFunction();
    }
  }

  Future _removeExistingClone(String baseDirPath) async {
    var baseDir = Directory(p.join(baseDirPath, "journal"));
    var dotGitDir = Directory(p.join(baseDir.path, ".git"));
    bool exists = await dotGitDir.exists();
    if (exists) {
      print("Removing " + baseDir.path);
      await baseDir.delete(recursive: true);
      await baseDir.create();
    }
  }
}

class GitHostSetupInitialChoice extends StatelessWidget {
  final Function onCreateNewRepo;
  final Function onExistingRepo;

  GitHostSetupInitialChoice({
    @required this.onCreateNewRepo,
    @required this.onExistingRepo,
  });

  @override
  Widget build(BuildContext context) {
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
          GitHostSetupButton(
            text: "Create a New Repo",
            onPressed: onCreateNewRepo,
          ),
          SizedBox(height: 8.0),
          GitHostSetupButton(
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

class GitHostSetupCreateRepo extends StatefulWidget {
  final Function onDone;

  GitHostSetupCreateRepo({@required this.onDone});

  @override
  GitHostSetupCreateRepoState createState() {
    return GitHostSetupCreateRepoState();
  }
}

class GitHostSetupCreateRepoState extends State<GitHostSetupCreateRepo> {
  bool switchValue = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            "Select a Git hosting provider -",
            style: Theme.of(context).textTheme.headline,
          ),
          SizedBox(height: 16.0),
          GitHostSetupButton(
            text: "GitHub",
            iconUrl: 'assets/icon/github-icon.png',
            onPressed: () {
              print("SwitchValue: " + switchValue.toString());
              widget.onDone(GitHostType.GitHub, switchValue);
            },
          ),
          SizedBox(height: 8.0),
          GitHostSetupButton(
            text: "GitLab",
            iconUrl: 'assets/icon/gitlab-icon.png',
            onPressed: () async {
              widget.onDone(GitHostType.GitLab, switchValue);
            },
          ),
          SizedBox(height: 8.0),
          Row(
            children: <Widget>[
              Switch(
                value: switchValue,
                onChanged: (bool value) {
                  setState(() {
                    print("Changing switchValue " + value.toString());
                    switchValue = value;
                  });
                },
              ),
              Text(
                "Auto Configure",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline,
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.end,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}

class GitHostSetupSshKey extends StatelessWidget {
  final Function doneFunction;
  final Function copyKeyFunction;
  final String publicKey;

  final Function openDeployKeyPage;
  final bool canOpenDeployKeyPage;

  GitHostSetupSshKey({
    @required this.doneFunction,
    @required this.copyKeyFunction,
    @required this.openDeployKeyPage,
    @required this.publicKey,
    @required this.canOpenDeployKeyPage,
  });

  @override
  Widget build(BuildContext context) {
    Widget copyAndDepoyWidget;
    Widget cloneButton;
    if (this.publicKey.isEmpty) {
      copyAndDepoyWidget = Container();
      cloneButton = Container();
    } else {
      cloneButton = GitHostSetupButton(
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
        copyAndDepoyWidget = GitHostSetupButton(
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
