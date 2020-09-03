import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:function_types/function_types.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/apis/githost_factory.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/setup/button.dart';
import 'package:gitjournal/setup/error.dart';
import 'package:gitjournal/setup/loading.dart';
import 'package:gitjournal/utils/logger.dart';

//import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      logEvent(Event.GitHostSetupError, parameters: {
        'errorMessage': errorMessage,
      });

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

    Widget repoBuilder = ListView(
      children: <Widget>[
        if (_textController.text.isNotEmpty) _buildCreateRepoTile(),
        for (var repo in filteredRepos)
          _RepoTile(
            repo: repo,
            onTap: () {
              setState(() {
                selectedRepo = repo;
                createRepo = false;
              });
            },
            selected: repo == selectedRepo,
          ),
      ],
      padding: const EdgeInsets.all(0.0),
    );

    // Remove Overflow animation
    repoBuilder = NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (OverscrollIndicatorNotification overScroll) {
        overScroll.disallowGlow();
        return false;
      },
      child: repoBuilder,
    );

    // Add a Filtering bar
    // text: Type to search or create
    var textField = TextField(
      controller: _textController,
      maxLines: 1,
      decoration: InputDecoration(
        hintText: tr('setup.repoSelector.hint'),
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
          tr('setup.repoSelector.title'),
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
            text: tr('setup.next'),
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

  Widget _buildCreateRepoTile() {
    var repoName = _textController.text.trim();

    return ListTile(
      leading: const Icon(Icons.add),
      title: Text(tr('setup.repoSelector.create', args: [repoName])),
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

class _RepoTile extends StatelessWidget {
  final GitHostRepo repo;
  final Function onTap;
  final bool selected;

  _RepoTile({
    @required this.repo,
    @required this.onTap,
    @required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;

    /*
    var iconsRow = Row(
      children: [
        if (repo.license != null)
          _IconText(repo.license, FontAwesomeIcons.balanceScale),
        if (repo.license != null) const SizedBox(width: 8.0),
        _IconText(repo.forks.toString(), FontAwesomeIcons.codeBranch),
        const SizedBox(width: 8.0),
        _IconText(repo.stars.toString(), FontAwesomeIcons.star),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );

    return Card(
      margin: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
      elevation: 0.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              repo.fullName,
              style:
                  textTheme.headline6.copyWith(color: theme.primaryColorDark),
            ),
            if (repo.description != null) const SizedBox(height: 8.0),
            if (repo.description != null) Text(repo.description),
            const SizedBox(height: 16.0),
            iconsRow,
          ],
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ),
    ); */

    return ListTile(
      title: Text(repo.fullName),
      trailing: _SmartDateTime(repo.updatedAt, textTheme.caption),
      selected: selected,
      contentPadding: const EdgeInsets.all(0.0),
      onTap: onTap,
    );
  }
}

/*
class _IconText extends StatelessWidget {
  final String text;
  final IconData iconData;

  _IconText(this.text, this.iconData);

  @override
  Widget build(BuildContext context) {
    var iconTheme = Theme.of(context).iconTheme;
    var iconColor = iconTheme.color.withAlpha(150);
    var textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        FaIcon(iconData, size: 16, color: iconColor),
        const SizedBox(width: 4.0),
        Text(text, style: textTheme.caption),
      ],
      textBaseline: TextBaseline.alphabetic,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      mainAxisSize: MainAxisSize.min,
    );
  }
}
*/

class _SmartDateTime extends StatelessWidget {
  final DateTime dt;
  final TextStyle style;

  _SmartDateTime(this.dt, this.style);

  static final _dateFormat = DateFormat('d MMM yyyy');
  static final _dateFormatWithoutYear = DateFormat('d MMM');
  static final thirtyDaysAgo =
      DateTime.now().subtract(const Duration(days: 30));

  @override
  Widget build(BuildContext context) {
    if (dt == null) {
      return Container();
    }

    String text;

    if (dt.isAfter(thirtyDaysAgo)) {
      Locale locale = Localizations.localeOf(context);
      text = timeago.format(dt, locale: locale.languageCode);
    } else if (dt.year == DateTime.now().year) {
      text = _dateFormatWithoutYear.format(dt);
    } else {
      text = _dateFormat.format(dt);
    }

    return Text(text, style: style);
  }
}
