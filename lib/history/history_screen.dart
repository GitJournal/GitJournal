/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';

import 'package:dart_git/dart_git.dart';
import 'package:dart_git/plumbing/commit_iterator.dart';
import 'package:flutter/material.dart';
import 'package:gitjournal/app_localizations_context.dart';
import 'package:gitjournal/folder_views/folder_view.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/sync_attempt.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:synchronized/synchronized.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeline_tile/timeline_tile.dart';

import 'commit_data_widget.dart';

class HistoryScreen extends StatelessWidget {
  static const String routePath = "/history";

  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var gjRepo = Provider.of<GitJournalRepo>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.drawerHistory),
      ),
      body: HistoryWidget(gjRepo: gjRepo),
      drawer: AppDrawer(),
    );
  }
}

class HistoryWidget extends StatefulWidget {
  final GitJournalRepo gjRepo;

  String get repoPath => gjRepo.repoPath;

  const HistoryWidget({super.key, required this.gjRepo});

  @override
  _HistoryWidgetState createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  final List<Result<GitCommit>> _commits = [];
  List<dynamic> _commitsAndSyncAttempts = [];

  Iterable<Result<GitCommit>>? _stream;

  final _scrollController = ScrollController();
  final _lock = Lock();

  Exception? _exception;
  GitRepository? _gitRepo;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      var mq = MediaQuery.maybeOf(context);
      var before = 200.0;
      if (mq != null) {
        before = mq.size.height / 1.5;
      }
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - before) {
        _loadMore();
      }
    });

    _loadMore();

    widget.gjRepo.addListener(_rebuild);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    widget.gjRepo.removeListener(_rebuild);

    super.dispose();
  }

  void _rebuild() {
    setState(() {
      _rebuildCombined();
    });
  }

  Future<void> _loadMore() async {
    // This needs to happen in another thread!
    await _lock.synchronized(() async {
      _stream ??= await _initStream();
      var stream = _stream!;

      var list = <Result<GitCommit>>[];
      for (var commit in stream.take(20)) {
        list.add(commit);
      }

      setState(() {
        _commits.addAll(list);
        _rebuildCombined();
      });
    });
  }

  Future<Iterable<Result<GitCommit>>> _initStream() async {
    try {
      _gitRepo = GitRepository.load(widget.repoPath).getOrThrow();
      var head = _gitRepo!.headHash().getOrThrow();
      return commitPreOrderIterator(
          objStorage: _gitRepo!.objStorage, from: head);
    } on Exception catch (ex) {
      setState(() {
        _exception = ex;
      });
    }

    return [];
  }

  void _rebuildCombined() {
    _commitsAndSyncAttempts = [];
    _commitsAndSyncAttempts.addAll(widget.gjRepo.syncAttempts);
    _commitsAndSyncAttempts.addAll(_commits);
    _commitsAndSyncAttempts.sort((a, b) {
      late DateTime aDt;
      if (a is SyncAttempt) {
        aDt = a.when;
      } else if (a is Result<GitCommit>) {
        if (a.isSuccess) {
          aDt = a.getOrThrow().author.date;
        } else {
          aDt = DateTime.now(); // WTF, am I supposed to do in this case?
        }
      } else {
        assert(false, "Something else is stored in History - ${a.runtimeType}");
      }

      late DateTime bDt;
      if (b is SyncAttempt) {
        bDt = b.when;
      } else if (b is Result<GitCommit>) {
        if (b.isSuccess) {
          bDt = b.getOrThrow().author.date;
        } else {
          bDt = DateTime.now(); // WTF, am I supposed to do in this case?
        }
      } else {
        assert(false, "Something else is stored in History - ${b.runtimeType}");
      }

      return bDt.compareTo(aDt);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_exception != null) {
      return _FailureTile(result: Result.fail(_exception!));
    }

    var extra = _lock.locked ? 1 : 0;
    return Scrollbar(
      child: RefreshIndicator(
        child: ListView.builder(
          controller: _scrollController,
          itemBuilder: _buildTile,
          itemCount: _commitsAndSyncAttempts.length + extra,
        ),
        onRefresh: () => syncRepo(context),
      ),
    );
  }

  Widget _buildTile(BuildContext context, int i) {
    if (i >= _commitsAndSyncAttempts.length) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    var d = _commitsAndSyncAttempts[i];
    if (d is SyncAttempt) {
      return _SyncAttemptTile(d);
    }

    assert(d is Result<GitCommit>);

    var commitR = d as Result<GitCommit>;
    Result<GitCommit>? parentCommitR;
    for (var j = i + 1; j < _commitsAndSyncAttempts.length; j++) {
      var dd = _commitsAndSyncAttempts[j];
      if (dd is Result<GitCommit>) {
        parentCommitR = dd;
        break;
      }
    }

    return _buildCommitTile(context, commitR, parentCommitR);
  }

  Widget _buildCommitTile(
    BuildContext context,
    Result<GitCommit> commitR,
    Result<GitCommit>? parentCommitR,
  ) {
    if (parentCommitR == null) {
      return commitR.isSuccess
          ? _CommitTile(
              commit: commitR.getOrThrow(),
              prevCommit: null,
              gitRepo: _gitRepo!,
            )
          : _FailureTile(result: commitR);
    }

    try {
      return _CommitTile(
        gitRepo: _gitRepo!,
        commit: commitR.getOrThrow(),
        prevCommit: parentCommitR.getOrThrow(),
      );
    } catch (ex, st) {
      return _FailureTile(result: Result.fail(ex, st));
    }
  }
}

class _SyncAttemptTile extends StatelessWidget {
  final SyncAttempt attempt;

  const _SyncAttemptTile(this.attempt);

  @override
  Widget build(BuildContext context) {
    var lastPart = attempt.parts.last;
    return TimelineTile(
      indicatorStyle: const IndicatorStyle(
        width: 15,
        color: Colors.green,
        padding: EdgeInsets.all(4.0),
        indicatorXY: 0.0,
      ),
      endChild: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('${lastPart.status} ${lastPart.when}'),
      ),
      beforeLineStyle: const LineStyle(color: Colors.green),
    );
  }
}

class _CommitTile extends StatefulWidget {
  final GitRepository gitRepo;
  final GitCommit commit;
  final GitCommit? prevCommit;

  const _CommitTile({
    required this.gitRepo,
    required this.commit,
    required this.prevCommit,
  });

  @override
  State<_CommitTile> createState() => _CommitTileState();
}

class _CommitTileState extends State<_CommitTile> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    var msgLines = LineSplitter.split(widget.commit.message).toList();
    var title = msgLines.first;

    var textTheme = Theme.of(context).textTheme;

    Locale locale = Localizations.localeOf(context);
    var when =
        timeago.format(widget.commit.author.date, locale: locale.languageCode);

    Widget body = Row(
      children: <Widget>[
        Expanded(
          child: Text(title, style: textTheme.subtitle2!),
        ),
        Text(when, style: textTheme.caption)
      ],
      // crossAxisAlignment: CrossAxisAlignment.baseline,
      // textBaseline: TextBaseline.alphabetic,
    );

    if (expanded && widget.prevCommit != null) {
      body = Column(
        children: [
          body,
          CommitDataWidget(
            gitRepo: widget.gitRepo,
            commit: widget.commit,
            parentCommit: widget.prevCommit!,
          ),
        ],
        mainAxisSize: MainAxisSize.min,
      );
    }

    return GestureDetector(
      child: TimelineTile(
        indicatorStyle: const IndicatorStyle(
          width: 15,
          color: Colors.black,
          padding: EdgeInsets.all(4.0),
          indicatorXY: 0.0,
        ),
        endChild: Card(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: body,
        )),
        beforeLineStyle: const LineStyle(color: Colors.black),
      ),
      onTap: () {
        setState(() {
          expanded = !expanded;
        });
      },
    );
  }
}

class _FailureTile<T> extends StatelessWidget {
  final Result<T> result;

  _FailureTile({super.key, required this.result}) {
    Log.e("Failure", ex: result.error, stacktrace: result.stackTrace);
  }

  @override
  Widget build(BuildContext context) {
    return Text(result.error.toString());
  }
}

// Extra info -
// * Has this commit been pushed, failed to sync
// * Title
// * (rest of the message - optionally)
// * Time
// * Author
// * Files + changes

// class _ExpandedCommitTile extends StatelessWidget {
//   const _ExpandedCommitTile({super.key}) ;

//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

// * Do a diff of files changed
// * Show added / removed easily
// * Show modified with a kind of whatever
