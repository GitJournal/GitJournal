import 'package:flutter/material.dart';
import 'package:journal/settings.dart';
import 'package:journal/utils.dart';

import 'package:preferences/preferences.dart';
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
          labelText: 'Git Author',
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
        decoration: const InputDecoration(
          icon: Icon(Icons.email),
          hintText: 'Who should author the changes?',
          labelText: 'Git Author Email',
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

    return PreferencePage([
      PreferenceTitle('Display Settings'),
      DropdownPreference(
        'Theme',
        'theme',
        defaultVal: "Light",
        values: ["Light", "Dark"],
        onChange: (newVal) {
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
      DropdownPreference(
        'Font Size',
        'font_size',
        defaultVal: "Normal",
        values: [
          "Extra Small",
          "Small",
          "Normal",
          "Large",
          "Extra Large",
        ],
        onChange: (newVal) {
          NoteViewerFontSize fontSize;
          switch (newVal) {
            case "Extra Small":
              fontSize = NoteViewerFontSize.ExtraSmall;
              break;
            case "Small":
              fontSize = NoteViewerFontSize.Small;
              break;
            case "Normal":
              fontSize = NoteViewerFontSize.Normal;
              break;
            case "Large":
              fontSize = NoteViewerFontSize.Large;
              break;
            case "Extra Large":
              fontSize = NoteViewerFontSize.ExtraLarge;
              break;
            default:
              fontSize = NoteViewerFontSize.Normal;
          }
          Settings.instance.noteViewerFontSize = fontSize;
          Settings.instance.save();
        },
      ),
      PreferenceTitle("Git Settings"),
      ListTile(title: gitAuthorForm),
      ListTile(title: gitAuthorEmailForm),
      SizedBox(height: 16.0),
      PreferenceTitle("Storage"),
      DropdownPreference(
        'File Name',
        'file_name',
        defaultVal: "ISO8601 With TimeZone",
        values: [
          "ISO8601 With TimeZone",
          "ISO8601",
          "ISO8601 without Colons",
        ],
        onChange: (newVal) {
          NoteFileNameFormat format;
          switch (newVal) {
            case "ISO8601 With TimeZone":
              format = NoteFileNameFormat.Iso8601WithTimeZone;
              break;
            case "ISO8601":
              format = NoteFileNameFormat.Iso8601;
              break;
            case "ISO8601 without Colons":
              format = NoteFileNameFormat.Iso8601WithTimeZoneWithoutColon;
              break;
            default:
              format = NoteFileNameFormat.Iso8601WithTimeZone;
          }
          Settings.instance.noteFileNameFormat = format;
          Settings.instance.save();
        },
      ),
      SizedBox(height: 16.0),
      PreferenceTitle("Analytics"),
      CheckboxPreference(
        "Collect Anonymous Usage Statistics",
        "usage_stats",
        defaultVal: Settings.instance.collectUsageStatistics,
        onEnable: () {
          Settings.instance.collectUsageStatistics = true;
          Settings.instance.save();
        },
        onDisable: () {
          Settings.instance.collectUsageStatistics = false;
          Settings.instance.save();
        },
      ),
      CheckboxPreference(
        "Collect Anonymous Crash Reports",
        "crash_reports",
        defaultVal: Settings.instance.collectCrashReports,
        onEnable: () {
          Settings.instance.collectCrashReports = true;
          Settings.instance.save();
        },
        onDisable: () {
          Settings.instance.collectCrashReports = false;
          Settings.instance.save();
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
    return ListTile(
      dense: true,
      title: Text(
        text,
        style: Theme.of(context).textTheme.title,
      ),
      enabled: false,
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
