/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:dart_git/git.dart';
import 'package:dart_git/plumbing/commit_iterator.dart';
import 'package:dart_git/plumbing/objects/commit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:synchronized/synchronized.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/repository.dart';

class HistoryScreen extends StatelessWidget {
  static const String routePath = "/history";

  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var gjRepo = Provider.of<GitJournalRepo>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.drawer_history.tr()),
      ),
      body: HistoryWidget(repoPath: gjRepo.repoPath),
    );
  }
}

class HistoryWidget extends StatefulWidget {
  final String repoPath;

  const HistoryWidget({Key? key, required this.repoPath}) : super(key: key);

  @override
  _HistoryWidgetState createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  List<Result<GitCommit>> commits = [];
  Stream<Result<GitCommit>>? _stream;

  final _scrollController = ScrollController();
  final _lock = Lock();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMore();
      }
    });
    try {
      _loadMore();
    } catch (ex, st) {
      print(ex);
      print(st);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  Future<void> _loadMore() async {
    print('load more ...');

    // This needs to happen in another thread!
    await _lock.synchronized(() async {
      _stream ??= await _initStream();
      var stream = _stream!;

      var list = <Result<GitCommit>>[];
      for (var j = 0; j < 20; j++) {
        await for (var commit in stream) {
          list.add(commit);
        }
      }

      setState(() {
        commits.addAll(list);
      });
    });
  }

  Future<Stream<Result<GitCommit>>> _initStream() async {
    print('initializing the stream?');
    var repo = await GitRepository.load(widget.repoPath).getOrThrow();
    var head = await repo.headCommit().getOrThrow();
    return commitPreOrderIterator(objStorage: repo.objStorage, from: head)
        .asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView.builder(
        controller: _scrollController,
        itemBuilder: _buildTile,
        itemCount: commits.length,
      ),
    );
  }

  Widget _buildTile(BuildContext context, int i) {
    if (i >= commits.length) {
      return const CircularProgressIndicator();
    }

    var result = commits[i];
    return result.isSuccess
        ? _CommitTile(commit: result.getOrThrow())
        : _FailureTile(result: result);
  }
}

class _CommitTile extends StatelessWidget {
  final GitCommit commit;

  const _CommitTile({Key? key, required this.commit}) : super(key: key);

  static final _dateFormat = DateFormat('dd MMM, yyyy');

  @override
  Widget build(BuildContext context) {
    var msgLines = LineSplitter.split(commit.message).toList();
    var title = msgLines.first;

    var textTheme = Theme.of(context).textTheme;

    var titleRow = Row(
      children: <Widget>[
        Expanded(
          child: Text(title, style: textTheme.subtitle2!),
        ),
        Text(
          _dateFormat.format(commit.author.date),
          style: textTheme.caption,
        )
      ],
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
    );
    return ListTile(
      title: titleRow,
    );
  }
}

class _FailureTile<T> extends StatelessWidget {
  final Result<T> result;

  _FailureTile({Key? key, required this.result}) : super(key: key) {
    Log.e("Failure", ex: result.error, stacktrace: result.stackTrace);
  }

  @override
  Widget build(BuildContext context) {
    return Text(result.error.toString());
  }
}
