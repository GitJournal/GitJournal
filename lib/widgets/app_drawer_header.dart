import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:function_types/function_types.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:time/time.dart';

import 'package:gitjournal/repository.dart';
import 'package:gitjournal/settings/app_settings.dart';
import 'package:gitjournal/settings/settings.dart';

class AppDrawerHeader extends StatelessWidget {
  final Func0<void> repoListToggled;

  AppDrawerHeader({
    required this.repoListToggled,
  });

  @override
  Widget build(BuildContext context) {
    var appSettings = Provider.of<AppSettings>(context);

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

    if (!appSettings.proMode) {
      return header;
    }

    return Banner(
      message: tr('pro'),
      location: BannerLocation.topStart,
      color: Theme.of(context).accentColor,
      child: header,
    );
  }
}

class _CurrentRepo extends StatefulWidget {
  const _CurrentRepo({
    Key? key,
    required this.repoListToggled,
  }) : super(key: key);

  final Func0<void> repoListToggled;

  @override
  __CurrentRepoState createState() => __CurrentRepoState();
}

class __CurrentRepoState extends State<_CurrentRepo>
    with SingleTickerProviderStateMixin {
  late Animation _animation;
  late AnimationController controller;

  var _gitRemoteUrl = "";
  var _repoFolderName = "";

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: 250.milliseconds, vsync: this);
    _animation = Tween(begin: 0.0, end: 0.5).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    controller.dispose();
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
    if (controller.isCompleted) {
      controller.reverse(from: 1.0);
    } else {
      controller.forward(from: 0.0);
    }
    widget.repoListToggled();
  }

  void _fetchRepoInfo() async {
    if (_repoFolderName.isNotEmpty) {
      return;
    }

    var repo = context.watch<GitJournalRepo>();
    var repoPath =
        await repo.storageConfig.buildRepoPath(repo.gitBaseDirectory);
    _repoFolderName = p.basename(repoPath);

    var remoteConfigs = await repo.remoteConfigs();
    if (!mounted) return;

    if (remoteConfigs.isEmpty) {
      setState(() {
        _gitRemoteUrl = tr("drawer.remote");
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

class ProButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(color: theme.accentColor, spreadRadius: 0),
        ],
      ),
      padding: const EdgeInsets.all(8.0),
      child: Text('PRO', style: theme.textTheme.button),
    );
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
