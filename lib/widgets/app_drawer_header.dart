import 'package:flutter/material.dart';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:function_types/function_types.dart';
import 'package:provider/provider.dart';
import 'package:time/time.dart';

import 'package:gitjournal/app_settings.dart';

class AppDrawerHeader extends StatelessWidget {
  final Func0<void> repoListToggled;
  final bool showRepoList;

  AppDrawerHeader({
    @required this.repoListToggled,
    @required this.showRepoList,
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
      showRepoList: showRepoList,
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
    Key key,
    @required this.showRepoList,
    @required this.repoListToggled,
  }) : super(key: key);

  final bool showRepoList;
  final Func0<void> repoListToggled;

  @override
  __CurrentRepoState createState() => __CurrentRepoState();
}

class __CurrentRepoState extends State<_CurrentRepo>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: 250.milliseconds, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    var w = Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Text("journal", style: textTheme.headline6),
            const SizedBox(height: 8.0),
            Text("github.com/vhanda/journal", style: textTheme.subtitle2),
            const SizedBox(height: 8.0),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        RotationTransition(
          turns: Tween(begin: 0.0, end: 0.5).animate(controller),
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
      controller.reverse(from: 0.0);
    } else {
      controller.forward(from: 0.0);
    }
    widget.repoListToggled();
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
        var dynamicTheme = DynamicTheme.of(context);
        var brightness = dynamicTheme.brightness;

        dynamicTheme.setBrightness(brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light);
      },
    );
  }
}
