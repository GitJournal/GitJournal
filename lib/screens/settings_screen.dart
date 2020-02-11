import 'package:flutter/material.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/screens/settings_widgets.dart';
import 'package:gitjournal/screens/settings_git_remote.dart';
import 'package:gitjournal/screens/settings_note_metadata.dart';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:gitjournal/widgets/folder_selection_dialog.dart';
import 'package:provider/provider.dart';

var defaultFolderConfigurable = false;

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
    var stateContainer = Provider.of<StateContainer>(context, listen: false);

    var remoteGitConfigured = stateContainer.appState.remoteGitRepoConfigured;
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
      SwitchListTile(
        title: const Text("Dark Theme"),
        value: brightness == Brightness.dark,
        onChanged: (bool newVal) {
          var b = newVal ? Brightness.dark : Brightness.light;
          var dynamicTheme = DynamicTheme.of(context);
          dynamicTheme.setBrightness(b);
        },
      ),
      if (defaultFolderConfigurable) SettingsHeader('Note Settings'),
      if (defaultFolderConfigurable)
        ListTile(
          title: const Text("Default Folder for new notes"),
          subtitle: Text(Settings.instance.defaultNewNoteFolder
              .replaceFirst('journal', 'Notes')),
          onTap: () async {
            var destFolder = await showDialog<NotesFolder>(
              context: context,
              builder: (context) => FolderSelectionDialog(),
            );
            if (destFolder != null) {
              Settings.instance.defaultNewNoteFolder = destFolder.fullName;
              Settings.instance.save();
              setState(() {});
            }
          },
        ),
      SettingsHeader("Git Author Settings"),
      ListTile(title: gitAuthorForm),
      ListTile(title: gitAuthorEmailForm),
      ListTile(
        title: const Text("Git Remote Settings"),
        subtitle: const Text("Configure where your notes are synced"),
        onTap: () {
          var route = MaterialPageRoute(
            builder: (context) => GitRemoteSettingsScreen(),
          );
          Navigator.of(context).push(route);
        },
        enabled: remoteGitConfigured,
      ),
      const SizedBox(height: 16.0),
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
      ListTile(
        title: const Text("Note Metadata Settings"),
        subtitle: const Text("Configure how the YAML Metadata is saved"),
        onTap: () {
          var route = MaterialPageRoute(
            builder: (context) => NoteMetadataSettingsScreen(),
          );
          Navigator.of(context).push(route);
        },
      ),
      const SizedBox(height: 16.0),
      SettingsHeader("Analytics"),
      SwitchListTile(
        title: const Text("Collect Anonymous Usage Statistics"),
        value: Settings.instance.collectUsageStatistics,
        onChanged: (bool val) {
          Settings.instance.collectUsageStatistics = val;
          Settings.instance.save();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: const Text("Collect Anonymous Crash Reports"),
        value: Settings.instance.collectCrashReports,
        onChanged: (bool val) {
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
      padding: const EdgeInsets.only(left: 16.0, bottom: 0.0, top: 20.0),
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
