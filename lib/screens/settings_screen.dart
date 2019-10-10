import 'package:flutter/material.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils.dart';

import 'package:dynamic_theme/dynamic_theme.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SettingsList(),
    );
  }
}

class SettingsList extends StatefulWidget {
  @override
  SettingsListState createState() {
    return SettingsListState();
  }
}

class SettingsListState extends State<SettingsList> {
  final gitAuthorKey = GlobalKey<FormFieldState<String>>();
  final gitAuthorEmailKey = GlobalKey<FormFieldState<String>>();
  final fontSizeKey = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    var settings = Settings.instance;

    var saveGitAuthor = (String gitAuthor) {
      Settings.instance.gitAuthor = gitAuthor;
      Settings.instance.save();
    };

    var gitAuthorForm = Form(
      child: TextFormField(
        key: gitAuthorKey,
        style: Theme.of(context).textTheme.title,
        decoration: const InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'Who should author the changes?',
          labelText: 'Full Name',
        ),
        validator: (String value) {
          value = value.trim();
          if (value.isEmpty) {
            return 'Please enter a name';
          }
          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: saveGitAuthor,
        onSaved: saveGitAuthor,
        initialValue: Settings.instance.gitAuthor,
      ),
      onChanged: () {
        if (!gitAuthorKey.currentState.validate()) return;
        var gitAuthor = gitAuthorKey.currentState.value;
        saveGitAuthor(gitAuthor);
      },
    );

    var saveGitAuthorEmail = (String gitAuthorEmail) {
      Settings.instance.gitAuthorEmail = gitAuthorEmail;
      Settings.instance.save();
    };
    var gitAuthorEmailForm = Form(
      child: TextFormField(
        key: gitAuthorEmailKey,
        style: Theme.of(context).textTheme.title,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          icon: Icon(Icons.email),
          hintText: 'Who should author the changes?',
          labelText: 'Email',
        ),
        validator: (String value) {
          value = value.trim();
          if (value.isEmpty) {
            return 'Please enter an email';
          }

          bool emailValid =
              RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
          if (!emailValid) {
            return 'Please enter a valid email';
          }
          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: saveGitAuthorEmail,
        onSaved: saveGitAuthorEmail,
        initialValue: Settings.instance.gitAuthorEmail,
      ),
      onChanged: () {
        if (!gitAuthorEmailKey.currentState.validate()) return;
        var gitAuthorEmail = gitAuthorEmailKey.currentState.value;
        saveGitAuthorEmail(gitAuthorEmail);
      },
    );

    var brightness = DynamicTheme.of(context).brightness;

    return ListView(children: [
      SettingsHeader('Display Settings'),
      ListPreference(
        title: "Theme",
        currentOption: brightness == Brightness.light ? "Light" : "Dark",
        options: ["Light", "Dark"],
        onChange: (String newVal) {
          var dynamicTheme = DynamicTheme.of(context);
          switch (newVal) {
            case "Dark":
              dynamicTheme.setBrightness(Brightness.dark);
              break;
            case "Light":
            case "default":
              dynamicTheme.setBrightness(Brightness.light);
              break;
          }
        },
      ),
      ListTile(
        title: Text("Font Size"),
        subtitle: Text(settings.noteFontSize.toPublicString()),
        onTap: () async {
          var fontSize = await showDialog<NoteFontSize>(
            context: context,
            builder: (context) => FontSizeSettingsDialog(settings.noteFontSize),
          );

          if (fontSize != null) {
            settings.noteFontSize = fontSize;
            settings.save();
            setState(() {});
          }
        },
      ),
      SettingsHeader("Git Author Settings"),
      ListTile(title: gitAuthorForm),
      ListTile(title: gitAuthorEmailForm),
      SizedBox(height: 16.0),
      SettingsHeader("Storage"),
      ListPreference(
        title: "File Name",
        currentOption: settings.noteFileNameFormat.toPublicString(),
        options:
            NoteFileNameFormat.options.map((f) => f.toPublicString()).toList(),
        onChange: (String publicStr) {
          var format = NoteFileNameFormat.fromPublicString(publicStr);
          Settings.instance.noteFileNameFormat = format;
          Settings.instance.save();
          setState(() {});
        },
      ),
      SizedBox(height: 16.0),
      SettingsHeader("Analytics"),
      BoolPreference(
        title: "Collect Anonymous Usage Statistics",
        defaultValue: Settings.instance.collectUsageStatistics,
        onChange: (bool val) {
          Settings.instance.collectUsageStatistics = val;
          Settings.instance.save();
          setState(() {});
        },
      ),
      BoolPreference(
        title: "Collect Anonymous Crash Reports",
        defaultValue: Settings.instance.collectUsageStatistics,
        onChange: (bool val) {
          Settings.instance.collectCrashReports = val;
          Settings.instance.save();
          setState(() {});
        },
      ),
      VersionNumberTile(),
    ]);
  }
}

class SettingsHeader extends StatelessWidget {
  final String text;
  SettingsHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, bottom: 0.0, top: 20.0),
      child: Text(
        text,
        style: TextStyle(
            color: Theme.of(context).accentColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class VersionNumberTile extends StatefulWidget {
  @override
  VersionNumberTileState createState() {
    return VersionNumberTileState();
  }
}

class VersionNumberTileState extends State<VersionNumberTile> {
  String versionText = "";

  @override
  void initState() {
    super.initState();

    () async {
      var str = await getVersionString();
      setState(() {
        versionText = str;
      });
    }();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return ListTile(
      title: Text("Version Info", style: textTheme.subhead),
      subtitle: Text(
        versionText,
        style: textTheme.body1,
        textAlign: TextAlign.left,
      ),
      enabled: false,
    );
  }
}

class FontSizeSettingsDialog extends StatelessWidget {
  final String title = "Font Size";
  final NoteFontSize prevSize;

  FontSizeSettingsDialog(this.prevSize);

  @override
  Widget build(BuildContext context) {
    var sizes = <Widget>[];
    for (var fontSize in NoteFontSize.options) {
      var highlight = fontSize == prevSize;
      var tile = _constructTile(context, fontSize, highlight);
      sizes.add(tile);
    }

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: ListBody(
          children: sizes,
        ),
      ),
    );
  }

  Widget _constructTile(
    BuildContext context,
    NoteFontSize fontSize,
    bool highlight,
  ) {
    var style = Theme.of(context).textTheme.body1;
    style = style.copyWith(fontSize: fontSize.toDouble());

    var tile = ListTile(
      title: Text(fontSize.toPublicString(), style: style),
      onTap: () {
        Navigator.of(context).pop(fontSize);
      },
    );
    if (!highlight) {
      return tile;
    }

    return Container(
      color: Theme.of(context).highlightColor,
      child: tile,
    );
  }
}

class ListPreference extends StatelessWidget {
  final String title;
  final String currentOption;
  final List<String> options;
  final Function onChange;

  ListPreference({
    @required this.title,
    @required this.currentOption,
    @required this.options,
    @required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(currentOption),
      onTap: () async {
        var option = await showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              var children = <Widget>[];
              for (var o in options) {
                var tile = ListTile(
                  title: Text(o),
                  onTap: () {
                    Navigator.of(context).pop(o);
                  },
                );
                children.add(tile);
              }
              return AlertDialog(
                title: Text(title),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: children,
                  ),
                ),
              );
            });

        if (option != null) {
          onChange(option);
        }
      },
    );
  }
}

class BoolPreference extends StatelessWidget {
  final String title;
  final bool defaultValue;
  final Function(bool) onChange;

  BoolPreference({
    @required this.title,
    @required this.defaultValue,
    @required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Checkbox(
        value: defaultValue,
        onChanged: onChange,
      ),
      onTap: () => onChange(!defaultValue),
    );
  }
}
