/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:dart_git/git.dart';
import 'package:dart_git/plumbing/commit_iterator.dart';
import 'package:dart_git/plumbing/objects/commit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:synchronized/synchronized.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/widgets/future_builder_with_progress.dart';

class HistoryScreen extends StatelessWidget {
  static const String routePath = "/history";

  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.drawer_history.tr()),
      ),
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

  final _lock = Lock();

  @override
  void initState() {
    super.initState();
  }

  Future<Stream<Result<GitCommit>>> _initStream() async {
    print('initializing the stream?');
    var gjRepo = Provider.of<GitJournalRepo>(context);

    var repo = await GitRepository.load(gjRepo.repoPath).getOrThrow();
    var head = await repo.headCommit().getOrThrow();
    return commitPreOrderIterator(objStorage: repo.objStorage, from: head);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilderWithProgress(
      future: () async {
        _stream = await _initStream();

        return Scrollbar(
          child: ListView.builder(
            itemBuilder: (BuildContext context, int i) {
              print('tile builder $i');
              return FutureBuilderWithProgress(future: _buildTile(context, i));
            },
          ),
        );
      }(),
    );
  }

  Future<Widget> _buildTile(BuildContext context, int i) async {
    var stream = _stream!;

    // This needs to happen in another thread!
    await _lock.synchronized(() async {
      if (i >= commits.length) {
        for (var j = 0; j < (commits.length - i).abs() + 1; j++) {
          print('about to await for in the stream - $j');
          try {
            await for (var commit in stream) {
              commits.add(commit.getOrThrow());
            }
          } catch (e, st) {
            print(e);
            print(st);
          }

          print('done with the stream');
        }
      }
    });

    try {
      var commit = commits[i];
      return ListTile(
        title: Text(commit.message),
        subtitle: Text(commit.author.date.toString()),
      );
    } catch (e, st) {
      print(e);
      print(st);
      return const Text('fail');
    }
  }
}
