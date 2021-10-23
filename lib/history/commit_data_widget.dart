/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:dart_git/dart_git.dart';
import 'package:dart_git/diff_commit.dart';
import 'package:dart_git/plumbing/git_hash.dart';
import 'package:dart_git/plumbing/objects/blob.dart';
import 'package:dart_git/plumbing/objects/commit.dart';

import 'package:gitjournal/logger/logger.dart';

class CommitDataWidget extends StatefulWidget {
  final GitRepository gitRepo;
  final GitCommit commit;
  final GitCommit parentCommit;

  const CommitDataWidget({
    required this.gitRepo,
    required this.commit,
    required this.parentCommit,
    Key? key,
  }) : super(key: key);

  @override
  _CommitDataWidgetState createState() => _CommitDataWidgetState();
}

class _CommitDataWidgetState extends State<CommitDataWidget> {
  Exception? _exception;
  CommitBlobChanges? _changes;

  @override
  void initState() {
    super.initState();

    _initStateAsync();
  }

  Future<void> _initStateAsync() async {
    // FIXME: Run all of this in another worker thread!

    var r = await diffCommits(
      fromCommit: widget.parentCommit,
      toCommit: widget.commit,
      objStore: widget.gitRepo.objStorage,
    );
    if (r.isFailure) {
      Log.e("Got exception in diffCommits",
          ex: r.error, stacktrace: r.stackTrace);
      return setState(() {
        _exception = r.exception;
      });
    }
    setState(() {
      _changes = r.getOrThrow();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_exception != null) {
      return Text(_exception!.toString());
    }
    if (_changes == null) {
      return const CircularProgressIndicator();
    }

    return _build();
  }

  Widget _build() {
    var children = <Widget>[];
    for (var change in _changes!.merged()) {
      if (change.add) {
        var hash = change.hash;
        var w = _BlobLoader(
            blobHash: hash, gitRepo: widget.gitRepo, color: Colors.green);
        children.add(w);
      } else if (change.delete) {
        var hash = change.hash;
        var w = _BlobLoader(
            blobHash: hash, gitRepo: widget.gitRepo, color: Colors.red);
        children.add(w);
      } else if (change.modify) {
        var hash = change.hash;
        var w = _BlobLoader(
            blobHash: hash, gitRepo: widget.gitRepo, color: Colors.red);
        children.add(w);

        var hash2 = change.to!.hash;
        var w2 = _BlobLoader(
            blobHash: hash2, gitRepo: widget.gitRepo, color: Colors.green);
        children.add(w2);
      }
    }

    return Column(
      children: children,
    );
  }
}

class _BlobLoader extends StatefulWidget {
  final GitRepository gitRepo;
  final GitHash blobHash;
  final Color color;

  const _BlobLoader({
    required this.gitRepo,
    required this.blobHash,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  __BlobLoaderState createState() => __BlobLoaderState();
}

class __BlobLoaderState extends State<_BlobLoader> {
  GitBlob? _blob;
  Exception? _exception;

  @override
  void initState() {
    super.initState();

    _initStateAsync();
  }

  Future<void> _initStateAsync() async {
    var result = await widget.gitRepo.objStorage.readBlob(widget.blobHash);
    setState(() {
      _exception = result.exception;
      _blob = result.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_exception != null) {
      return Text(_exception.toString());
    }

    if (_blob == null) {
      return const CircularProgressIndicator();
    }

    // FIXME: All of this boilerplate can easily be removed!

    try {
      var blob = _blob!;
      var text = utf8.decode(blob.blobData);

      var theme = Theme.of(context);
      var style = theme.textTheme.subtitle1!.copyWith(
        fontFamily: "Roboto Mono",
        color: widget.color,
      );
      return Text(text, style: style);
    } catch (ex) {
      return Text(ex.toString());
    }
  }
}
