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
import 'githostsetup_button.dart';
import 'githostsetup_clone.dart';
import 'githostsetup_clone_url.dart';

class GitHostSetupScreen extends StatefulWidget {
  final Function onCompletedFunction;

  GitHostSetupScreen(this.onCompletedFunction);

  @override
  GitHostSetupScreenState createState() {
    return GitHostSetupScreenState();
  }
}

enum PageChoice0 { Unknown, KnownProvider, CustomProvider }
enum PageChoice1 { Unknown, Manual, Auto }

class GitHostSetupScreenState extends State<GitHostSetupScreen> {
  var _pageCount = 1;

  var _pageChoice = [
    PageChoice0.Unknown,
    PageChoice1.Unknown,
  ];

  GitHostType _gitHostType = GitHostType.Unknown;

  var _gitCloneUrl = "";
  String gitCloneErrorMessage = "";

  String publicKey = "";
  bool _canLaunchDeployKeyPage = false;

  var pageController = PageController();
  int _currentPageIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildPage(BuildContext context, int pos) {
    print("_buildPage " + pos.toString());
    assert(_pageCount >= 1);

    if (pos == 0) {
      return GitHostChoicePage(
        onKnownGitHost: (GitHostType gitHostType) {
          setState(() {
            _gitHostType = gitHostType;
            _pageChoice[0] = PageChoice0.KnownProvider;
            _pageCount = pos + 2;
            _nextPage();
          });
        },
        onCustomGitHost: () {
          setState(() {
            _pageChoice[0] = PageChoice0.CustomProvider;
            _pageCount = pos + 2;
            _nextPage();
          });
        },
      );
    }

    if (pos == 1) {
      assert(_pageChoice[0] != PageChoice0.Unknown);

      if (_pageChoice[0] == PageChoice0.CustomProvider) {
        return GitCloneUrlPage(doneFunction: (String sshUrl) {
          setState(() {
            _gitCloneUrl = sshUrl;

            _pageCount = pos + 2;
            _nextPage();
            _generateSshKey();
          });
        });
      }

      return GitHostAutoConfigureChoicePage(
        onDone: (GitHostSetupType setupType) {
          if (setupType == GitHostSetupType.Manual) {
            setState(() {
              _pageCount = pos + 2;
              _pageChoice[1] = PageChoice1.Manual;
              _nextPage();
            });
          } else if (setupType == GitHostSetupType.Auto) {
            setState(() {
              _pageCount = pos + 2;
              _pageChoice[1] = PageChoice1.Auto;
              _nextPage();
            });
          }
        },
      );
    }

    if (pos == 2) {
      if (_pageChoice[0] == PageChoice0.CustomProvider) {
        return GitHostSetupSshKey(
          doneFunction: () {
            setState(() {
              _pageCount = pos + 2;
              _nextPage();
              _startGitClone(context);
            });
          },
          publicKey: publicKey,
          copyKeyFunction: _copyKeyToClipboard,
          openDeployKeyPage: _launchDeployKeyPage,
          canOpenDeployKeyPage: _canLaunchDeployKeyPage,
        );
      }

      assert(_pageChoice[1] != PageChoice1.Unknown);

      if (_pageChoice[1] == PageChoice1.Manual) {
        return GitCloneUrlKnownProviderPage(
          doneFunction: (String sshUrl) {
            setState(() {
              _pageCount = pos + 2;
              _gitCloneUrl = sshUrl;

              _nextPage();
              _generateSshKey();
            });
          },
          launchCreateUrlPage: _launchCreateRepoPage,
          gitHostType: _gitHostType,
        );
      } else if (_pageChoice[1] == PageChoice1.Auto) {
        return GitHostSetupAutoConfigure(
          gitHostType: _gitHostType,
          onDone: (String gitCloneUrl) {
            setState(() {
              _gitCloneUrl = gitCloneUrl;
              _pageCount = pos + 2;

              _nextPage();
              _startGitClone(context);
            });
          },
        );
      }
    }

    if (pos == 3) {
      if (_pageChoice[0] == PageChoice0.CustomProvider) {
        return GitHostSetupGitClone(errorMessage: gitCloneErrorMessage);
      }

      if (_pageChoice[1] == PageChoice1.Manual) {
        // FIXME: Create a new page with better instructions
        return GitHostSetupSshKey(
          doneFunction: () {
            setState(() {
              _pageCount = 6;

              _nextPage();
              _startGitClone(context);
            });
          },
          publicKey: publicKey,
          copyKeyFunction: _copyKeyToClipboard,
          openDeployKeyPage: _launchDeployKeyPage,
          canOpenDeployKeyPage: _canLaunchDeployKeyPage,
        );
      } else if (_pageChoice[1] == PageChoice1.Auto) {
        return GitHostSetupGitClone(errorMessage: gitCloneErrorMessage);
      }

      assert(false);
    }

    assert(_pageChoice[0] != PageChoice0.CustomProvider);

    if (pos == 4) {
      if (_pageChoice[1] == PageChoice1.Manual) {
        return GitHostSetupGitClone(errorMessage: gitCloneErrorMessage);
      }
    }

    assert(false);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    print("build _pageCount " + _pageCount.toString());
    print("build _currentPageIndex " + _currentPageIndex.toString());

    var pageView = PageView.builder(
      controller: pageController,
      itemBuilder: _buildPage,
      itemCount: _pageCount,
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
          _pageCount = _currentPageIndex + 1;
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
              numberOfDot: _pageCount,
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

  void _nextPage() {
    pageController.nextPage(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
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

  void _launchCreateRepoPage() async {
    assert(_gitHostType != GitHostType.Unknown);

    try {
      if (_gitHostType == GitHostType.GitHub) {
        await launch("https://github.com/new");
      } else if (_gitHostType == GitHostType.GitLab) {
        await launch("https://gitlab.com/projects/new");
      }
    } catch (err, stack) {
      // FIXME: Error handling?
      print("_launchCreateRepoPage: " + err.toString());
      print(stack);
    }
  }

  void _startGitClone(BuildContext context) async {
    var appState = StateContainer.of(context).appState;
    var basePath = appState.gitBaseDirectory;

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

class GitHostChoicePage extends StatelessWidget {
  final Function onKnownGitHost;
  final Function onCustomGitHost;

  GitHostChoicePage({
    @required this.onKnownGitHost,
    @required this.onCustomGitHost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            "Select a Git Hosting Provider -",
            style: Theme.of(context).textTheme.headline,
          ),
          SizedBox(height: 16.0),
          GitHostSetupButton(
            text: "GitHub",
            iconUrl: 'assets/icon/github-icon.png',
            onPressed: () {
              onKnownGitHost(GitHostType.GitHub);
            },
          ),
          SizedBox(height: 8.0),
          GitHostSetupButton(
            text: "GitLab",
            iconUrl: 'assets/icon/gitlab-icon.png',
            onPressed: () async {
              onKnownGitHost(GitHostType.GitLab);
            },
          ),
          SizedBox(height: 8.0),
          GitHostSetupButton(
            text: "Custom",
            onPressed: () async {
              onCustomGitHost();
            },
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}

enum GitHostSetupType {
  Auto,
  Manual,
}

class GitHostAutoConfigureChoicePage extends StatelessWidget {
  final Function onDone;

  GitHostAutoConfigureChoicePage({@required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            "How do you want to do this?",
            style: Theme.of(context).textTheme.headline,
          ),
          SizedBox(height: 16.0),
          GitHostSetupButton(
            text: "Setup everything automatically",
            onPressed: () {
              onDone(GitHostSetupType.Auto);
            },
          ),
          SizedBox(height: 8.0),
          GitHostSetupButton(
            text: "Let me do it manually",
            onPressed: () async {
              onDone(GitHostSetupType.Manual);
            },
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
