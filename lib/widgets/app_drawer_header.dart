import 'package:flutter/material.dart';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/app_settings.dart';

class AppDrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appSettings = Provider.of<AppSettings>(context);

    return Stack(
      children: <Widget>[
        DrawerHeader(
          margin: const EdgeInsets.all(0.0),
          decoration: BoxDecoration(
            color: Theme.of(context).highlightColor,
          ),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/icon/icon.png'),
                ),
              ),
            ),
          ),
        ),
        /*
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              padding: const EdgeInsets.all(0),
              icon: Icon(Icons.arrow_left, size: 42.0),
              onPressed: () {},
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              padding: const EdgeInsets.all(0),
              icon: Icon(Icons.arrow_right, size: 42.0),
              onPressed: () {},
            ),
          ),
        ),
        */
        if (appSettings.proMode)
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomRight,
              child: ProButton(),
            ),
          ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topRight,
            child: SafeArea(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 16, 0),
              child: ThemeSwitcherButton(),
            )),
          ),
        ),
      ],
      fit: StackFit.passthrough,
    );
  }
}

class ProButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(color: theme.accentColor, spreadRadius: 0),
          ],
        ),
        padding: const EdgeInsets.all(8.0),
        child: Text('PRO', style: theme.textTheme.button),
      ),
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
