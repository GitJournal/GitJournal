/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:function_types/function_types.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:provider/provider.dart';
import 'package:time/time.dart';

class AppDrawerHeader extends StatelessWidget {
  final Func0<void> repoListToggled;

  const AppDrawerHeader({
    required this.repoListToggled,
  });

  @override
  Widget build(BuildContext context) {
    var appConfig = Provider.of<AppConfig>(context);

    var top = Row(
      children: <Widget>[
        const DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/icon/icon.png'),
            ),
          ),
          child: SizedBox(width: 64, height: 64),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
          child: ThemeSwitcherButton(),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
    );

    var currentRepo = _CurrentRepo(
      repoListToggled: repoListToggled,
    );

    var header = DrawerHeader(
      margin: const EdgeInsets.all(0.0),
      decoration: BoxDecoration(
        color: Theme.of(context).highlightColor,
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Column(
        children: <Widget>[
          top,
          currentRepo,
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
    );

    if (!appConfig.proMode) {
      return header;
    }

    var isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;
    return Banner(
      message: isDesktop ? context.loc.beta : context.loc.pro,
      location: BannerLocation.topStart,
      color: Theme.of(context).colorScheme.secondary,
      child: header,
    );
  }
}

class _CurrentRepo extends StatefulWidget {
  const _CurrentRepo({
    required this.repoListToggled,
  });

  final Func0<void> repoListToggled;

  @override
  __CurrentRepoState createState() => __CurrentRepoState();
}

class __CurrentRepoState extends State<_CurrentRepo>
    with SingleTickerProviderStateMixin {
  late Animation _animation;
  late AnimationController _controller;

  var _gitRemoteUrl = "";
  var _repoFolderName = "";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: 250.milliseconds, vsync: this);
    _animation = Tween(begin: 0.0, end: 0.5).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _fetchRepoInfo();

    var textTheme = Theme.of(context).textTheme;

    var w = Row(
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              Text(_repoFolderName, style: textTheme.headline6),
              const SizedBox(height: 8.0),
              Text(
                _gitRemoteUrl,
                style: textTheme.subtitle2,
                overflow: TextOverflow.clip,
                maxLines: 1,
              ),
              const SizedBox(height: 8.0),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
        RotationTransition(
          turns: _animation as Animation<double>,
          child: IconButton(
            icon: const FaIcon(FontAwesomeIcons.angleDown),
            onPressed: _pressed,
          ),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
    );

    return GestureDetector(
      child: w,
      behavior: HitTestBehavior.opaque,
      onTap: _pressed,
    );
  }

  void _pressed() {
    if (_controller.isCompleted) {
      var _ = _controller.reverse(from: 1.0);
    } else {
      var _ = _controller.forward(from: 0.0);
    }
    widget.repoListToggled();
  }

  Future<void> _fetchRepoInfo() async {
    if (_repoFolderName.isNotEmpty) {
      return;
    }

    var repoManager = context.watch<RepositoryManager>();
    _repoFolderName = repoManager.repoFolderName(repoManager.currentId);

    if (repoManager.currentRepoError != null) {
      _gitRemoteUrl = "Error";
      return;
    }

    var repo = context.watch<GitJournalRepo>();
    var remoteConfigs = await repo.remoteConfigs();
    if (!mounted) return;

    if (remoteConfigs.isEmpty) {
      setState(() {
        _gitRemoteUrl = context.loc.drawerRemote;
      });
      return;
    }

    setState(() {
      _gitRemoteUrl = remoteConfigs.first.url;
      var i = _gitRemoteUrl.indexOf('@');
      if (i != -1 && i + 1 < _gitRemoteUrl.length) {
        _gitRemoteUrl = _gitRemoteUrl.substring(i + 1);
      }
    });
  }
}

class ThemeSwitcherButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: const FaIcon(FontAwesomeIcons.solidMoon),
      onTap: () {
        var theme = Theme.of(context);
        var settings = context.read<Settings>();

        if (theme.brightness == Brightness.light) {
          settings.theme = SettingsTheme.Dark;
        } else {
          settings.theme = SettingsTheme.Light;
        }
        settings.save();
      },
    );
  }
}
