import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:git_bindings/git_bindings.dart';
import 'package:badges/badges.dart';

import 'package:gitjournal/appstate.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/utils.dart';
import 'package:provider/provider.dart';

class SyncButton extends StatefulWidget {
  @override
  _SyncButtonState createState() => _SyncButtonState();
}

class _SyncButtonState extends State<SyncButton> {
  StreamSubscription<ConnectivityResult> subscription;
  ConnectivityResult _connectivity;

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
    final appState = Provider.of<StateContainer>(context).appState;

    if (_connectivity == ConnectivityResult.none) {
      return IconButton(
        icon: Icon(Icons.signal_wifi_off),
        onPressed: () async {
          _syncRepo();
        },
      );
    }
    if (appState.syncStatus == SyncStatus.Pulling) {
      return BlinkingIcon(
        icon: Icon(Icons.cloud_download),
      );
    }

    if (appState.syncStatus == SyncStatus.Pushing) {
      return BlinkingIcon(
        icon: Icon(Icons.cloud_upload),
      );
    }

    var theme = Theme.of(context);
    var darkMode = theme.brightness == Brightness.dark;
    var style = theme.textTheme.caption.copyWith(
      fontSize: 6.0,
      color: darkMode ? Colors.black : Colors.white,
    );

    return Badge(
      badgeContent: Text(appState.numChanges.toString(), style: style),
      showBadge: appState.numChanges != 0,
      badgeColor: theme.iconTheme.color,
      position: BadgePosition.topRight(top: 10.0, right: 4.0),
      child: IconButton(
        icon: Icon(_syncStatusIcon()),
        onPressed: () async {
          _syncRepo();
        },
      ),
    );
  }

  void _syncRepo() async {
    try {
      final container = Provider.of<StateContainer>(context, listen: false);
      await container.syncNotes();
    } on GitException catch (e) {
      showSnackbar(context, "Sync Error: ${e.cause}");
    } catch (e) {
      showSnackbar(context, e.toString());
    }
  }

  IconData _syncStatusIcon() {
    final container = Provider.of<StateContainer>(context);
    final appState = container.appState;
    switch (appState.syncStatus) {
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
  final Icon icon;
  final int interval;

  BlinkingIcon({@required this.icon, this.interval = 500, Key key})
      : super(key: key);

  @override
  _BlinkingIconState createState() => _BlinkingIconState();
}

class _BlinkingIconState extends State<BlinkingIcon>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

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

    _controller.repeat(reverse: true);
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
      child: IconButton(
        icon: widget.icon,
        onPressed: () {},
      ),
    );
  }
}
