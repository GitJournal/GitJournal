import 'package:flutter/material.dart';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/app_settings.dart';

class AppDrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appSettings = Provider.of<AppSettings>(context);

    var stack = Stack(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/icon/icon.png'),
              ),
            ),
          ),
        ),
        if (appSettings.proMode)
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ProButton(),
              ),
            ),
          ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topRight,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
                child: ThemeSwitcherButton(),
              ),
            ),
          ),
        ),
      ],
      fit: StackFit.passthrough,
    );

    /*
    var dropdownValue = 'One';
    var repoSelector = DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String newValue) {
        dropdownValue = newValue;
      },
      items: <String>['One', 'Two', 'Free', 'Four']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
    */

    return DrawerHeader(
      margin: const EdgeInsets.all(0.0),
      decoration: BoxDecoration(
        color: Theme.of(context).highlightColor,
      ),
      padding: const EdgeInsets.all(8.0),
      child: stack,
    );
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
