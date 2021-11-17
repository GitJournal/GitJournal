/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:badges/badges.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:git_bindings/git_bindings.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/sync_attempt.dart';
import 'package:gitjournal/utils/utils.dart';

class SyncButton extends StatefulWidget {
  @override
  _SyncButtonState createState() => _SyncButtonState();
}

class _SyncButtonState extends State<SyncButton> {
  late StreamSubscription<ConnectivityResult> subscription;
  ConnectivityResult? _connectivity;

  @override
  void initState() {
    super.initState();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        _connectivity = result;
      });
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<GitJournalRepo>(context);

    if (_connectivity == ConnectivityResult.none) {
      return GitPendingChangesBadge(
        child: IconButton(
          icon: const Icon(Icons.signal_wifi_off),
          onPressed: () async {
            _syncRepo();
          },
        ),
      );
    }
    if (repo.syncStatus == SyncStatus.Pulling) {
      return BlinkingIcon(
        child: GitPendingChangesBadge(
          child: IconButton(
            icon: const Icon(Icons.cloud_download),
            onPressed: () {},
          ),
        ),
      );
    }

    if (repo.syncStatus == SyncStatus.Pushing) {
      return BlinkingIcon(
        child: GitPendingChangesBadge(
          child: IconButton(
            icon: const Icon(Icons.cloud_upload),
            onPressed: () {},
          ),
        ),
      );
    }

    if (repo.syncStatus == SyncStatus.Error) {
      return GitPendingChangesBadge(
        child: IconButton(
          icon: const Icon(Icons.cloud_off),
          onPressed: () async {
            _syncRepo();
          },
        ),
      );
    }

    return GitPendingChangesBadge(
      child: IconButton(
        icon: Icon(_syncStatusIcon()),
        onPressed: () async {
          _syncRepo();
        },
      ),
    );
  }

  Future<void> _syncRepo() async {
    try {
      final repo = Provider.of<GitJournalRepo>(context, listen: false);
      await repo.syncNotes();
    } on GitException catch (e) {
      showSnackbar(
        context,
        tr(LocaleKeys.widgets_SyncButton_error, args: [e.cause]),
      );
    } catch (e) {
      showSnackbar(context, e.toString());
    }
  }

  IconData _syncStatusIcon() {
    final repo = Provider.of<GitJournalRepo>(context);
    switch (repo.syncStatus) {
      case SyncStatus.Error:
        return Icons.cloud_off;

      case SyncStatus.Unknown:
      case SyncStatus.Done:
      default:
        return Icons.cloud_done;
    }
  }
}

class BlinkingIcon extends StatefulWidget {
  final Widget child;
  final int interval;

  const BlinkingIcon({required this.child, this.interval = 500, Key? key})
      : super(key: key);

  @override
  _BlinkingIconState createState() => _BlinkingIconState();
}

class _BlinkingIconState extends State<BlinkingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: widget.interval),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );

    var _ = _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

class GitPendingChangesBadge extends StatelessWidget {
  final Widget child;

  const GitPendingChangesBadge({required this.child});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var darkMode = theme.brightness == Brightness.dark;
    var style = theme.textTheme.caption!.copyWith(
      fontSize: 6.0,
      color: darkMode ? Colors.black : Colors.white,
    );

    final repo = Provider.of<GitJournalRepo>(context);

    return Badge(
      badgeContent: Text(repo.numChanges.toString(), style: style),
      showBadge: repo.numChanges != 0,
      badgeColor: theme.iconTheme.color!,
      position: BadgePosition.topEnd(top: 10.0, end: 4.0),
      child: child,
    );
  }
}
