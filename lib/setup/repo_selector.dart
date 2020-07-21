import 'package:flutter/material.dart';
import 'package:function_types/function_types.dart';

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/apis/githost_factory.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/utils/logger.dart';
import 'package:intl/intl.dart';

import 'button.dart';
import 'error.dart';
import 'loading.dart';

class GitHostSetupRepoSelector extends StatefulWidget {
  final GitHost gitHost;
  final Func1<GitHostRepo, void> onDone;

  GitHostSetupRepoSelector({
    @required this.gitHost,
    @required this.onDone,
  });

  @override
  GitHostSetupRepoSelectorState createState() {
    return GitHostSetupRepoSelectorState();
  }
}

class GitHostSetupRepoSelectorState extends State<GitHostSetupRepoSelector> {
  String errorMessage = "";

  List<GitHostRepo> repos = [];
  var fetchedRepos = false;

  GitHostRepo selectedRepo;
  var _textController = TextEditingController();
  bool createRepo = false;

  @override
  void initState() {
    super.initState();

    _textController.addListener(() {
      setState(() {
        selectedRepo = null;
        createRepo = false;
      });
    });
    _initStateAysnc();
  }

  void _initStateAysnc() async {
    Log.d("Starting RepoSelector");

    try {
      var allRepos = await widget.gitHost.listRepos();
      allRepos.sort((GitHostRepo a, GitHostRepo b) {
        if (a.updatedAt != null && b.updatedAt != null) {
          return a.updatedAt.compareTo(b.updatedAt);
        }
        if (a.updatedAt == null && b.updatedAt == null) {
          return a.fullName.compareTo(b.fullName);
        }
        if (a.updatedAt == null) {
          return 1;
        }
        return -1;
      });

      if (!mounted) return;
      setState(() {
        repos = allRepos.reversed.toList();
        fetchedRepos = true;
      });

      var repo = repos.firstWhere(
        (r) => r.fullName.endsWith('/journal'),
        orElse: () => null,
      );
      if (repo != null) {
        setState(() {
          selectedRepo = repo;
        });
      } else {
        setState(() {
          _textController.text = "journal";
          createRepo = true;
        });
      }
    } on Exception catch (e, stacktrace) {
      _handleGitHostException(e, stacktrace);
      return;
    }
  }

  void _handleGitHostException(Exception e, StackTrace stacktrace) {
    Log.d("GitHostSetupAutoConfigure: " + e.toString());
    setState(() {
      errorMessage = e.toString();
      getAnalytics().logEvent(
        name: "githostsetup_error",
        parameters: <String, String>{
          'errorMessage': errorMessage,
        },
      );

      logException(e, stacktrace);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null && errorMessage.isNotEmpty) {
      return GitHostSetupErrorPage(errorMessage);
    }
    if (!fetchedRepos) {
      return GitHostSetupLoadingPage("Loading");
    }

    var q = _textController.text.toLowerCase();
    var filteredRepos = repos.where((r) {
      var repoName = r.fullName.split('/').last;
      return repoName.toLowerCase().contains(q);
    });

    var repoBuilder = ListView(
      children: <Widget>[
        if (_textController.text.isNotEmpty) _buildCreateRepoTile(),
        for (var repo in filteredRepos) _buildRepoTile(repo),
      ],
      padding: const EdgeInsets.all(0.0),
    );

    // Add a Filtering bar
    // text: Type to search or create
    var textField = TextField(
      controller: _textController,
      maxLines: 1,
      decoration: InputDecoration(
        hintText: 'Type to Search or Create a Repo',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          onPressed: () => _textController.clear(),
          icon: const Icon(Icons.clear),
        ),
      ),
    );

    bool canContinue = selectedRepo != null || createRepo;
    var columns = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Choose or create a repository -',
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 16.0),
        textField,
        const SizedBox(height: 8.0),
        Expanded(child: repoBuilder),
        const SizedBox(height: 8.0),
        Opacity(
          opacity: canContinue ? 1.0 : 0.0,
          child: GitHostSetupButton(
            text: "Next",
            onPressed: () async {
              if (selectedRepo != null) {
                widget.onDone(selectedRepo);
                return;
              }

              try {
                var repoName = _textController.text.trim();
                var repo = await widget.gitHost.createRepo(repoName);
                widget.onDone(repo);
                return;
              } catch (e, stacktrace) {
                _handleGitHostException(e, stacktrace);
              }
            },
          ),
        ),
        const SizedBox(height: 32.0),
      ],
    );

    return SafeArea(child: Center(child: columns));
  }

  Widget _buildRepoTile(GitHostRepo repo) {
    final _dateFormat = DateFormat('dd MMM, yyyy');

    Widget trailing = Container();
    if (repo.updatedAt != null) {
      var dateStr = _dateFormat.format(repo.updatedAt);

      var textTheme = Theme.of(context).textTheme;
      trailing = Text(dateStr, style: textTheme.caption);
    }

    return ListTile(
      title: Text(repo.fullName),
      trailing: trailing,
      selected: repo == selectedRepo,
      onTap: () {
        setState(() {
          selectedRepo = repo;
          createRepo = false;
        });
      },
      contentPadding: const EdgeInsets.all(0.0),
    );
  }

  Widget _buildCreateRepoTile() {
    var repoName = _textController.text.trim();

    return ListTile(
      leading: const Icon(Icons.add),
      title: Text('Create repo "$repoName"'),
      contentPadding: const EdgeInsets.all(0.0),
      onTap: () {
        setState(() {
          createRepo = true;
          selectedRepo = null;
        });
      },
      selected: createRepo,
    );
  }
}
