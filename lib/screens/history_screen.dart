/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:dart_git/git.dart';
import 'package:dart_git/plumbing/commit_iterator.dart';
import 'package:dart_git/plumbing/objects/commit.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/repository.dart';
import 'package:gitjournal/widgets/future_builder_with_progress.dart';

class HistoryScreen extends StatelessWidget {
  static const String routePath = "/history";

  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const HistoryWidget(),
    );
  }
}

class HistoryWidget extends StatefulWidget {
  const HistoryWidget({Key? key}) : super(key: key);

  @override
  _HistoryWidgetState createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  List<GitCommit> commits = [];
  Stream<Result<GitCommit>>? _stream;

  @override
  void initState() {
    super.initState();
  }

  Future<Stream<Result<GitCommit>>> _initStream() async {
    var gjRepo = Provider.of<GitJournalRepo>(context);

    var repo = await GitRepository.load(gjRepo.gitBaseDirectory).getOrThrow();
    return commitPreOrderIterator(
      objStorage: repo.objStorage,
      from: await repo.headCommit().getOrThrow(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilderWithProgress(
      future: () async {
        _stream = await _initStream();

        return ListView.builder(
          itemBuilder: (BuildContext context, int i) {
            return FutureBuilderWithProgress(future: _buildTile(context, i));
          },
        );
      }(),
    );
  }

  Future<Widget> _buildTile(BuildContext context, int i) async {
    var stream = _stream!;

    // Put in a lock!
    if (i >= commits.length) {
      for (var j = 0; j < (commits.length - i).abs() + 1; j++) {
        await for (var commit in stream) {
          commits.add(commit.getOrThrow());
          break;
        }
      }
    }

    var commit = commits[i];
    return Text(commit.message);
  }
}
